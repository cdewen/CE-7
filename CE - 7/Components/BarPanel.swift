import SwiftUI

struct BarPanel: View {
    let leftLevel: CGFloat
    let rightLevel: CGFloat
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
                AudioBars(level: leftLevel)
                Spacer()
                AudioBars(level: rightLevel)
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
