import SwiftUI

struct Screw: View {
    var size: CGFloat = 12

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .black, location: 0.00),
                        Gradient.Stop(color: Color(red: 0.21, green: 0.21, blue: 0.21), location: 0.21),
                        Gradient.Stop(color: .white, location: 0.56),
                        Gradient.Stop(color: Color(red: 0.34, green: 0.33, blue: 0.33), location: 0.85),
                        Gradient.Stop(color: Color(red: 0.16, green: 0.15, blue: 0.15), location: 1.00),
                    ],
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                )
                .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 1, y: 3))
            )
            .frame(width: size, height: size)
            .shadow(color: .white.opacity(0.55), radius: 1, x: 2, y: 0)
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.14, green: 0.14, blue: 0.14), location: 0.00),
                                Gradient.Stop(color: Color(red: 0.84, green: 0.84, blue: 0.84), location: 0.53),
                                Gradient.Stop(color: Color(red: 0.35, green: 0.35, blue: 0.35), location: 1.00),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}
