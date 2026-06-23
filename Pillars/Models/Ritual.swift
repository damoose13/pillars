import Foundation

/// A repeatable restoration with a name and a shape. Where a `PillarRecommendation` is a
/// suggestion for *today*, a `Ritual` is a practice the user can return to again and again.
struct Ritual: Identifiable, Hashable {
    let id: String
    let name: String
    let summary: String
    let pillar: PillarType
    let mode: RecommendationMode
    let estimatedMinutes: Int
    let tone: EmotionalTone
    let shareable: Bool
    let steps: [String]
    /// A ready-to-send invitation, for shareable rituals used in the Shared Reset flow.
    let shareMessage: String?

    /// Express the ritual as a one-off restoration for today's moves.
    func asRestoration() -> PillarRecommendation {
        PillarRecommendation(
            title: name,
            subtitle: summary,
            pillar: pillar,
            mode: mode,
            estimatedMinutes: estimatedMinutes,
            emotionalTone: tone,
            shareable: shareable
        )
    }
}
