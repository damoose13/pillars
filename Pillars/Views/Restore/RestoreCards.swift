import SwiftUI

/// A compact ritual card for the Restore sections (Recommended · Saved).
struct RestoreRitualCard: View {
    let ritual: Ritual
    var recommended: Bool = false

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m, highlight: recommended) {
            HStack(spacing: PillarsSpacing.m) {
                PillarIconBadge(pillar: ritual.pillar, size: 46)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(ritual.name)
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        if recommended {
                            Text("Recommended")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(PillarsColors.background)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(PillarsColors.gold))
                        }
                    }
                    Text(ritual.summary)
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        MetaChip(text: ritual.pillar.displayName, color: ritual.pillar.color)
                        if ritual.estimatedMinutes > 0 { MetaChip(text: "\(ritual.estimatedMinutes) min") }
                    }
                    .padding(.top, 1)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
        }
    }
}

/// One recently-completed restoration row.
struct CompletedRestorationRow: View {
    let action: PillarAction

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.m) {
                PillarIconBadge(pillar: action.pillar, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(action.title)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                }
                Spacer(minLength: 0)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(PillarsColors.gold)
            }
        }
    }

    private var subtitle: String {
        let when = (action.completedAt ?? action.createdAt).formatted(.relative(presentation: .named))
        if let helped = action.helped, !helped.isEmpty { return "\(when) · \(helped)" }
        return when
    }
}

/// A calm empty-state card for a Restore section.
struct RestoreEmptyCard: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        PillarGlassCard {
            VStack(spacing: PillarsSpacing.s) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(PillarsColors.gold)
                Text(title)
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                Text(message)
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
