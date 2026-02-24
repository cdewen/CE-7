import SwiftUI

struct Display: View {
    let timeText: String
    let dayText: String
    let recordingNumber: Int
    var animatedTimeValue: Double? = nil

    var body: some View {
        VStack(spacing: 4) {
            timeLabel
            
            HStack {
                Text(dayText)
                    .font(.system(size: 16, design: .monospaced))
                    .textCase(.uppercase)
                
                Spacer()
                
                Text(recordingNumber, format: .number.precision(.integerLength(2)))
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
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var timeLabel: some View {
        let base = Text(timeText)
            .font(.system(size: 24, design: .monospaced).bold())
            .textCase(.uppercase)
            .kerning(2)

        if let value = animatedTimeValue {
            base
                .contentTransition(.numericText(value: -value))
                .animation(.default, value: timeText)
        } else {
            base
        }
    }
}
