import Foundation
import SwiftData

/// A voluntary win a member chooses to share with a Circle.
///
/// **Foundation only** — see `CircleGroup`. Shared wins are the *only* thing a 2-person
/// Circle will ever surface; private pillar scores are never exposed in Circle mode.
@Model
final class SharedWin {
    var title: String
    var pillar: PillarType
    var createdAt: Date
    var note: String?
    /// Who chose to share it (e.g. "You" or a member's name). A win is the *only* thing a
    /// member ever attributes to themselves — and always voluntarily. Defaulted so adding
    /// this attribute migrates cleanly into existing local stores.
    var authorName: String = "You"

    init(
        title: String,
        pillar: PillarType,
        createdAt: Date = .now,
        note: String? = nil,
        authorName: String = "You"
    ) {
        self.title = title
        self.pillar = pillar
        self.createdAt = createdAt
        self.note = note
        self.authorName = authorName
    }
}
