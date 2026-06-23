import Foundation

/// The monetization tiers. `plus` deepens the personal app; `circlePass` unlocks the
/// Circle layer. They are not strictly nested — a user may hold either, both, or neither.
enum SubscriptionTier: String, CaseIterable, Codable, Comparable {
    case free
    case plus
    case circlePass

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .plus: return "Pillars Plus"
        case .circlePass: return "Circle Pass"
        }
    }

    var rank: Int {
        switch self {
        case .free: return 0
        case .plus: return 1
        case .circlePass: return 2
        }
    }

    static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool { lhs.rank < rhs.rank }
}

/// A capability that may be gated behind a tier. `isEntitled` lives on `EntitlementManager`.
enum Feature: CaseIterable {
    case fullHistory
    case weeklyReview
    case advancedInsights
    case circlePulse
    case multipleCircles
    case circleWeeklyReport

    /// Holding any one of these tiers unlocks the feature.
    var requiredTiers: Set<SubscriptionTier> {
        switch self {
        case .fullHistory, .weeklyReview, .advancedInsights:
            return [.plus]
        case .circlePulse, .multipleCircles, .circleWeeklyReport:
            return [.circlePass]
        }
    }

    var requiredTier: SubscriptionTier { requiredTiers.contains(.circlePass) ? .circlePass : .plus }

    var title: String {
        switch self {
        case .fullHistory: return "Your full history"
        case .weeklyReview: return "Weekly Review"
        case .advancedInsights: return "Advanced insights"
        case .circlePulse: return "Circle Pulse"
        case .multipleCircles: return "Multiple Circles"
        case .circleWeeklyReport: return "Circle weekly report"
        }
    }

    var blurb: String {
        switch self {
        case .fullHistory: return "See every check-in, not just the last seven days."
        case .weeklyReview: return "A calm weekly read of your pillars, patterns, and focus."
        case .advancedInsights: return "Deeper recommendations and monthly trends."
        case .circlePulse: return "Privacy-safe signals and shared resets for your Circle."
        case .multipleCircles: return "Keep separate Circles for family, friends, and more."
        case .circleWeeklyReport: return "A gentle weekly digest for the whole Circle."
        }
    }

    var icon: String {
        switch self {
        case .fullHistory: return "clock.arrow.circlepath"
        case .weeklyReview: return "chart.line.uptrend.xyaxis"
        case .advancedInsights: return "sparkles"
        case .circlePulse: return "waveform.path.ecg"
        case .multipleCircles: return "person.3.sequence.fill"
        case .circleWeeklyReport: return "doc.text"
        }
    }
}

/// StoreKit product identifiers and their mapping to tiers. No real products are configured
/// yet — these power both a future App Store Connect setup and the local mock catalog.
enum ProductCatalog {
    static let plusMonthly = "pillars.plus.monthly"
    static let plusYearly = "pillars.plus.yearly"
    static let circleMonthly = "pillars.circle.monthly"
    static let circleYearly = "pillars.circle.yearly"

    static let allIDs: [String] = [plusMonthly, plusYearly, circleMonthly, circleYearly]

    static func tier(for productID: String) -> SubscriptionTier? {
        if productID.hasPrefix("pillars.plus") { return .plus }
        if productID.hasPrefix("pillars.circle") { return .circlePass }
        return nil
    }

    /// Display-only product used when StoreKit returns no real products (development mock).
    struct MockProduct: Identifiable, Hashable {
        let id: String
        let tier: SubscriptionTier
        let displayPrice: String
        let period: String
        var isYearly: Bool
    }

    static let mock: [MockProduct] = [
        MockProduct(id: plusMonthly, tier: .plus, displayPrice: "$4.99", period: "month", isYearly: false),
        MockProduct(id: plusYearly, tier: .plus, displayPrice: "$39.99", period: "year", isYearly: true),
        MockProduct(id: circleMonthly, tier: .circlePass, displayPrice: "$6.99", period: "month", isYearly: false),
        MockProduct(id: circleYearly, tier: .circlePass, displayPrice: "$59.99", period: "year", isYearly: true)
    ]

    static func mockProducts(for tier: SubscriptionTier) -> [MockProduct] {
        mock.filter { $0.tier == tier }
    }
}
