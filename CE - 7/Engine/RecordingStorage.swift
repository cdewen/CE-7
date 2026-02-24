import Foundation
import AVFoundation
import SwiftData

struct RecordingStorage {
    struct LoadedRecording {
        let samplesL: [Float]
        let samplesR: [Float]
        let sampleRate: Double
    }

    func saveRecording(
        samplesL: [Float],
        samplesR: [Float],
        sampleRate: Double,
        recordedAt: Date,
        context: ModelContext
    ) throws {
        let frameCount = min(samplesL.count, samplesR.count)
        guard frameCount > 0 else { return }

        let recordingsDir = try recordingsDirectoryURL()
        let fileID = UUID()
        let fileName = "\(fileID.uuidString).caf"
        let fileURL = recordingsDir.appendingPathComponent(fileName, isDirectory: false)

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        ) else {
            return
        }

        buffer.frameLength = AVAudioFrameCount(frameCount)
        if let left = buffer.floatChannelData?[0], let right = buffer.floatChannelData?[1] {
            samplesL.withUnsafeBufferPointer { left.update(from: $0.baseAddress!, count: frameCount) }
            samplesR.withUnsafeBufferPointer { right.update(from: $0.baseAddress!, count: frameCount) }
        }

        let file = try AVAudioFile(
            forWriting: fileURL,
            settings: format.settings,
            commonFormat: .pcmFormatFloat32,
            interleaved: false
        )
        try file.write(from: buffer)

        let recordingNumberOfDay = try nextRecordingNumber(of: recordedAt, context: context)
        let duration = Double(frameCount) / sampleRate
        let item = RecordingItem(
            id: fileID,
            recordedAt: recordedAt,
            fileName: fileName,
            duration: duration,
            recordingNumberOfDay: recordingNumberOfDay
        )
        context.insert(item)
        try context.save()
    }

    func loadRecording(item: RecordingItem) throws -> LoadedRecording? {
        try loadRecording(fileName: item.fileName)
    }

    func loadRecording(fileName: String) throws -> LoadedRecording? {
        let fileURL = try recordingsDirectoryURL().appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let audioFile = try AVAudioFile(forReading: fileURL)
        let format = audioFile.processingFormat
        let length = AVAudioFrameCount(audioFile.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: length) else {
            return nil
        }
        try audioFile.read(into: buffer)

        let frameLength = Int(buffer.frameLength)
        guard let channels = buffer.floatChannelData else { return nil }

        let left = Array(UnsafeBufferPointer(start: channels[0], count: frameLength))
        let right: [Float]
        if format.channelCount > 1 {
            right = Array(UnsafeBufferPointer(start: channels[1], count: frameLength))
        } else {
            right = left
        }

        return LoadedRecording(
            samplesL: left,
            samplesR: right,
            sampleRate: format.sampleRate
        )
    }

    func deleteRecording(item: RecordingItem, context: ModelContext) throws {
        let fileURL = try recordingsDirectoryURL().appendingPathComponent(item.fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        context.delete(item)
        try context.save()
    }

    private func recordingsDirectoryURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = base.appendingPathComponent("Recordings", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    func nextRecordingNumber(of recordedAt: Date, context: ModelContext) throws -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: recordedAt)
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return 1
        }

        let predicate = #Predicate<RecordingItem> { item in
            item.recordedAt >= startOfDay && item.recordedAt < startOfNextDay
        }
        let descriptor = FetchDescriptor<RecordingItem>(predicate: predicate)
        let count = try context.fetchCount(descriptor)
        return count + 1
    }
}
