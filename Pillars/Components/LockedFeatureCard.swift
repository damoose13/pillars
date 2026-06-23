import SwiftUI

/// A graceful gate shown in place of premium content. Never nags — explains the value and
/// offers one calm way to unlock.
struct LockedFeatureCard: View {
    let feature: Feature
    var onUnlock: () -> Void

    var body: some View {
        PillarGlassCard(highlight: true) {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                HStack(spacing: PillarsSpacing.s) {
                    ZStack {
                        Circle().fill(PillarsColors.gold.opacity(0.14))
                        Image(systemName: feature.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(PillarsColors.gold)
                    }
                    .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Label(feature.requiredTier.displayName, systemImage: "lock.fill")
                            .pillarsOverline(PillarsColors.gold.opacity(0.9))
                        Text(feature.title)
                            .font(PillarsTypography.titleSmall)
                            .foregroundStyle(PillarsColors.primaryText)
                    }
                    Spacer(minLength: 0)
                }

                Text(feature.blurb)
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(1.5)

                Button(action: onUnlock) {
                    HStack(spacing: 6) {
                        Text("Unlock \(feature.requiredTier.displayName)")
                        Image(systemName: "arrow.right")
                    }
                    .font(PillarsTypography.callout.weight(.semibold))
                    .foregroundStyle(PillarsColors.background)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(Capsule().fill(PillarsColors.gold))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}
