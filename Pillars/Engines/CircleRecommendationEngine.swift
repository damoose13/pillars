import Foundation

/// Turns the privacy-safe morale read into supportive **group** suggestions — what the Circle
/// might do together right now. Reads only the aggregate (`CircleAggregate`): it never sees a
/// member's score, and it only names a soft dimension when the Circle is large enough to.
enum CircleRecommendationEngine {

    static func recommendations(for aggregate: CircleAggregate, winsThisWeek: Int) -> [CircleAction] {
        if aggregate.isAlone {
            return [CircleAction(
                title: "Invite someone you trust",
                subtitle: "A Circle works best at two or more. No one ever sees your scores.",
                pillar: nil, mode: .onePerson)]
        }

        var actions: [CircleAction] = []

        // A shared reset, targeted at the softest shared dimension when privacy lets us name it.
        if let soft = aggregate.gap?.softest ?? aggregate.blurredTrend?.pillar {
            actions.append(resetAction(for: soft))
        } else {
            actions.append(CircleAction(
                title: "Start a shared reset",
                subtitle: "Pick a small moment to do together — side by side or apart. No scores involved.",
                pillar: nil, mode: .circle))
        }

        // A second action tuned to where morale sits.
        switch aggregate.morale {
        case .low, .quiet:
            actions.append(CircleAction(
                title: "Trade one honest line",
                subtitle: "Each person sends a single real sentence — how they actually are. Nothing more.",
                pillar: .connect, mode: .circle))
        case .steady:
            if winsThisWeek == 0 {
                actions.append(CircleAction(
                    title: "Name one small win",
                    subtitle: "A quiet week is a fine week. One shared win keeps the Circle warm.",
                    pillar: nil, mode: .circle))
            }
        case .strong:
            actions.append(CircleAction(
                title: "Mark the good stretch",
                subtitle: "The Circle's resourced right now. A shared note helps it last.",
                pillar: nil, mode: .circle))
        }

        return actions
    }

    private static func resetAction(for pillar: PillarType) -> CircleAction {
        switch pillar {
        case .connect:
            return CircleAction(title: "Plan one honest hour",
                                subtitle: "Same hour, a real conversation — in person or on a call.",
                                pillar: .connect, mode: .circle)
        case .purpose:
            return CircleAction(title: "Trade what mattered",
                                subtitle: ContentPreferences.shared.spiritualRitualsEnabled
                                    ? "Each names one moment that counted — a gratitude round, service, or reflection."
                                    : "Each person names one moment that counted this week.",
                                pillar: .purpose, mode: .community)
        case .space, .mind:
            return CircleAction(title: "Hold a shared reset hour",
                                subtitle: "Same hour, separate spaces. Tidy, breathe, regroup.",
                                pillar: pillar, mode: .circle)
        case .body, .recover:
            return CircleAction(title: "Move together this week",
                                subtitle: "Small daily motion as a group — shared, never a competition.",
                                pillar: .body, mode: .circle)
        case .sleep, .fuel:
            return CircleAction(title: "Set a gentle wind-down pact",
                                subtitle: "Lights low by a shared hour. Compare notes tomorrow.",
                                pillar: pillar, mode: .circle)
        }
    }
}
