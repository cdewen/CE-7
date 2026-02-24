import SwiftUI

struct AudioBars: View {
    var level: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 82/255, green: 82/255, blue: 82/255),
                        Color(red: 169/255, green: 169/255, blue: 169/255).opacity(0.81)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .shadow(.inner(color: .black.opacity(0.5), radius: 17, x: 0, y: 6))
            )
            .frame(width: 6)
            .cornerRadius(8)
            .overlay {
                GeometryReader { geo in
                    let fillRatio = min(max(level, 0), 1)
                    let fillHeight = geo.size.height * fillRatio
                    let redThreshold: CGFloat = 0.7
                    let hasRed = fillRatio > redThreshold
                    let redHeight = hasRed ? geo.size.height * (fillRatio - redThreshold) : 0
                    let whiteHeight = fillHeight - redHeight
                    
                    VStack(spacing: 0) {
                        if hasRed {
                            Rectangle()
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 8))
                                .shadow(color: .recording, radius: 2, x: 0, y: 0)
                                .foregroundStyle(Color.recording.opacity(0.85))
                                .frame(height: redHeight)
                        }
                        
                        Rectangle()
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: hasRed ? 0 : 8, bottomLeadingRadius: 8, bottomTrailingRadius: 8, topTrailingRadius: hasRed ? 0 : 8))
                            .shadow(color: .white, radius: 2, x: 0, y: 0)
                            .foregroundStyle(Color.white.opacity(0.85))
                            .frame(height: whiteHeight)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .overlay(
                GeometryReader { geo in
                    let count = 13
                    let spacing = geo.size.height / CGFloat(count + 1)
                    let bandHeight: CGFloat = 1.5
                    let pinch: CGFloat = 1.5
                    
                    ForEach(0..<count, id: \.self) { i in
                        let y = spacing * CGFloat(i + 1)
                        
                        Path { path in
                            let w = geo.size.width
                            
                            path.move(to: CGPoint(x: 0, y: y - bandHeight / 2))
                            path.addQuadCurve(
                                to: CGPoint(x: w, y: y - bandHeight / 2),
                                control: CGPoint(x: w / 2, y: y - bandHeight / 2 - pinch)
                            )
                            
                            path.addLine(to: CGPoint(x: w, y: y + bandHeight / 2))
                            path.addQuadCurve(
                                to: CGPoint(x: 0, y: y + bandHeight / 2),
                                control: CGPoint(x: w / 2, y: y + bandHeight / 2 - pinch)
                            )
                            
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 153/255, green: 153/255, blue: 153/255).opacity(0),
                                    Color(red: 166/255, green: 166/255, blue: 166/255).opacity(0.16),
                                    Color(red: 191/255, green: 191/255, blue: 191/255)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
            )
    }
}
