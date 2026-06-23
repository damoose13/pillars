import Foundation

/// Rule-based recommendation logic. No AI — predictable, calm, and shippable.
///
/// Combination rules (two related pillars low together) are evaluated first because they
/// carry more signal, then single-pillar rules, then a gentle maintenance fallback. The
/// engine returns **at most three** actions, de-duplicated, with the most relevant first.
enum RecommendationEngine {

    /// A pillar at or below this 1–5 score is considered "low" / asking for support.
    static let lowThreshold = 2

    static func recommendations(for result: PillarScoreResult) -> [PillarRecommendation] {
        let scores = result.pillarScores
        func low(_ pillar: PillarType) -> Bool { (scores[pillar] ?? 3) <= lowThreshold }

        var out: [PillarRecommendation] = []

        // 1. Combination rules — higher signal, evaluated first.
        if low(.connect) && low(.purpose) {
            out.append(.init(
                title: "Plan a shared reset",
                subtitle: "A temple visit, a shared meal, or a slow reflection walk with someone you trust.",
                pillar: .connect, mode: .onePerson, estimatedMinutes: 45))
        }
        if low(.sleep) && low(.mind) {
            out.append(.init(
                title: "Protect a slow wind-down",
                subtitle: "Dim the lights an hour early and let your mind set with the day.",
                pillar: .sleep, mode: .solo, estimatedMinutes: 30))
        }
        if low(.space) && low(.mind) {
            out.append(.init(
                title: "Reset one room",
                subtitle: "Ten quiet minutes on a single surface. Outer order, inner calm.",
                pillar: .space, mode: .solo, estimatedMinutes: 10))
        }
        if low(.body) && low(.connect) {
            out.append(.init(
                title: "Walk with someone",
                subtitle: "Twenty minutes outside with a person you've been meaning to reach.",
                pillar: .body, mode: .onePerson, estimatedMinutes: 20))
        }

        // 2. Single-pillar rules.
        if low(.connect) {
            out.append(.init(
                title: "Reach one person honestly",
                subtitle: "A short, real message. Connection restores more than it costs.",
                pillar: .connect, mode: .onePerson, estimatedMinutes: 5))
        }
        if low(.purpose) {
            out.append(.init(
                title: "Return to what matters",
                subtitle: "Five minutes to reflect, pray, or write the one thing that counts today.",
                pillar: .purpose, mode: .solo, estimatedMinutes: 5))
        }
        if low(.fuel) {
            out.append(.init(
                title: "Steady your fuel",
                subtitle: "A glass of water and some protein. Small inputs, steadier output.",
                pillar: .fuel, mode: .solo, estimatedMinutes: 5))
        }
        if low(.recover) {
            out.append(.init(
                title: "Let your system settle",
                subtitle: "A few minutes of breathwork or gentle mobility. Recovery is productive.",
                pillar: .recover, mode: .solo, estimatedMinutes: 10))
        }
        if low(.sleep) {
            out.append(.init(
                title: "Bank an hour of rest",
                subtitle: "Move bedtime forward tonight. Tomorrow is built the night before.",
                pillar: .sleep, mode: .solo, estimatedMinutes: 0))
        }
        if low(.body) {
            out.append(.init(
                title: "Move for twenty minutes",
                subtitle: "A walk is enough. Motion is the simplest medicine.",
                pillar: .body, mode: .solo, estimatedMinutes: 20))
        }
        if low(.mind) {
            out.append(.init(
                title: "Quiet the noise",
                subtitle: "One single-task block with no inputs. Give your attention a rest.",
                pillar: .mind, mode: .solo, estimatedMinutes: 15))
        }
        if low(.space) {
            out.append(.init(
                title: "Clear one surface",
                subtitle: "Bed, desk, or floor. Choose one and finish it.",
                pillar: .space, mode: .solo, estimatedMinutes: 10))
        }

        // 3. Maintenance fallback — when nothing is flagged low, support the pillars that
        //    need it most and protect what's working. Never an empty, anxious screen.
        if out.isEmpty {
            out.append(maintenance(for: result.weakestPillar))
            out.append(maintenance(for: result.secondWeakestPillar))
            out.append(.init(
                title: "Protect what's working",
                subtitle: "Name the pillar holding you steady today, and keep it that way.",
                pillar: result.strongestPillar, mode: .solo, estimatedMinutes: 3))
        }

        // De-duplicate by identity, keep order, cap at three.
        var seen = Set<String>()
        let unique = out.filter { seen.insert($0.id).inserted }
        return Array(unique.prefix(3))
    }

    /// A gentle "keep it steady" nudge for a pillar that isn't low.
    private static func maintenance(for pillar: PillarType) -> PillarRecommendation {
        switch pillar {
        case .body:
            return .init(title: "Keep moving", subtitle: "A short walk or some stretching to stay loose.", pillar: .body, mode: .solo, estimatedMinutes: 15)
        case .fuel:
            return .init(title: "Eat with intention", subtitle: "One real meal, unhurried. Notice how it lands.", pillar: .fuel, mode: .solo, estimatedMinutes: 20)
        case .sleep:
            return .init(title: "Guard your sleep", subtitle: "Hold a consistent bedtime tonight.", pillar: .sleep, mode: .solo, estimatedMinutes: 0)
        case .recover:
            return .init(title: "Take a real pause", subtitle: "Five slow breaths between the things you're doing.", pillar: .recover, mode: .solo, estimatedMinutes: 5)
        case .mind:
            return .init(title: "Make a little space", subtitle: "Step away from the screen for ten minutes.", pillar: .mind, mode: .solo, estimatedMinutes: 10)
        case .connect:
            return .init(title: "Send one kind word", subtitle: "A small message to someone you appreciate.", pillar: .connect, mode: .onePerson, estimatedMinutes: 5)
        case .space:
            return .init(title: "Tend your space", subtitle: "Reset one surface so the room feels lighter.", pillar: .space, mode: .solo, estimatedMinutes: 10)
        case .purpose:
            return .init(title: "Name what matters", subtitle: "Write the one thing that would make today count.", pillar: .purpose, mode: .solo, estimatedMinutes: 5)
        }
    }
}
