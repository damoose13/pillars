import XCTest
@testable import Pillars

/// The scoring engine turns check-ins into the system score and the pillars at the extremes —
/// the data the whole Pillar Web reads from.
final class PillarScoringEngineTests: XCTestCase {

    func testEmptyHistoryReturnsNil() {
        XCTAssertNil(PillarScoringEngine.result(from: []))
    }

    func testWeakestAndStrongestPillars() throws {
        let checkIn = DailyCheckIn(
            bodyScore: 5, fuelScore: 4, sleepScore: 4, recoverScore: 4,
            mindScore: 4, connectScore: 1, spaceScore: 4, purposeScore: 4
        )
        let result = try XCTUnwrap(PillarScoringEngine.result(from: [checkIn]))
        XCTAssertEqual(result.weakestPillar, .connect, "Connect (score 1) is the weakest")
        XCTAssertEqual(result.strongestPillar, .body, "Body (score 5) is the strongest")
        XCTAssertEqual(result.score(for: .connect), 1)
    }

    func testSystemScoreIsZeroToOneHundred() throws {
        let allFives = DailyCheckIn(
            bodyScore: 5, fuelScore: 5, sleepScore: 5, recoverScore: 5,
            mindScore: 5, connectScore: 5, spaceScore: 5, purposeScore: 5
        )
        let result = try XCTUnwrap(PillarScoringEngine.result(from: [allFives]))
        XCTAssertEqual(result.systemScore, 100, "All fives is a full system")

        let allOnes = DailyCheckIn(
            bodyScore: 1, fuelScore: 1, sleepScore: 1, recoverScore: 1,
            mindScore: 1, connectScore: 1, spaceScore: 1, purposeScore: 1
        )
        let low = try XCTUnwrap(PillarScoringEngine.result(from: [allOnes]))
        XCTAssertGreaterThanOrEqual(low.systemScore, 0)
        XCTAssertLessThan(low.systemScore, allFives.systemScore)
    }

    func testSecondWeakestDiffersFromWeakest() throws {
        let checkIn = DailyCheckIn(
            bodyScore: 5, fuelScore: 4, sleepScore: 4, recoverScore: 4,
            mindScore: 3, connectScore: 1, spaceScore: 2, purposeScore: 4
        )
        let result = try XCTUnwrap(PillarScoringEngine.result(from: [checkIn]))
        XCTAssertEqual(result.weakestPillar, .connect)
        XCTAssertNotEqual(result.secondWeakestPillar, result.weakestPillar)
        XCTAssertEqual(result.secondWeakestPillar, .space, "Space (2) is second weakest")
    }
}
