import Foundation
import SwiftData

/// Keeps ritual save/unsave persistence out of the views.
enum RitualSaveStore {
    static func isSaved(_ ritual: Ritual, in saved: [SavedRitual]) -> Bool {
        saved.contains { $0.ritualID == ritual.id }
    }

    static func toggle(_ ritual: Ritual, in saved: [SavedRitual], context: ModelContext) {
        if let existing = saved.first(where: { $0.ritualID == ritual.id }) {
            context.delete(existing)
        } else {
            context.insert(SavedRitual(ritualID: ritual.id))
        }
        try? context.save()
    }

    /// Saved rituals resolved back to their library content, newest first.
    static func rituals(from saved: [SavedRitual]) -> [Ritual] {
        saved.sorted { $0.savedAt > $1.savedAt }.compactMap { RitualLibrary.ritual(id: $0.ritualID) }
    }
}
