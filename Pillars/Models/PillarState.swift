import SwiftUI

/// How a pillar is doing today, in human language. Deliberately avoids "low" / "bad" —
/// a pillar is never failing, it's just *asking* for support.
enum PillarState: String, CaseIterable, Hashable {
    case firm
    case steady
    case asking
    case quiet
    case drained

    /// Maps a 1–5 score to a state.
    static func from(score: Int) -> PillarState {
        switch max(1, min(5, score)) {
        case 5: return .firm
        case 4: return .steady
        case 3: return .asking
        case 2: return .quiet
        default: return .drained
        }
    }

    var label: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    /// A short, supportive read — no alarm, no diagnosis.
    var blurb: String {
        switch self {
        case .firm:    return "Holding strong."
        case .steady:  return "Steady and reliable."
        case .asking:  return "Asking for a little attention."
        case .quiet:   return "Gone quiet lately."
        case .drained: return "Running on empty — be gentle here."
        }
    }

    /// True when the pillar would benefit from a restoration today.
    var isAskingForSupport: Bool {
        self == .asking || self == .quiet || self == .drained
    }

    /// A calm, non-judgemental color. Warm gold for "needs you", soft green for strong.
    var color: Color {
        switch self {
        case .firm:    return PillarsColors.positive
        case .steady:  return PillarsColors.goldSoft
        case .asking:  return PillarsColors.gold
        case .quiet:   return PillarsColors.secondaryText
        case .drained: return PillarsColors.caution
        }
    }
}
