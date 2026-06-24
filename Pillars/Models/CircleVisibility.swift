import Foundation

/// How much of themselves a member lets the Circle see. **Opt-in; the default is private.**
/// No level ever exposes private notes unless the user separately, explicitly chooses to.
enum VisibilityLevel: String, Codable, CaseIterable, Hashable {
    /// Default. Circle sees only voluntary wins and shared resets — no pillar data.
    case privateLevel
    /// A soft status only ("steady" / "may want support"). No pillar values.
    case statusOnly
    /// Only the specific pillars the user chooses.
    case selectedPillars
    /// All pillar states (still not private notes).
    case fullShared

    var title: String {
        switch self {
        case .privateLevel:    return "Private"
        case .statusOnly:      return "Soft status"
        case .selectedPillars: return "Selected pillars"
        case .fullShared:      return "Full pillar states"
        }
    }

    var detail: String {
        switch self {
        case .privateLevel:    return "The Circle sees only the wins and resets you choose to share."
        case .statusOnly:      return "The Circle sees a soft status — never a value."
        case .selectedPillars: return "Only the pillars you pick are visible."
        case .fullShared:      return "Your pillar states are visible. Private notes are never shared."
        }
    }
}
