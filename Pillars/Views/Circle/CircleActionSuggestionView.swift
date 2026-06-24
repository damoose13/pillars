import SwiftUI

/// A suggested shared action ("group reset"). Tapping **Start reset** opens the shared-reset
/// flow — choose, invite, show up — with no scores and no pressure.
struct CircleActionSuggestionView: View {
    let action: CircleAction
    var onStart: () -> Void = {}

    private var accent: Color { action.pillar?.color ?? PillarsColors.gold }

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(alignment: .top, spacing: PillarsSpacing.m) {
                ZStack {
                    Circle().fill(accent.opacity(0.16))
                    Circle().strokeBorder(accent.opacity(0.35), lineWidth: 1)
                    Image(systemName: action.pillar?.icon ?? "sparkles")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(accent)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 6) {
                    Text(action.title)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(action.subtitle)
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1.5)

                    HStack(spacing: 6) {
                        MetaChip(text: action.mode.label, color: accent)
                        if let pillar = action.pillar {
                            MetaChip(text: pillar.displayName)
                        }
                    }
                    .padding(.top, 3)
                }

                Spacer(minLength: 0)

                Button(action: onStart) {
                    Text("Start reset")
                        .font(PillarsTypography.caption.weight(.semibold))
                        .foregroundStyle(PillarsColors.background)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(PillarsColors.gold))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}
