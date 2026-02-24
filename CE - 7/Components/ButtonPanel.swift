import SwiftUI

struct ButtonPanel: View {
    let state: RecorderState
    let isPaused: Bool
    let onPrime: () -> Void
    let onPlay: () -> Void
    let onStop: () -> Void

    private var canPrime: Bool {
        state == .none || state == .primed || state == .playback
    }

    private var canPlay: Bool {
        state == .primed || state == .none || (state == .playback && isPaused)
    }

    private var canStop: Bool {
        state == .recording || state == .playback
    }

    var body: some View {
        HStack(spacing: 4) {
            TiltButton(
                icon: "circle.fill",
                iconColor: .accentColor,
                edge: .leading,
                isEnabled: canPrime,
                action: onPrime,
                disabledAction: { print("Prime not available in state: \(state)") }
            )
            TiltButton(
                icon: "play.fill",
                iconColor: .black.opacity(0.65),
                edge: .center,
                isEnabled: canPlay,
                action: onPlay,
                disabledAction: { print("Play not available in state: \(state)") }
            )
            TiltButton(
                icon: "stop.fill",
                iconColor: .black.opacity(0.65),
                edge: .trailing,
                isEnabled: canStop,
                action: onStop,
                disabledAction: { print("Stop not available in state: \(state)") }
            )
        }
        .padding(.top, 4)
        .padding(.trailing, 4)
        .background(Color.black)
        .clipShape(UnevenRoundedRectangle(topTrailingRadius: 6))
        .padding(.top, 4)
        .padding(.trailing, 4)
        .background(.black.opacity(0.2))
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 74/255, green: 74/255, blue: 74/255), location: 0.00),
                    Gradient.Stop(color: .white.opacity(0.76), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: -0.01),
                endPoint: UnitPoint(x: 0.5, y: 0.02)
            )
        )
        .clipShape(UnevenRoundedRectangle(topTrailingRadius: 8))
        .shadow(color: .white.opacity(0.3), radius: 8, x: 3, y: -3)
    }
}
