import SwiftUI

struct TapeReel: View {
    @ObservedObject var engine: TapeEngine
    @State private var prevAngle: Double = 0
    @State private var accumulated: Double = 0
    @State private var dragStartTime: TimeInterval = 0
    @State private var dragStartDisplayAngle: Double = 0
    @State private var hasDragStarted = false
    @State private var reelHapticTick = 0
    @State private var lastHapticAccumulated: Double = 0
    private let reelHapticStepDegrees: Double = 14
    
    private var displayAngle: Double { engine.angleOffset + engine.currentTime * 180 }
    
    var body: some View {
        GeometryReader { outerGeo in
            let size = min(outerGeo.size.width, outerGeo.size.height)
            let half = size / 2
            
            ZStack {
                Circle()
                    .shadow(color: .white.opacity(0.8), radius: 3, x: 2, y: 5)
                    .shadow(color: .white.opacity(0.34), radius: 80, x: 0, y: 10)
                
                Circle()
                    .padding(1.1)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 212/255, green: 212/255, blue: 212/255), Color(red: 170/255, green: 170/255, blue: 170/255)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .shadow(.inner(color: .white.opacity(0.9), radius: 5, x: 5, y: 3))
                        .shadow(.inner(color: .black.opacity(0.15), radius: 1, x: -5, y: -3))
                    )
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                    .overlay(
                        Rectangle()
                            .colorEffect(
                                ShaderLibrary.randomNoise()
                            )
                            .opacity(0.11)
                    )
                
                Circle()
                    .padding(128)
                    .foregroundStyle(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 209/255, green: 209/255, blue: 209/255), location: 0.0),
                                .init(color: Color(red: 196/255, green: 196/255, blue: 196/255), location: 0.07),
                                .init(color: Color(red: 215/255, green: 214/255, blue: 214/255), location: 0.34),
                                .init(color: Color(red: 103/255, green: 103/255, blue: 103/255), location: 0.4),
                                .init(color: Color(red: 87/255, green: 87/255, blue: 87/255).opacity(0.49), location: 0.73),
                                .init(color: Color(red: 169/255, green: 169/255, blue: 169/255).opacity(0.81), location: 1.0),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .opacity(0.6)
                    )
                
                Circle()
                    .padding(128)
                    .foregroundStyle(Color(red: 134/255, green: 134/255, blue: 134/255).opacity(0.16))
                
                Group {
                    GeometryReader { geo in
                        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                        let fullRadius = min(geo.size.width, geo.size.height) / 2
                        let centerRadius = fullRadius - 128
                        let gap: CGFloat = 15
                        
                        let lineStart = centerRadius + gap
                        let lineEnd = fullRadius - gap
                        let midPoint = (lineStart + lineEnd) / 2

                        Path { path in
                            path.move(to: CGPoint(x: center.x, y: center.y - lineStart))
                            path.addLine(to: CGPoint(x: center.x, y: center.y - lineEnd))
                            path.move(to: CGPoint(x: center.x, y: center.y + lineStart))
                            path.addLine(to: CGPoint(x: center.x, y: center.y + lineEnd))
                        }
                        .stroke(Color(red: 105/255, green: 105/255, blue: 105/255), lineWidth: 2)
                        
                        Text("48/16")
                            .font(.body)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color(red: 105/255, green: 105/255, blue: 105/255))
                            .position(
                                x: center.x - midPoint,
                                y: center.y
                            )
                    }
                    
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(red: 164/255, green: 164/255, blue: 164/255), location: 0.0),
                                    .init(color: Color(red: 97/255, green: 97/255, blue: 97/255), location: 0.29),
                                    .init(color: Color(red: 207/255, green: 207/255, blue: 207/255).opacity(0.11), location: 0.52),
                                    .init(color: Color(red: 131/255, green: 131/255, blue: 131/255), location: 0.76),
                                    .init(color: Color(red: 186/255, green: 186/255, blue: 186/255), location: 1.0),
                                ],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            ),
                            lineWidth: 2
                        )
                        .padding(128)
                        .overlay {
                            Circle()
                                .strokeBorder(Color.black.opacity(0.4), lineWidth: 2)
                                .padding(128)
                        }
                    
                    GeometryReader { geo in
                        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                        let radius = (min(geo.size.width, geo.size.height) / 2 - 128) * 0.6
                        
                        Screw()
                            .position(
                                x: center.x + radius * cos(-.pi / 2),
                                y: center.y + radius * sin(-.pi / 2)
                            )
                        
                        Screw()
                            .position(
                                x: center.x + radius * cos(5 * .pi / 6),
                                y: center.y + radius * sin(5 * .pi / 6)
                            )
                        
                        Screw()
                            .position(
                                x: center.x + radius * cos(.pi / 6),
                                y: center.y + radius * sin(.pi / 6)
                            )
                    }
                }
                .rotationEffect(.degrees(displayAngle))
            }
            .contentShape(Circle())
            .sensoryFeedback(.impact(weight: .light), trigger: reelHapticTick)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        let cur = atan2(v.location.x - half, half - v.location.y) * 180 / .pi

                        if !hasDragStarted {
                            let start = atan2(v.startLocation.x - half, half - v.startLocation.y) * 180 / .pi
                            prevAngle = start
                            accumulated = 0
                            lastHapticAccumulated = 0
                            dragStartTime = engine.currentTime
                            dragStartDisplayAngle = displayAngle
                            hasDragStarted = true
                            if engine.state == .recording || engine.state == .playback {
                                engine.beginScrub()
                            }
                        }

                        var delta = cur - prevAngle
                        if delta > 180 { delta -= 360 }
                        if delta < -180 { delta += 360 }
                        prevAngle = cur
                        
                        let proposedAccumulated = accumulated + delta
                        
                        if engine.state == .recording || engine.state == .playback {
                            let proposedTime = dragStartTime + (proposedAccumulated / 180.0)
                            let boundedTime = min(max(proposedTime, 0), engine.recordingDuration)
                            let boundedAccumulated = (boundedTime - dragStartTime) * 180.0
                            
                            guard boundedAccumulated != accumulated else { return }
                            accumulated = boundedAccumulated
                            engine.scrubTo(time: boundedTime)
                        } else {
                            accumulated = proposedAccumulated
                            engine.angleOffset = dragStartDisplayAngle + accumulated
                        }
                        
                        let hapticDelta = accumulated - lastHapticAccumulated
                        let hapticSteps = Int(abs(hapticDelta) / reelHapticStepDegrees)
                        if hapticSteps > 0 {
                            reelHapticTick += hapticSteps
                            let direction = hapticDelta.sign == .minus ? -1.0 : 1.0
                            lastHapticAccumulated += direction * Double(hapticSteps) * reelHapticStepDegrees
                        }
                    }
                    .onEnded { _ in
                        if hasDragStarted, engine.state == .recording || engine.state == .playback {
                            engine.endScrub()
                        }
                        hasDragStarted = false
                        lastHapticAccumulated = 0
                    }
            )
        }
    }
}
