import Foundation

/// The computed picture of a day: system score, the pillars at the extremes, and trends
/// versus the previous check-in.
struct PillarScoreResult {
    /// 0–100.
    let systemScore: Int
    /// Each pillar's 1–5 score.
    let pillarScores: [PillarType: Int]
    let weakestPillar: PillarType
    let secondWeakestPillar: PillarType
    let strongestPillar: PillarType
    /// Change in system score vs the previous check-in, in points (0 if none).
    let systemTrend: Int
    /// Per-pillar change vs the previous check-in, in score points.
    let pillarTrends: [PillarType: Int]

    func score(for pillar: PillarType) -> Int { pillarScores[pillar] ?? 3 }
    func trend(for pillar: PillarType) -> Int { pillarTrends[pillar] ?? 0 }

    /// Pillars ordered weakest → strongest (ties broken by canonical order).
    var pillarsByNeed: [PillarType] {
        PillarType.allCases.sorted { a, b in
            let sa = score(for: a), sb = score(for: b)
            if sa != sb { return sa < sb }
            return indexOf(a) < indexOf(b)
        }
    }

    private func indexOf(_ p: PillarType) -> Int {
        PillarType.allCases.firstIndex(of: p) ?? 0
    }
}

/// Pure scoring logic. No SwiftUI, no persistence — trivially testable.
enum PillarScoringEngine {

    /// Builds a result from a check-in and an optional previous one (for trends).
    static func result(for checkIn: DailyCheckIn, previous: DailyCheckIn? = nil) -> PillarScoreResult {
        let scores = checkIn.scores

        // Weakest first, ties broken by canonical pillar order for stability.
        let ranked = PillarType.allCases.sorted { a, b in
            let sa = scores[a] ?? 3, sb = scores[b] ?? 3
            if sa != sb { return sa < sb }
            let ia = PillarType.allCases.firstIndex(of: a) ?? 0
            let ib = PillarType.allCases.firstIndex(of: b) ?? 0
            return ia < ib
        }

        let weakest = ranked.first ?? .body
        let secondWeakest = ranked.count > 1 ? ranked[1] : weakest
        let strongest = ranked.last ?? .purpose

        var pillarTrends: [PillarType: Int] = [:]
        if let previous {
            for pillar in PillarType.allCases {
                pillarTrends[pillar] = checkIn.score(for: pillar) - previous.score(for: pillar)
            }
        } else {
            for pillar in PillarType.allCases { pillarTrends[pillar] = 0 }
        }

        let systemTrend = previous.map { checkIn.systemScore - $0.systemScore } ?? 0

        return PillarScoreResult(
            systemScore: checkIn.systemScore,
            pillarScores: scores,
            weakestPillar: weakest,
            secondWeakestPillar: secondWeakest,
            strongestPillar: strongest,
            systemTrend: systemTrend,
            pillarTrends: pillarTrends
        )
    }

    /// Builds a result from a history (newest first or unsorted), using the latest
    /// check-in as "today" and the one before it for trends.
    static func result(from checkIns: [DailyCheckIn]) -> PillarScoreResult? {
        let sorted = checkIns.sorted { $0.date > $1.date }
        guard let latest = sorted.first else { return nil }
        let previous = sorted.count > 1 ? sorted[1] : nil
        return result(for: latest, previous: previous)
    }
}
