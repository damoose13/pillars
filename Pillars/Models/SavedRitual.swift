import Foundation
import SwiftData

/// A ritual the user chose to keep close. Stored by the ritual's stable id; the ritual content
/// itself lives in `RitualLibrary`.
@Model
final class SavedRitual {
    @Attribute(.unique) var ritualID: String
    var savedAt: Date

    init(ritualID: String, savedAt: Date = .now) {
        self.ritualID = ritualID
        self.savedAt = savedAt
    }
}
