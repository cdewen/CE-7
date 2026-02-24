import Foundation
import SwiftData

@Model
final class RecordingItem {
    @Attribute(.unique) var id: UUID
    var recordedAt: Date
    var fileName: String
    var duration: TimeInterval
    var recordingNumberOfDay: Int

    init(
        id: UUID = UUID(),
        recordedAt: Date,
        fileName: String,
        duration: TimeInterval,
        recordingNumberOfDay: Int = 1
    ) {
        self.id = id
        self.recordedAt = recordedAt
        self.fileName = fileName
        self.duration = duration
        self.recordingNumberOfDay = recordingNumberOfDay
    }
}
