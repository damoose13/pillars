import Foundation

/// How a recommended action is meant to be done. Kept simple and non-medical.
enum RecommendationMode: String, Codable, CaseIterable, Hashable {
    case solo
    case onePerson
    case circle
    case community

    var label: String {
        switch self {
        case .solo: return "Solo"
        case .onePerson: return "With one person"
        case .circle: return "With your Circle"
        case .community: return "Community"
        }
    }
}

/// A single restoring action the app suggests. Value type — produced by
/// `RecommendationEngine`, never stored directly (completion is tracked via `PillarAction`).
struct PillarRecommendation: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let pillar: PillarType
    var mode: RecommendationMode
    var estimatedMinutes: Int

    init(
        title: String,
        subtitle: String,
        pillar: PillarType,
        mode: RecommendationMode = .solo,
        estimatedMinutes: Int = 5
    ) {
        // Stable identity from pillar + title so completion state survives recomputation.
        self.id = "\(pillar.rawValue)|\(title)"
        self.title = title
        self.subtitle = subtitle
        self.pillar = pillar
        self.mode = mode
        self.estimatedMinutes = estimatedMinutes
    }
}
