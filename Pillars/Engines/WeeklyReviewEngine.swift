import Foundation

/// A calm, rule-based summary of the past week of check-ins. No diagnoses, no charts —
/// just the few things worth noticing and one focus for the week ahead.
struct WeeklyReview {
    let checkInCount: Int
    /// 0–100, averaged across the window.
    let averageSystemScore: Int
    /// Change from the first to the last check-in in the window, in points.
    let systemTrend: Int
    let averagePillarScores: [PillarType: Double]
    let weakestPillar: PillarType
    let strongestPillar: PillarType
    /// The pillar that rose most across the window, if any movement was meaningful.
    let mostImprovedPillar: PillarType?
    /// Where attention pays off most next week.
    let focusPillar: PillarType
    /// One plain-language pattern, surfaced by simple rules.
    let hiddenPattern: String
    /// Up to three suggested actions for the week ahead.
    let recommendations: [PillarRecommendation]

    func average(for pillar: PillarType) -> Double { averagePillarScores[pillar] ?? 3 }
}

/// Pure weekly-review logic over a history of check-ins.
enum WeeklyReviewEngine {

    /// Builds a review from the most recent `window` check-ins (default 7). Returns `nil`
    /// when there isn't enough history yet.
    static func review(from checkIns: [DailyCheckIn], window: Int = 7) -> WeeklyReview? {
        let sorted = checkIns.sorted { $0.date < $1.date } // oldest → newest
        let recent = Array(sorted.suffix(window))
        guard recent.count >= 2 else { return nil }

        // Average per pillar.
        var averages: [PillarType: Double] = [:]
        for pillar in PillarType.allCases {
            let total = recent.reduce(0) { $0 + $1.score(for: pillar) }
            averages[pillar] = Double(total) / Double(recent.count)
        }

        func avg(_ pillar: PillarType) -> Double { averages[pillar] ?? 3 }
        let canonical: (PillarType) -> Int = { PillarType.allCases.firstIndex(of: $0) ?? 0 }

        let weakest = PillarType.allCases.min {
            avg($0) != avg($1) ? avg($0) < avg($1) : canonical($0) < canonical($1)
        } ?? .body
        let strongest = PillarType.allCases.max {
            avg($0) != avg($1) ? avg($0) < avg($1) : canonical($0) > canonical($1)
        } ?? .purpose

        // Average system score across the window.
        let avgSystem = recent.reduce(0) { $0 + $1.systemScore } / recent.count
        let systemTrend = (recent.last?.systemScore ?? 0) - (recent.first?.systemScore ?? 0)

        // Most improved: earlier half vs later half.
        let mostImproved = mostImprovedPillar(in: recent)

        let focus = weakest
        let pattern = hiddenPattern(
            averages: averages, weakest: weakest, strongest: strongest, mostImproved: mostImproved
        )

        // Suggested actions: feed the averaged scores through the existing engine.
        let synthetic = DailyCheckIn()
        for pillar in PillarType.allCases {
            synthetic.setScore(Int(avg(pillar).rounded()), for: pillar)
        }
        let result = PillarScoringEngine.result(for: synthetic)
        let recommendations = RecommendationEngine.recommendations(for: result)

        return WeeklyReview(
            checkInCount: recent.count,
            averageSystemScore: avgSystem,
            systemTrend: systemTrend,
            averagePillarScores: averages,
            weakestPillar: weakest,
            strongestPillar: strongest,
            mostImprovedPillar: mostImproved,
            focusPillar: focus,
            hiddenPattern: pattern,
            recommendations: recommendations
        )
    }

    // MARK: Helpers

    private static func mostImprovedPillar(in recent: [DailyCheckIn]) -> PillarType? {
        guard recent.count >= 2 else { return nil }
        let mid = recent.count / 2
        guard mid >= 1 else { return nil }
        let early = Array(recent[0..<mid])
        let late = Array(recent[mid...])

        func mean(_ pillar: PillarType, _ slice: [DailyCheckIn]) -> Double {
            guard !slice.isEmpty else { return 0 }
            return Double(slice.reduce(0) { $0 + $1.score(for: pillar) }) / Double(slice.count)
        }

        var best: PillarType?
        var bestDelta = 0.25 // require a meaningful rise
        for pillar in PillarType.allCases {
            let delta = mean(pillar, late) - mean(pillar, early)
            if delta > bestDelta {
                bestDelta = delta
                best = pillar
            }
        }
        return best
    }

    private static func hiddenPattern(
        averages: [PillarType: Double],
        weakest: PillarType,
        strongest: PillarType,
        mostImproved: PillarType?
    ) -> String {
        func avg(_ pillar: PillarType) -> Double { averages[pillar] ?? 3 }
        let low = 2.5

        if avg(.sleep) < low && avg(.mind) < low {
            return "When your Sleep dips, your Mind tends to follow. Rest is the lever this week."
        }
        if avg(.space) < low && avg(.mind) < low {
            return "A noisy space and a busy mind have been moving together. Clear one to settle the other."
        }
        if avg(.body) < low && avg(.connect) < low {
            return "Movement and connection have both been quiet. A walk with someone covers both."
        }
        if avg(.connect) < low {
            return "Connection has been quiet this week. A single honest message can shift it."
        }
        if avg(.purpose) < low {
            return "Purpose has felt faint lately. A few minutes on what matters goes a long way."
        }
        if let improved = mostImproved {
            return "\(improved.displayName) is already turning a corner — keep the momentum."
        }
        return "Your steadiest days came when \(strongest.displayName) led. Lean on it."
    }
}
