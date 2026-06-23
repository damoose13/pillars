import Foundation
import SwiftData

/// A single day's check-in across all eight pillars.
///
/// Scores are stored as discrete `Int` columns (1–5) per pillar — flat and query-friendly
/// for SwiftData — with convenience accessors that bridge to `PillarType`.
@Model
final class DailyCheckIn {
    var date: Date
    var notes: String?

    var bodyScore: Int
    var fuelScore: Int
    var sleepScore: Int
    var recoverScore: Int
    var mindScore: Int
    var connectScore: Int
    var spaceScore: Int
    var purposeScore: Int

    init(
        date: Date = .now,
        notes: String? = nil,
        bodyScore: Int = 3,
        fuelScore: Int = 3,
        sleepScore: Int = 3,
        recoverScore: Int = 3,
        mindScore: Int = 3,
        connectScore: Int = 3,
        spaceScore: Int = 3,
        purposeScore: Int = 3
    ) {
        self.date = date
        self.notes = notes
        self.bodyScore = bodyScore
        self.fuelScore = fuelScore
        self.sleepScore = sleepScore
        self.recoverScore = recoverScore
        self.mindScore = mindScore
        self.connectScore = connectScore
        self.spaceScore = spaceScore
        self.purposeScore = purposeScore
    }
}

// MARK: - Pillar bridging & derived values

extension DailyCheckIn {

    /// Score (1–5) for a given pillar.
    func score(for pillar: PillarType) -> Int {
        switch pillar {
        case .body: return bodyScore
        case .fuel: return fuelScore
        case .sleep: return sleepScore
        case .recover: return recoverScore
        case .mind: return mindScore
        case .connect: return connectScore
        case .space: return spaceScore
        case .purpose: return purposeScore
        }
    }

    /// Sets a pillar score, clamped to 1...5.
    func setScore(_ value: Int, for pillar: PillarType) {
        let v = min(5, max(1, value))
        switch pillar {
        case .body: bodyScore = v
        case .fuel: fuelScore = v
        case .sleep: sleepScore = v
        case .recover: recoverScore = v
        case .mind: mindScore = v
        case .connect: connectScore = v
        case .space: spaceScore = v
        case .purpose: purposeScore = v
        }
    }

    /// All scores keyed by pillar.
    var scores: [PillarType: Int] {
        Dictionary(uniqueKeysWithValues: PillarType.allCases.map { ($0, score(for: $0)) })
    }

    /// Scores in canonical pillar order.
    var orderedScores: [(pillar: PillarType, score: Int)] {
        PillarType.allCases.map { (pillar: $0, score: score(for: $0)) }
    }

    /// Mean pillar score (1.0–5.0).
    var average: Double {
        let total = PillarType.allCases.reduce(0) { $0 + score(for: $1) }
        return Double(total) / Double(PillarType.allCases.count)
    }

    /// The day's system score on a 0–100 scale: `average / 5 * 100`.
    var systemScore: Int {
        Int((average / 5.0 * 100).rounded())
    }
}
