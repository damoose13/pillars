import Foundation

/// How much a Circle may reveal, by size. Smaller Circles get *less* aggregate detail,
/// because in a small group an "average" can quietly expose an individual.
enum CirclePrivacyTier {
    /// 1–2 people: voluntary shared wins and suggestions only. No aggregates at all.
    case duo
    /// 3 people: a single, vague trend ("Connect is quiet"). Nothing more.
    case small
    /// 4+ people: aggregate pillar trend *labels* (never numbers, never per-member).
    case group

    static func tier(forMemberCount count: Int) -> CirclePrivacyTier {
        if count <= 2 { return .duo }
        if count == 3 { return .small }
        return .group
    }

    var name: String {
        switch self {
        case .duo: return "Just between you"
        case .small: return "Blurred trend"
        case .group: return "Aggregate only"
        }
    }

    /// Plain-language reassurance shown alongside the pulse.
    var shortExplainer: String {
        switch self {
        case .duo:
            return "In a Circle this small, even an average can reveal too much — so you'll only ever see voluntary wins and shared suggestions."
        case .small:
            return "With three people, the Circle shows just one soft, blurred trend — never anyone's individual scores."
        case .group:
            return "With four or more, the Circle shows aggregate pillar trends only. Individual scores never leave each person's device."
        }
    }
}

/// A single, deliberately vague pillar trend. Carries a word, never a number.
struct CirclePillarTrend: Identifiable {
    let pillar: PillarType
    /// "Quiet" · "Steady" · "Lifting".
    let label: String
    var id: PillarType { pillar }
}

/// A suggested shared action ("group reset"). Supportive, never a directive.
struct CircleAction: Identifiable {
    let title: String
    let subtitle: String
    let pillar: PillarType?
    let mode: RecommendationMode
    var id: String { title }
}

/// The whole privacy-safe read of a Circle. The Circle UI renders **only** this — it never
/// touches a member's raw scores.
struct CirclePulse {
    let tier: CirclePrivacyTier
    let memberCount: Int
    let isAlone: Bool
    let headline: String
    let trends: [CirclePillarTrend]
    let actions: [CircleAction]
}

/// Turns member signals into supportive, non-identifying Circle output. No AI, no
/// diagnoses, no shame — and no path by which an individual score reaches a view.
enum CirclePulseEngine {

    private static let quiet = 2.6
    private static let lifting = 3.6

    static func pulse(members: [CircleMember], winsThisWeek: Int) -> CirclePulse {
        let count = members.count
        let tier = CirclePrivacyTier.tier(forMemberCount: count)
        let isAlone = count <= 1

        // Internal aggregate only — these Doubles never leave this function as numbers.
        var averages: [PillarType: Double] = [:]
        for pillar in PillarType.allCases {
            if members.isEmpty {
                averages[pillar] = 3
            } else {
                let total = members.reduce(0) { $0 + $1.score(for: pillar) }
                averages[pillar] = Double(total) / Double(members.count)
            }
        }
        func avg(_ pillar: PillarType) -> Double { averages[pillar] ?? 3 }
        let canonical: (PillarType) -> Int = { PillarType.allCases.firstIndex(of: $0) ?? 0 }

        let rankedWeakest = PillarType.allCases.sorted {
            avg($0) != avg($1) ? avg($0) < avg($1) : canonical($0) < canonical($1)
        }
        let weakest = rankedWeakest.first ?? .connect

        func vague(_ value: Double) -> String {
            value < quiet ? "Quiet" : (value < lifting ? "Steady" : "Firm")
        }

        // Headline — playful, supportive, never about an individual.
        let headline: String
        if isAlone {
            headline = "Your Circle is just you, for now. Invite someone you trust."
        } else if winsThisWeek == 0 {
            headline = "Your Circle has been in solo mode this week."
        } else if avg(.connect) < quiet {
            headline = "Connection has been quiet. A shared reset could help."
        } else if avg(.purpose) < quiet {
            headline = "Purpose may need support across the Circle."
        } else {
            headline = "Your Circle is steady. A small shared moment keeps it that way."
        }

        // Trends — gated strictly by tier.
        var trends: [CirclePillarTrend] = []
        switch tier {
        case .duo:
            trends = []
        case .small:
            trends = [CirclePillarTrend(pillar: weakest, label: vague(avg(weakest)))]
        case .group:
            trends = rankedWeakest.prefix(4).map { CirclePillarTrend(pillar: $0, label: vague(avg($0))) }
        }

        let actions = suggestedActions(weakest: weakest, isAlone: isAlone)

        return CirclePulse(
            tier: tier,
            memberCount: count,
            isAlone: isAlone,
            headline: headline,
            trends: trends,
            actions: actions
        )
    }

    private static func suggestedActions(weakest: PillarType, isAlone: Bool) -> [CircleAction] {
        if isAlone {
            return [CircleAction(
                title: "Invite someone you trust",
                subtitle: "A Circle works best at two or more. No one will ever see your scores.",
                pillar: nil, mode: .onePerson)]
        }

        switch weakest {
        case .connect:
            return [
                CircleAction(title: "Send one honest check-in",
                             subtitle: "A short, real message to the group — no performance required.",
                             pillar: .connect, mode: .circle),
                CircleAction(title: "Start a 20-minute walk pledge",
                             subtitle: "Anyone who's in walks today, then shares a single line about it.",
                             pillar: .body, mode: .circle)
            ]
        case .purpose:
            return [
                CircleAction(title: "Plan a shared reflection",
                             subtitle: ContentPreferences.shared.spiritualRitualsEnabled
                                ? "A temple visit, gratitude round, service activity, or a reflection call."
                                : "A gratitude round, a service activity, or a reflection call.",
                             pillar: .purpose, mode: .community),
                CircleAction(title: "Trade one thing that mattered",
                             subtitle: "Each person names a single moment that counted this week.",
                             pillar: .purpose, mode: .circle)
            ]
        case .space, .mind:
            return [CircleAction(title: "Hold a shared reset hour",
                                 subtitle: "Same hour, separate spaces. Tidy, breathe, then regroup.",
                                 pillar: .space, mode: .circle)]
        case .body, .recover:
            return [CircleAction(title: "Move together this week",
                                 subtitle: "Small daily motion as a group — shared, never a competition.",
                                 pillar: .body, mode: .circle)]
        case .sleep, .fuel:
            return [CircleAction(title: "Set a gentle wind-down pact",
                                 subtitle: "Lights low by a shared hour tonight. Compare notes tomorrow.",
                                 pillar: .sleep, mode: .circle)]
        }
    }
}
