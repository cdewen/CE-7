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
                        VStack(spacing: 4) {
                            Text(formattedDuration(recording.duration))
                                .font(.system(size: 24, design: .monospaced).bold())
                                .textCase(.uppercase)
                                .kerning(2)

                            HStack {
                                Text(dayLabel(for: recording.recordedAt))
                                    .font(.system(size: 16, design: .monospaced))
                                    .textCase(.uppercase)

                                Spacer()

                                Text(recording.recordingNumberOfDay, format: .number.precision(.integerLength(2)))
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
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    RecordingsListView()
        .environmentObject(TapeEngine())
        .modelContainer(for: RecordingItem.self, inMemory: true)
}
