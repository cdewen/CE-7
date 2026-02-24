import SwiftUI
import AVFoundation
import Accelerate
import SwiftData
internal import Combine

private func rmsToDecibels(_ rms: Float) -> Float {
    20 * log10f(max(rms, 1e-7))
}

class TapeEngine: ObservableObject {
    @Published var state: RecorderState = .none
    @Published var currentTime: TimeInterval = 0
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevelL: Float = -60
    @Published var audioLevelR: Float = -60
    @Published var isDragging = false
    @Published var angleOffset: Double = 0
    @Published var isPaused = false
    @Published var activeRecordingDate: Date?
    @Published var activeRecordingNumberOfDay: Int?
    @Published var scrubBoundaryHit: Int = 0

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var samplesL: [Float] = []
    private var samplesR: [Float] = []
    /// Raw C pointers the render block reads from (no Swift array access on RT thread)
    private var rawL: UnsafeMutablePointer<Float>?
    private var rawR: UnsafeMutablePointer<Float>?
    private var rawCount: Int = 0
    private let playhead = PlayheadState()
    private var recordingSampleRate: Double = 48000
    private var displayLink: CADisplayLink?
    private var recordingStartDate: Date?
    private var lastScrubTime: Double = 0
    private var lastScrubSample: Double = 0
    private let recordingStorage = RecordingStorage()
    private var modelContext: ModelContext?
    private var playbackLoadToken = UUID()
    private let sampleQueue = DispatchQueue(label: "com.tp7.samples")

    func configureStorage(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Session

    private func activateSession() {
        let s = AVAudioSession.sharedInstance()
        try? s.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
        try? s.setActive(true)
        try? s.setAllowHapticsAndSystemSoundsDuringRecording(true)

        guard let availableInputs = s.availableInputs,
              let builtInMic = availableInputs.first(where: { $0.portType == .builtInMic }) else { return }
        try? s.setPreferredInput(builtInMic)

        if let dataSources = builtInMic.dataSources,
           let stereoSource = dataSources.first(where: {
               $0.supportedPolarPatterns?.contains(.stereo) == true
           }) {
            try? stereoSource.setPreferredPolarPattern(.stereo)
            try? builtInMic.setPreferredDataSource(stereoSource)

            let uiOrientation = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.effectiveGeometry.interfaceOrientation ?? .portrait

            let inputOrientation: AVAudioSession.StereoOrientation
            switch uiOrientation {
            case .portrait:            inputOrientation = .portrait
            case .portraitUpsideDown:   inputOrientation = .portraitUpsideDown
            case .landscapeLeft:       inputOrientation = .landscapeLeft
            case .landscapeRight:      inputOrientation = .landscapeRight
            default:                   inputOrientation = .portrait
            }
            try? s.setPreferredInputOrientation(inputOrientation)
        }
    }

    // MARK: - State transitions

    func prime() {
        if state == .none {
            state = .primed
            startMonitoring()
        } else if state == .playback {
            fullStopPlayback()
            state = .primed
            startMonitoring()
        } else if state == .primed {
            stopMonitoring()
            state = .none
        }
    }

    private func startMonitoring() {
        activateSession()
        let input = engine.inputNode
        let fmt = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: fmt) { [weak self] buf, _ in
            guard let self = self else { return }
            let n = Int(buf.frameLength)
            let channels = Int(fmt.channelCount)
            var rmsL: Float = 0
            var rmsR: Float = 0
            vDSP_measqv(buf.floatChannelData![0], 1, &rmsL, vDSP_Length(n))
            rmsL = sqrtf(rmsL)
            if channels > 1 {
                vDSP_measqv(buf.floatChannelData![1], 1, &rmsR, vDSP_Length(n))
                rmsR = sqrtf(rmsR)
            } else {
                rmsR = rmsL
            }
            DispatchQueue.main.async {
                self.audioLevelL = rmsToDecibels(rmsL)
                self.audioLevelR = rmsToDecibels(rmsR)
            }
        }
        try? engine.start()
    }

