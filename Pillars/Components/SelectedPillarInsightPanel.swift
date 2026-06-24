import SwiftUI

/// The action surface beneath the Pillar Web: names the selected pillar and its state, gives
/// one calm line of insight, and offers a primary "Restore [Pillar]" action plus a detail link.
struct SelectedPillarInsightPanel: View {
    let score: PillarWebScore
    var onRestore: () -> Void
    var onDetail: () -> Void

    var body: some View {
        PillarGlassCard(highlight: score.state.isAskingForSupport) {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                HStack(spacing: PillarsSpacing.s) {
                    PillarIconBadge(pillar: score.pillar, size: 48)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(score.pillar.displayName)
                            .font(PillarsTypography.title)
                            .foregroundStyle(PillarsColors.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("\(score.state.displayName) · \(score.state.supportCopy)")
                            .font(PillarsTypography.callout.weight(.medium))
                            .foregroundStyle(score.state.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    Spacer(minLength: 0)
                }

                Text(score.pillar.insightCopy(for: score.state))
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: PillarsSpacing.s) {
                    Button(action: onRestore) {
                        Text("Restore \(score.pillar.displayName)")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(PillarsColors.gold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button(action: onDetail) {
                        Text("Detail")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                            .background(Capsule().fill(Color.white.opacity(0.05)))
                            .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }
}
