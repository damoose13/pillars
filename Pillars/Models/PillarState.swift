import SwiftUI

/// How a pillar is doing today, in human language. Numeric scores stay internal (1–5);
/// the UI leans on these qualitative states instead of raw numbers.
enum PillarState: String, CaseIterable, Codable, Hashable {
    case drained   // 1
    case quiet     // 2
    case steady    // 3
    case strong    // 4
    case full      // 5

    static func from(score: Int) -> PillarState {
        switch max(1, min(5, score)) {
        case 1: return .drained
        case 2: return .quiet
        case 3: return .steady
        case 4: return .strong
        default: return .full
        }
    }

    var displayName: String {
        switch self {
        case .drained: return "Drained"
        case .quiet: return "Quiet"
        case .steady: return "Steady"
        case .strong: return "Strong"
        case .full: return "Full"
        }
    }

    /// Alias kept for existing call sites.
    var label: String { displayName }

    /// A short, supportive read — no alarm, no diagnosis.
    var supportCopy: String {
        switch self {
        case .drained: return "needs real support"
        case .quiet: return "asking for care"
        case .steady: return "holding shape"
        case .strong: return "supporting you"
        case .full: return "deeply resourced"
        }
    }

    /// True when a restoration would meaningfully help (scores 1–2).
    var isAskingForSupport: Bool { self == .quiet || self == .drained }

    /// A calm, non-judgemental color — warm gold for "needs you", soft green for resourced.
    var color: Color {
        switch self {
        case .full:    return PillarsColors.positive
        case .strong:  return PillarsColors.goldSoft
        case .steady:  return PillarsColors.secondaryText
        case .quiet:   return PillarsColors.gold
        case .drained: return PillarsColors.caution
        }
    }
}
