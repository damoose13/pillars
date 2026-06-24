import XCTest
@testable import Pillars

/// The most important invariant in the app: a Circle never exposes an individual's scores.
/// These tests guard the privacy gating so a refactor can't quietly open a leak.
final class CirclePulsePrivacyTests: XCTestCase {

    private func member(_ name: String, all score: Int) -> CircleMember {
        CircleMember(
            name: name, bodyScore: score, fuelScore: score, sleepScore: score,
            recoverScore: score, mindScore: score, connectScore: score,
            spaceScore: score, purposeScore: score
        )
    }

    func testDuoTierExposesNoAggregate() {
        // 1–2 people: no shape, no trends — even an average could identify someone.
        let solo = CirclePulseEngine.pulse(members: [member("You", all: 1)], winsThisWeek: 0)
        XCTAssertEqual(solo.tier, .duo)
        XCTAssertTrue(solo.shape.isEmpty, "Solo Circle must expose no aggregate shape")
        XCTAssertTrue(solo.trends.isEmpty)

        let pair = CirclePulseEngine.pulse(
            members: [member("You", all: 1), member("A", all: 5)], winsThisWeek: 1)
        XCTAssertEqual(pair.tier, .duo)
        XCTAssertTrue(pair.shape.isEmpty, "Two-person Circle must expose no aggregate shape")
        XCTAssertTrue(pair.trends.isEmpty)
    }

    func testSmallTierShowsOneBlurredTrendAndBucketedShape() {
        let members = [member("You", all: 1), member("A", all: 1), member("B", all: 1)]
        let pulse = CirclePulseEngine.pulse(members: members, winsThisWeek: 1)
        XCTAssertEqual(pulse.tier, .small)
        XCTAssertEqual(pulse.trends.count, 1, "Small Circle shows exactly one vague trend")
        XCTAssertFalse(pulse.shape.isEmpty)
    }

    func testShapeIsQuantizedNeverRawScores() {
        // Members all at extreme 5; the blurred shape must never echo a raw 5 (or 1).
        let members = (0..<4).map { member("M\($0)", all: 5) }
        let pulse = CirclePulseEngine.pulse(members: members, winsThisWeek: 2)
        XCTAssertEqual(pulse.tier, .group)
        XCTAssertFalse(pulse.shape.isEmpty)
        for score in pulse.shape {
            XCTAssertTrue((2...4).contains(score.score),
                          "Aggregate shape must be bucketed to 2–4, never a raw score; got \(score.score)")
        }
    }

    func testTrendsCarryNoNumbers() {
        let members = (0..<5).map { member("M\($0)", all: 3) }
        let pulse = CirclePulseEngine.pulse(members: members, winsThisWeek: 1)
        for trend in pulse.trends {
            XCTAssertTrue(["Quiet", "Steady", "Firm"].contains(trend.label),
                          "Trend labels are vague words, never numbers; got \(trend.label)")
        }
    }
}
