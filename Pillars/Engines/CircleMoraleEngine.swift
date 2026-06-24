import SwiftUI

/// The overall morale of a Circle — a single, coarse, supportive word. This is **group
/// morale**, never "health" and never a score: it's the felt sense of how the Circle is
/// holding together, derived only from a blurred aggregate that no individual can be read out of.
enum MoraleState: String {
    case low, quiet, steady, strong

    /// One warm word for the hero.
    var title: String {
        switch self {
        case .low:    return "Tender"
        case .quiet:  return "Quiet"
        case .steady: return "Steady"
        case .strong: return "Strong"
        }
    }

    /// A supportive sentence — about the group, never anyone in it.
    var description: String {
        switch self {
        case .low:
            return "The Circle's been carrying a lot. A small shared moment can lighten it."
        case .quiet:
            return "Things are running quiet. One honest check-in could lift the whole group."
        case .steady:
            return "The Circle is holding its shape. Keep the small things going."
        case .strong:
            return "The Circle is resourced and showing up for each other."
        }
    }

    /// A calm color for the morale halo — warm gold when tender (asking for care), soft
    /// green when strong. Never red, never alarming.
    var color: Color {
        switch self {
        case .low:    return PillarsColors.gold
        case .quiet:  return PillarsColors.goldSoft
        case .steady: return PillarsColors.secondaryText
        case .strong: return PillarsColors.positive
        }
    }

    /// How brightly the morale halo glows behind the group web (0–1).
    var glow: Double {
        switch self {
        case .low:    return 0.22
        case .quiet:  return 0.28
        case .steady: return 0.34
        case .strong: return 0.42
        }
    }

    var symbol: String {
        switch self {
        case .low:    return "moon.haze.fill"
        case .quiet:  return "cloud.fill"
        case .steady: return "circle.hexagongrid.fill"
        case .strong: return "sun.max.fill"
        }
    }
}

/// The gap between where the Circle is softest and where it's firmest — expressed in vague
/// words, never numbers. Used to suggest *where* a shared reset might help, without ranking.
struct CircleDimensionGap {
    let softest: PillarType
    let firmest: PillarType
    /// A blurred word for the softest dimension ("Quiet" / "Steady" / "Firm").
    let softestLabel: String
    let firmestLabel: String
}

/// The whole privacy-safe morale read of a Circle. The morale hero renders **only** this —
/// it never touches a member's raw scores.
struct CircleAggregate {
    let memberCount: Int
    let isAlone: Bool
    let webMode: GroupWebMode
    /// Whether a Group Morale word may be shown (3+ people).
    let showsMorale: Bool
    let morale: MoraleState
    /// The softest↔firmest spread, only when a full aggregate web is permitted (4+).
    let gap: CircleDimensionGap?
    /// One blurred trend, only at the 3-person tier.
    let blurredTrend: CirclePillarTrend?
    /// The soft, quantized Group Web — non-empty only at the aggregate (4+) tier.
    let webScores: [PillarWebScore]
}

/// Turns member signals into a supportive, non-identifying morale read. No AI, no diagnosis,
/// no shame — and no path by which an individual score reaches a view.
enum CircleMoraleEngine {

    // Aggregate cutoffs on the 1–5 mean. Deliberately gentle — most Circles read "Steady".
    private static let lowCutoff    = 2.5
    private static let quietCutoff  = 3.1
    private static let steadyCutoff = 3.8

    // Per-pillar buckets for the blurred trend word and quantized web.
    private static let quietPillar  = 2.6
    private static let firmPillar   = 3.6

    static func aggregate(members: [CircleMember]) -> CircleAggregate {
        let count = members.count
        let webMode = PrivacyRulesEngine.groupWebMode(memberCount: count)
        let showsMorale = PrivacyRulesEngine.canSeeMorale(memberCount: count)
        let isAlone = count <= 1

        // Internal aggregate only — these Doubles never leave this function as numbers.
        var averages: [PillarType: Double] = [:]
        for pillar in PillarType.allCases {
            if members.isEmpty {
                averages[pillar] = 3
            } else {
                let total = members.reduce(0) { $0 + $1.score(for: pillar) }
                averages[pillar] = Double(total) / Double(count)
            }
        }
        func avg(_ pillar: PillarType) -> Double { averages[pillar] ?? 3 }
        let canonical: (PillarType) -> Int = { PillarType.allCases.firstIndex(of: $0) ?? 0 }

        let overall = PillarType.allCases.map { avg($0) }.reduce(0, +) / Double(PillarType.allCases.count)
        let morale: MoraleState
        switch overall {
        case ..<lowCutoff:    morale = .low
        case ..<quietCutoff:  morale = .quiet
        case ..<steadyCutoff: morale = .steady
        default:              morale = .strong
        }

        let rankedSoftest = PillarType.allCases.sorted {
            avg($0) != avg($1) ? avg($0) < avg($1) : canonical($0) < canonical($1)
        }
        let softest = rankedSoftest.first ?? .connect
        let firmest = rankedSoftest.last ?? .body

        func vague(_ value: Double) -> String {
            value < quietPillar ? "Quiet" : (value < firmPillar ? "Steady" : "Firm")
        }
        func bucket(_ value: Double) -> Int {
            value < quietPillar ? 2 : (value < firmPillar ? 3 : 4)
        }

        // Gap + web + trend are each gated strictly by the web mode.
        let gap: CircleDimensionGap?
        let blurredTrend: CirclePillarTrend?
        let webScores: [PillarWebScore]
        switch webMode {
        case .hidden:
            gap = nil
            blurredTrend = nil
            webScores = []
        case .blurredTrend:
            gap = nil
            blurredTrend = CirclePillarTrend(pillar: softest, label: vague(avg(softest)))
            webScores = []
        case .aggregateWeb:
            gap = CircleDimensionGap(
                softest: softest, firmest: firmest,
                softestLabel: vague(avg(softest)), firmestLabel: vague(avg(firmest))
            )
            blurredTrend = nil
            webScores = PillarType.allCases.map { PillarWebScore(pillar: $0, score: bucket(avg($0))) }
        }

        return CircleAggregate(
            memberCount: count,
            isAlone: isAlone,
            webMode: webMode,
            showsMorale: showsMorale,
            morale: morale,
            gap: gap,
            blurredTrend: blurredTrend,
            webScores: webScores
        )
    }
}
