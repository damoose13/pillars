import Foundation

/// A data-driven weekly pattern: which two pillars actually *moved together* across the week.
/// Where `WeeklyReviewEngine`'s fallback leans on fixed thresholds ("both averaged low"), this
/// reads the day-by-day co-movement in the real check-ins — so the pattern is earned, not assumed.
struct WeeklyPatternInsight {
    /// The pillar to lead with — the lower-averaging of the pair, i.e. the lever.
    let primary: PillarType
    let secondary: PillarType
    let text: String
}

enum WeeklyInsightEngine {

    /// The strongest genuine pillar pairing in the window, if there's enough signal. A pair
    /// "moves together" when, day over day, both sit on the same side of their own average.
    static func pattern(from recent: [DailyCheckIn]) -> WeeklyPatternInsight? {
        guard recent.count >= 3 else { return nil }

        var mean: [PillarType: Double] = [:]
        for pillar in PillarType.allCases {
            mean[pillar] = Double(recent.reduce(0) { $0 + $1.score(for: pillar) }) / Double(recent.count)
        }

        // Concordance over the window: +1 when both pillars are on the same side of their mean
        // on a given day, -1 when opposite. Days where either sits exactly at its mean carry no
        // signal. Normalised by the number of days.
        func comovement(_ a: PillarType, _ b: PillarType) -> Double {
            var score = 0
            for day in recent {
                let da = Double(day.score(for: a)) - (mean[a] ?? 3)
                let db = Double(day.score(for: b)) - (mean[b] ?? 3)
                if da == 0 || db == 0 { continue }
                score += (da > 0) == (db > 0) ? 1 : -1
            }
            return Double(score) / Double(recent.count)
        }

        let pillars = PillarType.allCases
        var best: (a: PillarType, b: PillarType, strength: Double)?
        for i in pillars.indices {
            for j in pillars.indices where j > i {
                let strength = comovement(pillars[i], pillars[j])
                guard strength >= 0.5 else { continue }   // mostly concordant only
                if best == nil || strength > best!.strength {
                    best = (pillars[i], pillars[j], strength)
                }
            }
        }

        guard let best else { return nil }
        // Lead with whichever pillar is lower on average — that's where support pays off.
        let primary = (mean[best.a] ?? 3) <= (mean[best.b] ?? 3) ? best.a : best.b
        let secondary = primary == best.a ? best.b : best.a
        return WeeklyPatternInsight(
            primary: primary,
            secondary: secondary,
            text: "This week your \(primary.displayName) and \(secondary.displayName) moved together — when one dipped, the other tended to follow. Supporting \(primary.displayName) may lift both."
        )
    }
}
