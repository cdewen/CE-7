import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, body: String)] = [
        (
            "circle.fill",
            "Prime",
            "Tap the red button to arm recording. The light will blink to show you're ready."
        ),
        (
            "play.fill",
            "Record & Play",
            "Once primed, tap play to start recording. Tap play again to listen back."
        ),
        (
            "hand.tap.fill",
            "Pause & Rewrite",
            "While recording, touch and hold the reel to pause. Scrub back and release to record over what you've already laid down."
        ),
        (
            "arrow.trianglehead.2.clockwise",
            "Scrub",
            "Spin the reel with your finger to scrub through a recording."
        ),
        (
            "list.bullet",
            "Recordings",
            "Tap the display in the top-right corner to browse and replay past recordings."
        ),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 24) {
                            Image(systemName: page.icon)
                                .font(.system(size: 56))
                                .foregroundStyle(index == 0 ? Color.accentColor : .white)

                            Text(page.title)
                                .font(.system(size: 28, design: .monospaced).bold())
                                .foregroundStyle(.white)
                                .kerning(2)

                            Text(page.body)
                                .font(.system(size: 17))
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        isPresented = false
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.system(size: 18, design: .monospaced).bold())
                        .kerning(1)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 20)

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        isPresented = false
                    }
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 16)
                } else {
                    Color.clear.frame(height: 35)
                }
            }
        }
    }
}

#Preview {
    TutorialView(isPresented: .constant(true))
}
