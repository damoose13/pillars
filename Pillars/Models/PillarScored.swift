import Foundation

/// Anything that can yield a 1–5 score per pillar. Lets `CirclePulseEngine` treat the
/// user's real check-in and mock circle members uniformly — and, crucially, only ever in
/// aggregate.
protocol PillarScored {
    func score(for pillar: PillarType) -> Int
}

extension DailyCheckIn: PillarScored {}   // already provides `score(for:)`
extension CircleMember: PillarScored {}   // provides `score(for:)` in its own file
