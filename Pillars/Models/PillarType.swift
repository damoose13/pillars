import SwiftUI

/// The eight life pillars Pillars measures.
///
/// Labels are intentionally short and mainstream. `purpose` is the default name for the
/// eighth pillar and can be renamed by the user (Spirit, Faith, Dharma, Values, Meaning,
/// Direction) without changing its identity — see `PillarNaming`.
enum PillarType: String, Codable, CaseIterable, Identifiable, Hashable {
    case body
    case fuel
    case sleep
    case recover
    case mind
    case connect
    case space
    case purpose

    var id: String { rawValue }

    /// The canonical, non-customized name.
    var defaultName: String {
        switch self {
        case .body: return "Body"
        case .fuel: return "Fuel"
        case .sleep: return "Sleep"
        case .recover: return "Recover"
        case .mind: return "Mind"
        case .connect: return "Connect"
        case .space: return "Space"
        case .purpose: return "Purpose"
        }
    }

    /// The user-facing name, honoring any custom alias (currently only `purpose`).
    var displayName: String { PillarNaming.shared.name(for: self) }

    /// SF Symbol used to represent the pillar. Chosen to read as a calm, coherent set.
    var icon: String {
        switch self {
        case .body: return "figure.walk"
        case .fuel: return "fork.knife"
        case .sleep: return "moon.stars.fill"
        case .recover: return "arrow.triangle.2.circlepath"
        case .mind: return "brain.head.profile"
        case .connect: return "person.2.fill"
        case .space: return "house.fill"
        case .purpose: return "mountain.2.fill"
        }
    }

    /// A one-line description used in philosophy and detail screens.
    var shortDescription: String {
        switch self {
        case .body: return "Strength, movement, and physical vitality."
        case .fuel: return "Nourishment, hydration, and steady energy."
        case .sleep: return "Rest, and the depth of your overnight recovery."
        case .recover: return "Active recovery, mobility, and a calm nervous system."
        case .mind: return "Focus, clarity, and mental steadiness."
        case .connect: return "Closeness and honest connection with others."
        case .space: return "The order and calm of your environment."
        case .purpose: return "Meaning, direction, and alignment with what matters."
        }
    }

    /// The prompt shown during a check-in.
    var checkInPrompt: String {
        switch self {
        case .body: return "How does your body feel today?"
        case .fuel: return "How well have you fueled yourself?"
        case .sleep: return "How was your sleep?"
        case .recover: return "How recovered do you feel?"
        case .mind: return "How clear is your mind?"
        case .connect: return "How connected do you feel to others?"
        case .space: return "How is the space around you?"
        case .purpose: return "How aligned do you feel with what matters?"
        }
    }

    /// Muted, tasteful accent color. Desaturated on purpose — these read as a harmonious
    /// family on a warm dark ground, never as primary/neon swatches.
    var color: Color {
        switch self {
        case .body:    return Color(red: 0.78, green: 0.44, blue: 0.40) // clay
        case .fuel:    return Color(red: 0.82, green: 0.61, blue: 0.36) // amber
        case .sleep:   return Color(red: 0.44, green: 0.50, blue: 0.72) // dusk indigo
        case .recover: return Color(red: 0.40, green: 0.64, blue: 0.58) // muted teal
        case .mind:    return Color(red: 0.60, green: 0.52, blue: 0.76) // soft violet
        case .connect: return Color(red: 0.82, green: 0.53, blue: 0.55) // muted rose
        case .space:   return Color(red: 0.62, green: 0.66, blue: 0.50) // sage
        case .purpose: return Color(red: 0.80, green: 0.66, blue: 0.40) // warm bronze
        }
    }

    /// Suggested alternate names for the Purpose pillar, offered in Settings.
    static let purposeAliasSuggestions = ["Purpose", "Spirit", "Faith", "Values", "Meaning", "Direction", "Dharma"]
}

/// Resolves user-facing pillar names, applying any custom alias.
///
/// Kept as a tiny process-wide store (backed by `AppState` / `UserDefaults`) so that
/// `PillarType.displayName` stays a simple property usable from anywhere — including deep
/// inside reusable components — while remaining consistent app-wide.
final class PillarNaming {
    static let shared = PillarNaming()
    private init() {}

    /// Custom name for the Purpose pillar, or `nil` to use the default.
    var purposeAlias: String?

    func name(for pillar: PillarType) -> String {
        if pillar == .purpose, let alias = purposeAlias, !alias.isEmpty {
            return alias
        }
        return pillar.defaultName
    }
}
