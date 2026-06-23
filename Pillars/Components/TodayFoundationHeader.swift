import SwiftUI

/// Editorial header for the Today dashboard: a tracked date overline, a large serif
/// title, and one calm, intelligent line of microcopy derived from the day's result.
struct TodayFoundationHeader: View {
    let result: PillarScoreResult
    var date: Date = .now

    var body: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text(dateString)
                .pillarsOverline(PillarsColors.gold.opacity(0.9))

            Text("Today's Foundation")
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

    /// A single, non-judgemental read of the day. Leads with the pillar that needs support.
    private var summary: String {
        let weak = result.weakestPillar.displayName
        let strong = result.strongestPillar.displayName
        switch result.systemScore {
        case 80...:
            return "Your system is strong today. \(strong) is carrying you — let \(weak) catch up gently."
        case 60..<80:
            return "You're steady. \(weak) is the pillar asking for attention; \(strong) is holding firm."
        case 40..<60:
            return "A mixed day. Lead with \(weak) — small support there will lift the whole system."
        default:
            return "A heavy day. You don't need to fix everything. Start with \(weak), and let the rest follow."
        }
    }
}
