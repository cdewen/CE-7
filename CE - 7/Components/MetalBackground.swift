import SwiftUI

struct ConcentricRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path(rect)
    }
}

struct MetalBackground: View {
    var body: some View {
        ConcentricRectangle()
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 220/255, green: 220/255, blue: 220/255),
                        Color(red: 148/255, green: 148/255, blue: 148/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                ConcentricRectangle()
                    .stroke(.white.opacity(0.6), lineWidth: 15)
                    .blur(radius: 8)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(ConcentricRectangle())
            )
            .overlay(
                ConcentricRectangle()
                    .stroke(.white.opacity(0.6), lineWidth: 15)
                    .blur(radius: 8)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(ConcentricRectangle())
            )
            .overlay(
                ConcentricRectangle()
                    .stroke(.black.opacity(0.5), lineWidth: 15)
                    .blur(radius: 8)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                    )
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .clipShape(ConcentricRectangle())
            )
            .overlay(
                Rectangle()
                    .colorEffect(
                        ShaderLibrary.randomNoise()
                    )
                    .opacity(0.11)
            )
    }
}
