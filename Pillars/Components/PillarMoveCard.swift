import SwiftUI

/// A premium action card for one of "Today's Moves".
///
/// Tinted pillar badge, a clear title and calm subtitle, a row of quiet metadata chips
/// (pillar · mode · minutes), and a gold completion control. Completing it dims and
/// strikes the card without removing it — progress you can see.
struct PillarMoveCard: View {
    let recommendation: PillarRecommendation
    var isCompleted: Bool
    var onToggle: () -> Void

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(alignment: .top, spacing: PillarsSpacing.m) {
                PillarIconBadge(pillar: recommendation.pillar, size: 50)

                VStack(alignment: .leading, spacing: 7) {
                    Text(recommendation.title)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                        .strikethrough(isCompleted, color: PillarsColors.tertiaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(recommendation.subtitle)
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1.5)

                    HStack(spacing: 6) {
                        MetaChip(text: recommendation.pillar.displayName, color: recommendation.pillar.color)
                        MetaChip(text: recommendation.mode.label)
                        if recommendation.estimatedMinutes > 0 {
                            MetaChip(text: "\(recommendation.estimatedMinutes) min")
                        }
                    }
                    .padding(.top, 3)
                }

                Spacer(minLength: 0)

                Button(action: onToggle) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundStyle(isCompleted ? PillarsColors.gold : PillarsColors.tertiaryText)
                        .symbolEffect(.bounce, value: isCompleted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isCompleted ? "Mark not done" : "Mark done")
            }
        }
        .opacity(isCompleted ? 0.66 : 1)
        .animation(.snappy(duration: 0.25), value: isCompleted)
    }
}