    private func stopMonitoring() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        audioLevelL = -60
        audioLevelR = -60
    }

    func play() {
        switch state {
        case .primed:  startRecording()
        case .none:    startPlaybackFromMostRecent()
        case .playback:
            if isPaused {
                if currentTime >= recordingDuration {
                    angleOffset += currentTime * 180
                    currentTime = 0
                    playhead.renderPos.pointee = 0
                    playhead.target.pointee = 0
                }
                isPaused = false
                playhead.rate.pointee = 1.0
            }
        default: break
        }
    }

    func playRecording(_ item: RecordingItem) {
        guard modelContext != nil else { return }
        let selectedFileName = item.fileName
        let selectedDate = item.recordedAt
        let selectedNumberOfDay = item.recordingNumberOfDay

        switch state {
        case .recording:
            stopRecording()
        case .playback:
            fullStopPlayback()
        default:
            break
        }

        let token = UUID()
        playbackLoadToken = token
        let storage = recordingStorage

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                guard let loaded = try storage.loadRecording(fileName: selectedFileName) else {
                    return
                }
                DispatchQueue.main.async {
                    guard let self, self.playbackLoadToken == token else { return }
                    self.samplesL = loaded.samplesL
                    self.samplesR = loaded.samplesR
                    self.recordingSampleRate = loaded.sampleRate
                    self.recordingDuration = Double(loaded.samplesL.count) / loaded.sampleRate
                    self.activeRecordingDate = selectedDate
                    self.activeRecordingNumberOfDay = selectedNumberOfDay
                    self.startPlayback()
                }
            } catch {
                print("Failed to load selected recording: \(error)")
            }
        }
    }

    func stop() {
        switch state {
        case .recording: stopRecording()
        case .playback:
            if isPaused {
                fullStopPlayback()
            } else {
                pausePlayback()
            }
        default: break
        }
    }

    // MARK: - Recording

    private func startRecording() {
        engine.inputNode.removeTap(onBus: 0)
        if !engine.isRunning {
            activateSession()
        }

        samplesL.removeAll(keepingCapacity: true)
        samplesR.removeAll(keepingCapacity: true)
        currentTime = 0
        recordingDuration = 0
        recordingStartDate = Date()
        activeRecordingDate = nil
        activeRecordingNumberOfDay = nil
        state = .recording

        let input = engine.inputNode
        let fmt = input.outputFormat(forBus: 0)
        recordingSampleRate = fmt.sampleRate
        let channelCount = Int(fmt.channelCount)

        let sampleRate = recordingSampleRate
        input.installTap(onBus: 0, bufferSize: 1024, format: fmt) { [weak self] buf, _ in
            guard let self = self else { return }
            if self.isDragging { return }

            let n = Int(buf.frameLength)
            let ptrL = buf.floatChannelData![0]
            let chunkL = Array(UnsafeBufferPointer(start: ptrL, count: n))
            let chunkR: [Float]
            if channelCount > 1 {
                let ptrR = buf.floatChannelData![1]
                chunkR = Array(UnsafeBufferPointer(start: ptrR, count: n))
            } else {
                chunkR = chunkL
            }

            var rmsL: Float = 0
            vDSP_measqv(chunkL, 1, &rmsL, vDSP_Length(n))
            rmsL = sqrtf(rmsL)
            var rmsR: Float = 0
            vDSP_measqv(chunkR, 1, &rmsR, vDSP_Length(n))
            rmsR = sqrtf(rmsR)
            let dbL = rmsToDecibels(rmsL)
            let dbR = rmsToDecibels(rmsR)

            self.sampleQueue.async {
                self.samplesL.append(contentsOf: chunkL)
                self.samplesR.append(contentsOf: chunkR)
                let duration = Double(self.samplesL.count) / sampleRate
                DispatchQueue.main.async {
                    self.recordingDuration = duration
                    self.audioLevelL = dbL
                    self.audioLevelR = dbR
                }
            }
        }

        try? engine.start()
        startDisplayLink()
    }

    private func stopRecording() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()

        var finalSamplesL: [Float] = []
        var finalSamplesR: [Float] = []
        sampleQueue.sync {
            finalSamplesL = samplesL
            finalSamplesR = samplesR
        }

        if let modelContext, !finalSamplesL.isEmpty {
            let recordedAt = recordingStartDate ?? Date()
            do {
                try recordingStorage.saveRecording(
                    samplesL: finalSamplesL,
                    samplesR: finalSamplesR,
                    sampleRate: recordingSampleRate,
                    recordedAt: recordedAt,
                    context: modelContext
                )
            } catch {
                print("Failed to persist recording: \(error)")
            }
        }

        angleOffset += currentTime * 180
        currentTime = 0
        state = .none
        audioLevelL = -60
        audioLevelR = -60
        stopDisplayLink()
    }

    // MARK: - Playback (AVAudioSourceNode render callback)

    /// Copies Swift arrays into raw C buffers the render block can safely read.
    private func prepareSampleBuffers() {
        rawL?.deallocate(); rawR?.deallocate()

        let count = samplesL.count
        rawL = .allocate(capacity: count)
        rawR = .allocate(capacity: count)
        samplesL.withUnsafeBufferPointer { rawL!.initialize(from: $0.baseAddress!, count: count) }
        samplesR.withUnsafeBufferPointer { rawR!.initialize(from: $0.baseAddress!, count: count) }
        rawCount = count

        playhead.sampleCount.pointee = count
    }

    private func startPlaybackFromMostRecent() {
        guard let modelContext else { return }

        do {
            var descriptor = FetchDescriptor<RecordingItem>(
                sortBy: [SortDescriptor(\.recordedAt, order: .reverse)]
            )
            descriptor.fetchLimit = 1

            guard let item = try modelContext.fetch(descriptor).first else {
                return
            }
            playRecording(item)
        } catch {
            print("Failed to load most recent recording: \(error)")
        }
    }

    private func startPlayback() {
        guard !samplesL.isEmpty else { return }
        activateSession()
        state = .playback
        currentTime = 0
        isPaused = false

        prepareSampleBuffers()

        playhead.renderPos.pointee = 0
        playhead.target.pointee = 0
        playhead.rate.pointee = 1.0

        let pL = rawL!
        let pR = rawR!
        let ph = playhead

        let fmt = AVAudioFormat(standardFormatWithSampleRate: recordingSampleRate, channels: 2)!

        let src = AVAudioSourceNode(format: fmt) { _, _, frameCount, audioBufferList -> OSStatus in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            let count = ph.sampleCount.pointee

            guard abl.count >= 2 else { return noErr }
            let outL = abl[0].mData!.assumingMemoryBound(to: Float.self)
            let outR = abl[1].mData!.assumingMemoryBound(to: Float.self)

            var pos = ph.renderPos.pointee
            let rate = ph.rate.pointee
            let target = ph.target.pointee

            let drift = target - pos
            let needsCorrection = abs(rate) < 0.99 || abs(rate) > 1.01
            let correctionPerFrame = needsCorrection ? (drift / Double(frames)) * 0.15 : 0.0

            for i in 0..<frames {
                let samplePos = pos

                let idx = Int(samplePos)
                if idx >= 0 && idx < count - 1 {
                    let frac = Float(samplePos - Double(idx))
                    outL[i] = pL[idx] + frac * (pL[idx + 1] - pL[idx])
                    outR[i] = pR[idx] + frac * (pR[idx + 1] - pR[idx])
                } else if idx >= 0 && idx < count {
                    outL[i] = pL[idx]
                    outR[i] = pR[idx]
                } else {
                    outL[i] = 0
                    outR[i] = 0
                }

                pos += rate + correctionPerFrame
            }

            pos = min(max(pos, 0), Double(count))
            ph.renderPos.pointee = pos

            return noErr
        }

        sourceNode = src
        engine.attach(src)
        engine.connect(src, to: engine.mainMixerNode, format: fmt)

        try? engine.start()
        startDisplayLink()
    }

    private func pausePlayback() {
        guard state == .playback else { return }
        isPaused = true
        playhead.rate.pointee = 0
        playhead.target.pointee = playhead.renderPos.pointee
    }

    private func fullStopPlayback() {
        guard state == .playback else { return }
        playhead.rate.pointee = 0
        angleOffset += currentTime * 180

        if let src = sourceNode {
            engine.disconnectNodeOutput(src)
            engine.detach(src)
            sourceNode = nil
        }
        engine.stop()

        isPaused = false
        state = .none
        currentTime = 0
        activeRecordingDate = nil
        activeRecordingNumberOfDay = nil
        audioLevelL = -60
        audioLevelR = -60
        stopDisplayLink()
    }

    /// Called when playback reaches the end naturally
    private func stopPlayback() {
        guard state == .playback, !isDragging else { return }
        isPaused = true
        playhead.rate.pointee = 0
        playhead.renderPos.pointee = Double(samplesL.count)
        playhead.target.pointee = Double(samplesL.count)
        currentTime = recordingDuration
        audioLevelL = -60
        audioLevelR = -60
    }

    // MARK: - Scrubbing

    func beginScrub() {
        isDragging = true
        if state == .playback {
            playhead.rate.pointee = 0
            lastScrubTime = CACurrentMediaTime()
            lastScrubSample = playhead.renderPos.pointee
        }
    }

    func scrubTo(time newTime: TimeInterval) {
        guard state == .recording || state == .playback else { return }
        let maxT = recordingDuration
        let clamped = min(max(newTime, 0), maxT)
        if currentTime != clamped {
            if clamped <= 0 && currentTime > 0 {
                print("You've reached the beginning")
                scrubBoundaryHit += 1
            }
            if clamped >= maxT && maxT > 0 && currentTime < maxT {
                print("You've reached the end")
                scrubBoundaryHit += 1
            }
        }
        currentTime = clamped

        if state == .playback {
            let now = CACurrentMediaTime()
            let newSample = currentTime * recordingSampleRate
            let dt = now - lastScrubTime

            if dt > 0.001 {
                let sampleDelta = newSample - lastScrubSample
                let expectedSamples = dt * recordingSampleRate
                let newRate = sampleDelta / expectedSamples

                let currentRate = playhead.rate.pointee
                playhead.rate.pointee = currentRate * 0.3 + newRate * 0.7
            }

            playhead.target.pointee = min(max(newSample, 0), Double(rawCount))

            lastScrubTime = now
            lastScrubSample = newSample
        }
    }

    func endScrub() {
        isDragging = false
        if state == .recording {
            let target = Int(currentTime * recordingSampleRate)
            let sampleRate = recordingSampleRate
            var truncatedCount = target
            sampleQueue.sync {
                if target < samplesL.count {
                    samplesL = Array(samplesL.prefix(target))
                    samplesR = Array(samplesR.prefix(target))
                }
                truncatedCount = samplesL.count
            }
            recordingDuration = Double(truncatedCount) / sampleRate
            recordingStartDate = Date().addingTimeInterval(-currentTime)
        } else if state == .playback {
            let samplePos = currentTime * recordingSampleRate
            playhead.renderPos.pointee = samplePos
            playhead.target.pointee = samplePos
            playhead.rate.pointee = 1.0
        }
    }

    // MARK: - Display link

    private func startDisplayLink() {
        stopDisplayLink()
        let link = CADisplayLink(target: self, selector: #selector(displayFrame))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func displayFrame() {
        if state == .recording, !isDragging, let start = recordingStartDate {
            currentTime = Date().timeIntervalSince(start)
        }

        if state == .playback {
            if !isDragging {
                currentTime = playhead.renderPos.pointee / recordingSampleRate
            }

            if currentTime >= recordingDuration && !isDragging {
                stopPlayback()
                return
            }

            let idx = Int(currentTime * recordingSampleRate)
            let win = 1024
            if idx >= 0 && idx + win < samplesL.count {
                samplesL.withUnsafeBufferPointer { bufL in
                    var rms: Float = 0
                    vDSP_measqv(bufL.baseAddress! + idx, 1, &rms, vDSP_Length(win))
                    audioLevelL = rmsToDecibels(sqrtf(rms))
                }
                samplesR.withUnsafeBufferPointer { bufR in
                    var rms: Float = 0
                    vDSP_measqv(bufR.baseAddress! + idx, 1, &rms, vDSP_Length(win))
                    audioLevelR = rmsToDecibels(sqrtf(rms))
                }
            }
        }
    }

    // MARK: - Delete

    func deleteRecording(_ item: RecordingItem) {
        guard let modelContext else { return }
        do {
            try recordingStorage.deleteRecording(item: item, context: modelContext)
        } catch {
            print("Failed to delete recording: \(error)")
        }
    }

    // MARK: - Helpers

    var nextRecordingNumberForToday: Int {
        guard let modelContext else { return 1 }
        return (try? recordingStorage.nextRecordingNumber(of: Date(), context: modelContext)) ?? 1
    }

    var formattedTime: String {
        let t = max(currentTime, 0)
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        let s = Int(t) % 60
        return String(format: "%d.%02d.%02d", h, m, s)
    }

    var normalisedLevelL: CGFloat {
        CGFloat(min(max((audioLevelL + 60) / 60, 0), 1))
    }
    var normalisedLevelR: CGFloat {
        CGFloat(min(max((audioLevelR + 60) / 60, 0), 1))
    }

    deinit {
        rawL?.deallocate()
        rawR?.deallocate()
    }
}
