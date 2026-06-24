import SwiftUI

/// The morale hero — the emotional center of Circle mode. It shows the Circle's overall
/// morale (a single warm word), a soft Group Web when the Circle is large enough, and a
/// gentle dimension gap. Everything it shows is scaled to size: the smaller the Circle, the
/// less it reveals. No scores, no names, no numbers, no ranking.
struct CircleMoraleView: View {
    let aggregate: CircleAggregate

    var body: some View {
        PillarGlassCard(highlight: true) {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Label { Text("Circle morale") } icon: { Image(systemName: "person.3.sequence.fill") }
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))

                if aggregate.isAlone {
                    aloneContent
                } else if !aggregate.showsMorale {
                    duoContent
                } else {
                    moraleContent
                }
            }
        }
    }

    // MARK: Alone (≤1)

    private var aloneContent: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("Your Circle is just you, for now.")
                .font(PillarsTypography.title)
                .foregroundStyle(PillarsColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            Text("Invite someone you trust. The shape of your Circle appears once a few of you are in — and even then, never anyone's individual scores.")
                .font(PillarsTypography.callout)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Duo (2) — too small for any aggregate

    private var duoContent: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("Just the two of you.")
                .font(PillarsTypography.title)
                .foregroundStyle(PillarsColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            Text("In a Circle this small, even an average could reveal too much — so Pillars keeps morale private. Share a win or start a reset to support each other.")
                .font(PillarsTypography.callout)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            privacyLine
        }
    }

    // MARK: Morale (3+)

    private var moraleContent: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            HStack(alignment: .firstTextBaseline, spacing: PillarsSpacing.s) {
                Text(aggregate.morale.title)
                    .font(PillarsFont.serif(34, .semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                Image(systemName: aggregate.morale.symbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(aggregate.morale.color)
                Spacer(minLength: 0)
            }

            Text(aggregate.morale.description)
                .font(PillarsTypography.callout)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            if !aggregate.webScores.isEmpty {
                GroupPillarWebView(scores: aggregate.webScores, morale: aggregate.morale)
                    .frame(height: 188)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PillarsSpacing.xs)
            }

            if let gap = aggregate.gap {
                gapLine(gap)
            }

            if let trend = aggregate.blurredTrend {
                trendChip(trend)
            }

            privacyLine
        }
    }

    // MARK: Pieces

    private func gapLine(_ gap: CircleDimensionGap) -> some View {
        (
            Text(gap.softest.displayName).foregroundColor(gap.softest.color)
            + Text(" could use the Circle's support · ").foregroundColor(PillarsColors.secondaryText)
            + Text(gap.firmest.displayName).foregroundColor(gap.firmest.color)
            + Text(" is holding firm").foregroundColor(PillarsColors.secondaryText)
        )
        .font(PillarsTypography.caption.weight(.semibold))
        .fixedSize(horizontal: false, vertical: true)
    }

    private func trendChip(_ trend: CirclePillarTrend) -> some View {
        HStack(spacing: 8) {
            Circle().fill(trend.pillar.color).frame(width: 8, height: 8)
            Text(trend.pillar.displayName)
                .font(PillarsTypography.caption.weight(.semibold))
                .foregroundStyle(PillarsColors.primaryText)
            Text(trend.label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(PillarsColors.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Capsule().fill(Color.white.opacity(0.05)))
        .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
    }

    private var privacyLine: some View {
        Label {
            Text(CirclePrivacyTier.tier(forMemberCount: aggregate.memberCount).shortExplainer)
        } icon: {
            Image(systemName: "lock.fill")
        }
        .font(PillarsTypography.caption)
        .foregroundStyle(PillarsColors.secondaryText)
        .padding(.top, PillarsSpacing.xxs)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        CircleMoraleView(aggregate: CircleMoraleEngine.aggregate(
            members: (0..<5).map { CircleMember.mock(name: CircleMember.sampleRoster[$0], colorIndex: $0) }
        ))
        .padding()
    }
    .pillarsBackground()
    .preferredColorScheme(.dark)
}
#endif
