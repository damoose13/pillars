import Foundation
import SwiftData

/// A small restoring action surfaced to the user.
///
/// Recommendations themselves are computed fresh (see `RestorationEngine`); a
/// `PillarAction` is persisted to remember *completion* of one of today's moves.
@Model
final class PillarAction {
    var title: String
    var subtitle: String
    var pillar: PillarType
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    /// A private reflection on whether the restoration helped. Optional, never shared.
    var helped: String?

    init(
        title: String,
        subtitle: String,
        pillar: PillarType,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        helped: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.pillar = pillar
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.helped = helped
    }
}

extension PillarAction {
    /// Whether this stored action corresponds to a given recommendation made today.
    func matches(_ recommendation: PillarRecommendation, calendar: Calendar = .current) -> Bool {
        title == recommendation.title
            && pillar == recommendation.pillar
            && calendar.isDateInToday(createdAt)
    }
}
