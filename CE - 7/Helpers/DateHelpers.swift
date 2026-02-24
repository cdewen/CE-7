import Foundation

func dayLabel(for date: Date) -> String {
    if Calendar.current.isDateInToday(date) {
        return "Today"
    }
    return date.formatted(.dateTime.month(.abbreviated).day())
}
