import XCTest
@testable import Pillars

/// The 5-state system and the restoration engine — the qualitative language and the moves the
/// app leads with.
final class PillarStateAndRestorationTests: XCTestCase {

    func testStateMapping() {
        XCTAssertEqual(PillarState.from(score: 1), .drained)
        XCTAssertEqual(PillarState.from(score: 2), .quiet)
        XCTAssertEqual(PillarState.from(score: 3), .steady)
        XCTAssertEqual(PillarState.from(score: 4), .strong)
        XCTAssertEqual(PillarState.from(score: 5), .full)
    }

    func testStateClampsOutOfRange() {
        XCTAssertEqual(PillarState.from(score: 0), .drained)
        XCTAssertEqual(PillarState.from(score: 99), .full)
    }

    func testOnlyLowStatesAskForSupport() {
        XCTAssertTrue(PillarState.drained.isAskingForSupport)
        XCTAssertTrue(PillarState.quiet.isAskingForSupport)
        XCTAssertFalse(PillarState.steady.isAskingForSupport)
        XCTAssertFalse(PillarState.strong.isAskingForSupport)
        XCTAssertFalse(PillarState.full.isAskingForSupport)
    }

    func testRestorationsLeadWithTheWeakestPillar() throws {
        let checkIn = DailyCheckIn(
            bodyScore: 5, fuelScore: 5, sleepScore: 5, recoverScore: 5,
            mindScore: 5, connectScore: 1, spaceScore: 5, purposeScore: 5
        )
        let result = try XCTUnwrap(PillarScoringEngine.result(from: [checkIn]))
        let recs = RestorationEngine.restorations(for: result)
        XCTAssertFalse(recs.isEmpty, "There should always be at least one restoration")
        XCTAssertTrue(recs.contains { $0.pillar == result.weakestPillar },
                      "Restorations must address the weakest pillar")
    }

    func testRestorationsAreSecularByDefault() throws {
        // Default content preferences are secular; no recommendation should be a spiritual one.
        ContentPreferences.shared.spiritualRitualsEnabled = false
        let checkIn = DailyCheckIn(
            bodyScore: 4, fuelScore: 4, sleepScore: 4, recoverScore: 4,
            mindScore: 4, connectScore: 4, spaceScore: 4, purposeScore: 1
        )
        let result = try XCTUnwrap(PillarScoringEngine.result(from: [checkIn]))
        let recs = RestorationEngine.restorations(for: result)
        let text = recs.map { "\($0.title) \($0.subtitle)" }.joined(separator: " ").lowercased()
        for word in ["temple", "prayer", "seva", "scripture", "worship"] {
            XCTAssertFalse(text.contains(word),
                           "Secular default must not surface spiritual content; found '\(word)'")
        }
    }
}
