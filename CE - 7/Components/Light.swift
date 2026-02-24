import SwiftUI

struct Light: View {
    let state: RecorderState

    private var gradient: some ShapeStyle {
        if isOn {
            LinearGradient(
                stops: [
                    .init(color: Color.recording.opacity(1.0), location: 0.0),
                    .init(color: Color.recording.opacity(0.6), location: 0.73),
                    .init(color: Color.recording.opacity(0.9), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .shadow(.inner(color: .recording.opacity(0.5), radius: 17, x: 0, y: 6))
        } else {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 170/255, green: 170/255, blue: 170/255).opacity(1.0), location: 0.0),
                    .init(color: Color(red: 64/255, green: 64/255, blue: 64/255).opacity(0.49), location: 0.73),
                    .init(color: Color(red: 169/255, green: 169/255, blue: 169/255).opacity(0.81), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .shadow(.inner(color: .black.opacity(0.25), radius: 17, x: 0, y: 6))
        }
    }

    private var isOn: Bool {
        switch state {
        case .recording:
            return true
        case .primed:
            // 0.8s cadence keeps attention without feeling frantic.
            return (Int(Date().timeIntervalSinceReferenceDate / 0.4) % 2) == 0
        case .none, .playback:
            return false
        }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { _ in
            Circle()
                .foregroundStyle(gradient)
                .overlay(
                    Circle()
                        .strokeBorder(
                                AnyShapeStyle(LinearGradient(
                                        stops: [
                                            .init(color: .white, location: 0),
                                            .init(color: .black.opacity(0.2), location: 0.5),
                                            .init(color: .white, location: 1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      )),
                                lineWidth: 1.5
                            )
                        .opacity(isOn ? 0.8 : 1.0)
                )
                .frame(width: 36)
                .shadow(color: isOn ? .recording.opacity(0.8) : .clear, radius: 6, x: 0, y: 0)
                .padding(.leading, 30)
                .padding(.bottom, 8)
                .animation(.easeInOut(duration: 0.15), value: isOn)
        }
    }
}
