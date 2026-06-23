import SwiftUI

/// Editorial header for the Today dashboard: a tracked date overline, a large serif
/// title, and one calm, intelligent line of microcopy derived from the day's result.
struct TodayFoundationHeader: View {
    let result: PillarScoreResult
    var date: Date = .now
    /// Whether the underlying check-in is from today (vs. the most recent prior day).
    var isToday: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text(isToday ? dateString : "LAST CHECK-IN")
                .pillarsOverline(PillarsColors.gold.opacity(0.9))

            Text(isToday ? "Today's Foundation" : "Where you left off")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(summary)
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dateString: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased()
    }

    /// A single, non-judgemental read of the day. Leads with the pillar asking for support.
    private var summary: String {
        let weak = result.weakestPillar.displayName
        let strong = result.strongestPillar.displayName
        let weakState = PillarState.from(score: result.score(for: result.weakestPillar))
        switch result.systemScore {
        case 80...:
            return "Your system is firm today. \(strong) is carrying you — let \(weak) catch up gently."
        case 60..<80:
            return "You're steady. \(weak) is \(weakState.label.lowercased()); \(strong) is holding firm."
        case 40..<60:
            return "A mixed day. Lead with \(weak) — small support there will lift the whole system."
        default:
            return "A heavy day. You don't need to fix everything. Start with \(weak), and let the rest follow."
        }
    }
}
