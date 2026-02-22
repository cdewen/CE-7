//
//  ContentView.swift
//  TP7
//
//  Created by Carter Ewen on 2/19/26.
//

import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    var body: some View {
        ZStack {
            MetalBackground()
            
            VStack {
                HStack {
                    Spacer()
                    Display()
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                }
                .padding(.top, 32)
                
                Spacer()
                
                TapeReel()
                    .padding(.horizontal)
                
                
                HStack {
                    Light(isOn: false)
                    Spacer()
                }
                .padding(.bottom, 32)
                
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ButtonPanel()
                            .frame(width: geo.size.width * 0.75)
                        
                        BarPanel()
                            .frame(width: geo.size.width * 0.25)
                    }
                }
                .frame(height: 200)
            }
        }
        .ignoresSafeArea()
    }
}

//MARK: - Screw

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

//MARK: - Display

struct Display: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("0:00:00")
                .font(.system(size: 24, design: .monospaced).bold())
                .textCase(.uppercase)
                .kerning(2)
            
            HStack {
                Text("Today")
                    .font(.system(size: 16, design: .monospaced))
                    .textCase(.uppercase)
                
                Spacer()
                
                Text("01")
                    .font(.system(size: 12, design: .monospaced))
                    .textCase(.uppercase)
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white)
                    .cornerRadius(4)
            }
        }
        .padding(12)
        .foregroundColor(.white)
        .background(Color.black)
        .cornerRadius(8)
        .fixedSize()
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8))
    }
}

//MARK: - Light

struct Light: View {
    @State var isOn: Bool

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

    var body: some View {
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
            //TODO: figure out best glasseffect stlye
            //.glassEffect(isOn ? .clear : .regular)
            .shadow(color: isOn ? .recording.opacity(0.8) : .clear, radius: 6, x: 0, y: 0)
            .padding(.leading, 30)
            .padding(.bottom, 8)
            .onTapGesture {
                withAnimation() {
                    isOn.toggle()
                }
            }
    }
}

// MARK: - Button Panel (Left Side)

struct ButtonPanel: View {
    var body: some View {
        HStack(spacing: 4) {
            TiltButton(icon: "circle.fill", iconColor: .accent, edge: .leading)
            TiltButton(icon: "play.fill")
            TiltButton(icon: "stop.fill")
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

// MARK: - Tilt Button

enum TiltButtonEdge {
    case leading
    case center
    case trailing
}

struct TiltButtonShape: Shape {
    let edge: TiltButtonEdge
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
    @State private var isPressed = false
    
    /// Reads the display corner radius from the first connected screen (private UIKit key, falls back to 44)
    private var screenCornerRadius: CGFloat {
        guard let screen = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.screen else { return 44 }
        return screen.value(forKey: "_displayCornerRadius") as? CGFloat ?? 44
    }
    
    private var clipShape: TiltButtonShape {
        switch edge {
        case .leading:
            TiltButtonShape(
                edge: .leading,
                topLeadingRadius: 4,
                topTrailingRadius: 4,
                bottomLeadingRadius: screenCornerRadius,
                bottomTrailingRadius: 0
            )
        case .center:
            TiltButtonShape(
                edge: .center,
                topLeadingRadius: 4,
                topTrailingRadius: 4,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0
            )
        case .trailing:
            TiltButtonShape(
                edge: .trailing,
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
                .degrees(isPressed ? -8 : 0),
                axis: (x: 1, y: 0, z: 0),
                anchor: .top,
                perspective: 0.5
            )
            .onTapGesture {
                // Quick tilt down
                withAnimation(.spring(response: 0.15, dampingFraction: 0.8)) {
                    isPressed = true
                }
                // Hold briefly, then slowly spring back
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                        isPressed = false
                    }
                }
            }
    }
}

// MARK: - Rail Panel (Right Side)

struct BarPanel: View {
    @State private var barsHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color(red: 105/255, green: 105/255, blue: 105/255))
                .frame(height: 2)
                .padding(.top, barsHeight * 4/15 + 1.5)
                .padding(.horizontal)
            
            HStack {
                Spacer()
                AudioBars(decibel: 12)
                Spacer()
                AudioBars(decibel: 3)
                Spacer()
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { barsHeight = geo.size.height }
                        .onChange(of: geo.size.height) { _, newValue in
                            barsHeight = newValue
                        }
                }
            )
        }
        .padding(.bottom, 32)
    }
}

// MARK: - Metal Rail (Vertical Lines)

struct AudioBars: View {
    var decibel: CGFloat = 0
    
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
                    let fillRatio = min(decibel / 14, 1)
                    let fillHeight = geo.size.height * fillRatio
                    let redThreshold: CGFloat = 10.0 / 14.0
                    let hasRed = decibel > 10
                    let redHeight = hasRed ? geo.size.height * (fillRatio - redThreshold) : 0
                    let whiteHeight = fillHeight - redHeight
                    
                    VStack(spacing: 0) {
                        // Red portion (above 10 dB)
                        if hasRed {
                            Rectangle()
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 8))
                                .shadow(color: .recording, radius: 2, x: 0, y: 0)
                                .foregroundStyle(Color.recording.opacity(0.85))
                                .frame(height: redHeight)
                        }
                        
                        // White portion (up to 10 dB)
                        Rectangle()
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: fillRatio > 10/14 ? 0 : 8, bottomLeadingRadius: 8, bottomTrailingRadius: 8, topTrailingRadius:fillRatio > 10/14 ? 0 : 8))
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


// MARK: - Metal Background

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

//MARK: - Tape Reel
struct TapeReel: View {
    @State private var angle: CGFloat = 0
    @State private var lastAngle: CGFloat = 0
    
    var body: some View {
        GeometryReader { outerGeo in
            let size = min(outerGeo.size.width, outerGeo.size.height)
            let half = size / 2
            
            ZStack {
                //black background
                Circle()
                    .shadow(color: .white.opacity(0.8), radius: 3, x: 2, y: 5)
                    .shadow(color: .white.opacity(0.34), radius: 80, x: 0, y: 10)
                
                //metal textured main part (STATIC)
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
                
                //shiny center background (STATIC)
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
                
                // ROTATING GROUP: lines, text, stroke borders, screws
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
                .rotationEffect(.degrees(Double(angle)))
            }
            .contentShape(Circle())
            .gesture(
                DragGesture()
                    .onChanged { v in
                        var theta = (
                            atan2(v.location.x - half, half - v.location.y) -
                            atan2(v.startLocation.x - half, half - v.startLocation.y)
                        ) * 180 / .pi
                        if theta < 0 { theta += 360 }
                        angle = theta + lastAngle
                    }
                    .onEnded { _ in
                        lastAngle = angle
                    }
            )
        }
    }
}

#Preview {
   ContentView()
}
