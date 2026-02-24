import SwiftUI

enum TiltButtonEdge {
    case leading
    case center
    case trailing
}

struct TiltButtonShape: Shape {
    let topLeadingRadius: CGFloat
    let topTrailingRadius: CGFloat
    let bottomLeadingRadius: CGFloat
    let bottomTrailingRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(
            topLeadingRadius: topLeadingRadius,
            bottomLeadingRadius: bottomLeadingRadius,
            bottomTrailingRadius: bottomTrailingRadius,
            topTrailingRadius: topTrailingRadius
        ).path(in: rect)
    }
}

struct TiltButton: View {
    let icon: String
    var iconColor: Color = .black.opacity(0.7)
    var edge: TiltButtonEdge = .center
    var isEnabled: Bool = true
    var action: () -> Void = {}
    var disabledAction: () -> Void = {}
    @State private var isPressed = false
    @State private var hapticTick = 0
    @State private var errorHapticTick = 0
    @State private var didHandleCurrentTouch = false
    
    private static let screenCornerRadius: CGFloat = {
        guard let screen = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.screen else { return 44 }
        return screen.value(forKey: "_displayCornerRadius") as? CGFloat ?? 44
    }()
    
    private var clipShape: TiltButtonShape {
        switch edge {
        case .leading:
            TiltButtonShape(
                topLeadingRadius: 4,
                topTrailingRadius: 4,
                bottomLeadingRadius: Self.screenCornerRadius,
                bottomTrailingRadius: 0
            )
        case .center:
            TiltButtonShape(
                topLeadingRadius: 4,
                topTrailingRadius: 4,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0
            )
        case .trailing:
            TiltButtonShape(
                topLeadingRadius: 4,
                topTrailingRadius: 4,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0
            )
        }
    }
    
    var body: some View {
        Color(red: 183/255, green: 183/255, blue: 183/255)
            .overlay(alignment: .trailing) {
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 183/255, green: 183/255, blue: 183/255), location: 0.00),
                        Gradient.Stop(color: Color(red: 246/255, green: 246/255, blue: 246/255).opacity(0.4), location: 0.22),
                        Gradient.Stop(color: Color.black.opacity(0.4), location: 1.00),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 8)
            }
            .overlay(
                Rectangle()
                    .colorEffect(
                        ShaderLibrary.randomNoise()
                    )
                    .opacity(0.11)
            )
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [.white.opacity(1), .white.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blur(radius: 1)
                .frame(height: 13)
            }
            .overlay(alignment: .leading) {
                LinearGradient(
                    colors: [.white.opacity(1), .white.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .blur(radius: 1)
                .frame(width: 8)
            }
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [.black.opacity(0.6), .black.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 6)
            }
            .overlay(alignment: .top) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(iconColor)
                    .padding(.top, 32)
            }
            .clipShape(clipShape)
            .rotation3DEffect(
                .degrees(isPressed && isEnabled ? -8 : 0),
                axis: (x: 1, y: 0, z: 0),
                anchor: .top,
                perspective: 0.5
            )
            .animation(
                isPressed
                    ? .spring(response: 0.15, dampingFraction: 0.8)
                    : .spring(response: 0.5, dampingFraction: 0.5),
                value: isPressed
            )
            .sensoryFeedback(.impact(weight: .medium), trigger: hapticTick)
            .sensoryFeedback(.error, trigger: errorHapticTick)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !didHandleCurrentTouch else { return }
                        didHandleCurrentTouch = true
                        guard isEnabled else {
                            disabledAction()
                            errorHapticTick += 1
                            return
                        }
                        hapticTick += 1
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.8)) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        defer { didHandleCurrentTouch = false }
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                            isPressed = false
                        }
                        guard isEnabled else { return }
                        action()
                    }
            )
    }
}
