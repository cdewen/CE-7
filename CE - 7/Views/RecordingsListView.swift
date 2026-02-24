import SwiftUI
import SwiftData

struct RecordingsListView: View {
    @Query(sort: \RecordingItem.recordedAt, order: .reverse) private var recordings: [RecordingItem]
    @EnvironmentObject private var engine: TapeEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if recordings.isEmpty {
                ContentUnavailableView(
                    "No Recordings Yet",
                    systemImage: "waveform",
                    description: Text("Record something and it will appear here.")
                )
            } else {
                List(recordings) { recording in
                    Button {
                        engine.playRecording(recording)
                        dismiss()
                    } label: {
                        Display(
                            timeText: formattedDuration(recording.duration),
                            dayText: dayLabel(for: recording.recordedAt),
                            recordingNumber: recording.recordingNumberOfDay
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            engine.deleteRecording(recording)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Recordings")
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    RecordingsListView()
        .environmentObject(TapeEngine())
        .modelContainer(for: RecordingItem.self, inMemory: true)
}
