import Foundation
import SwiftData

/// A member of a Circle. **Mock/local only** in v0.2 — there is no auth or backend yet, so
/// "members" are fabricated on-device to exercise the privacy-safe pulse logic.
///
/// The per-pillar scores below are a private signal used **exclusively** by
/// `CirclePulseEngine` to compute aggregate, blurred outputs. They are never displayed
/// individually anywhere in the Circle UI — that's the core privacy guarantee.
@Model
final class CircleMember {
    var name: String
    var colorIndex: Int
    var joinedAt: Date
    /// The current user's own membership slot (its signal is synced from real check-ins).
    var isYou: Bool

    var bodyScore: Int
    var fuelScore: Int
    var sleepScore: Int
    var recoverScore: Int
    var mindScore: Int
    var connectScore: Int
    var spaceScore: Int
    var purposeScore: Int

    init(
        name: String,
        colorIndex: Int = 0,
        isYou: Bool = false,
        joinedAt: Date = .now,
        bodyScore: Int = 3,
        fuelScore: Int = 3,
        sleepScore: Int = 3,
        recoverScore: Int = 3,
        mindScore: Int = 3,
        connectScore: Int = 3,
        spaceScore: Int = 3,
        purposeScore: Int = 3
    ) {
        self.name = name
        self.colorIndex = colorIndex
        self.isYou = isYou
        self.joinedAt = joinedAt
        self.bodyScore = bodyScore
        self.fuelScore = fuelScore
        self.sleepScore = sleepScore
        self.recoverScore = recoverScore
        self.mindScore = mindScore
        self.connectScore = connectScore
        self.spaceScore = spaceScore
        self.purposeScore = purposeScore
    }

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
}

extension CircleMember {
    /// Candidate names used when inviting mock members during development.
    static let sampleRoster = ["Maya", "Theo", "Aria", "Noah", "Priya", "Liam", "Sofia", "Ezra"]

    /// A plausible mock member with slightly varied scores.
    static func mock(name: String, colorIndex: Int) -> CircleMember {
        let member = CircleMember(name: name, colorIndex: colorIndex)
        for pillar in PillarType.allCases {
            member.setScore(Int.random(in: 2...5), for: pillar)
        }
        return member
    }
}
