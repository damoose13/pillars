import Foundation
import SwiftData

/// Records the *effect* of the loop: whether today's restorations were completed. Keeps the
/// create/toggle/save persistence out of the views (previously duplicated in the dashboard
/// and the Moves screen).
enum RestorationLog {

    static func isCompleted(_ recommendation: PillarRecommendation, in actions: [PillarAction]) -> Bool {
        actions.contains { $0.matches(recommendation) && $0.isCompleted }
    }

    /// Toggle completion for one of today's restorations, creating the record if needed.
    static func toggle(_ recommendation: PillarRecommendation, in actions: [PillarAction], context: ModelContext) {
        if let existing = actions.first(where: { $0.matches(recommendation) }) {
            existing.isCompleted.toggle()
            existing.completedAt = existing.isCompleted ? .now : nil
        } else {
            let action = PillarAction(
                title: recommendation.title,
                subtitle: recommendation.subtitle,
                pillar: recommendation.pillar,
                isCompleted: true,
                createdAt: .now,
                completedAt: .now
            )
            context.insert(action)
        }
        try? context.save()
    }
}
