import Foundation

/// How much aggregate shape a Circle may reveal, scaled to its size. The single rule:
/// the smaller the Circle, the less it shows — because in a small group, even an "average"
/// can quietly expose an individual.
enum GroupWebMode: Equatable {
    /// 1–2 people: no aggregate of any kind. Wins and shared resets only.
    case hidden
    /// 3 people: one soft, blurred trend word. No web, no numbers.
    case blurredTrend
    /// 4+ people: a soft, haloed aggregate Group Web — quantized buckets only, never
    /// per-member, never a number, never a name.
    case aggregateWeb
}

/// The single authority on what a Circle may reveal. Every Circle view must route through
/// this engine before showing anything aggregate — there is no other path to member data.
///
/// Thresholds are sourced from `CirclePrivacyTier` so the size rules live in exactly one place.
enum PrivacyRulesEngine {

    /// The web mode for a Circle of `memberCount` people.
    static func groupWebMode(memberCount: Int) -> GroupWebMode {
        switch CirclePrivacyTier.tier(forMemberCount: memberCount) {
        case .duo:   return .hidden
        case .small: return .blurredTrend
        case .group: return .aggregateWeb
        }
    }

    /// True only when the Circle is large enough (4+) to show a soft aggregate web.
    static func canSeeAggregateWeb(memberCount: Int) -> Bool {
        groupWebMode(memberCount: memberCount) == .aggregateWeb
    }

    /// True once a Circle is large enough (3+) to surface a Group Morale read without an
    /// average pinning to one person. Below that, the hero shows only encouragement.
    static func canSeeMorale(memberCount: Int) -> Bool {
        memberCount >= 3
    }

    /// The pillars a single member has chosen to expose, honoring their visibility level.
    /// This is a *permission* filter only — it never widens past the size-based web rules.
    static func sharedPillars(for member: CircleMember) -> [PillarType] {
        switch member.visibilityLevel {
        case .privateLevel, .statusOnly:
            return []
        case .selectedPillars:
            return member.sharedPillars
        case .fullShared:
            return PillarType.allCases
        }
    }

    /// Whether a member's soft status (never a value) may be shown on their profile.
    static func showsStatus(for member: CircleMember) -> Bool {
        member.visibilityLevel != .privateLevel
    }
}
