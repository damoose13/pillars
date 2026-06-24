import SwiftUI

/// The Circle Pulse card — the emotional center of Circle mode. One supportive headline,
/// optional blurred trend chips (tier-gated), and a quiet privacy reassurance. Never a
/// number, never an individual.
struct CirclePulseView: View {
    let pulse: CirclePulse

    var body: some View {
        PillarGlassCard(highlight: true) {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Label { Text("Circle Pulse") } icon: { Image(systemName: "waveform.path.ecg") }
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))

                Text(pulse.headline)
                    .font(PillarsTypography.title)
                    .foregroundStyle(PillarsColors.primaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                if !pulse.shape.isEmpty {
                    DynamicPillarWebView(scores: pulse.shape, mode: .blurred)
                        .frame(height: 168)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PillarsSpacing.xs)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("A soft, blurred picture of the Circle's overall shape. No individual scores.")
                }

                if !pulse.trends.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(pulse.trends) { trend in
                            CircleTrendChip(trend: trend)
                        }
                    }
                    .padding(.top, 2)
                }

                Label {
                    Text(pulse.tier.shortExplainer)
                } icon: {
                    Image(systemName: "lock.fill")
                }
                .font(PillarsTypography.caption)
                .foregroundStyle(PillarsColors.secondaryText)
                .padding(.top, PillarsSpacing.xxs)
            }
        }
    }
}

/// A blurred-trend chip: pillar identity + a vague word. Deliberately carries no value.
private struct CircleTrendChip: View {
    let trend: CirclePillarTrend

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(trend.pillar.color).frame(width: 8, height: 8)
            Text(trend.pillar.displayName)
                .font(PillarsTypography.caption.weight(.semibold))
                .foregroundStyle(PillarsColors.primaryText)
            Spacer(minLength: 4)
            Text(trend.label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(PillarsColors.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Capsule().fill(Color.white.opacity(0.05)))
        .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
    }
}
