import SwiftUI

/// A suggested shared action ("group reset"). Tapping **Nudge** sends a playful, local-only
/// ping to the Circle — no scores, no pressure. Real delivery arrives with the backend.
struct CircleActionSuggestionView: View {
    let action: CircleAction
    var onNudge: () -> Void = {}

    @State private var nudged = false

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

                Button {
                    withAnimation(.snappy) { nudged = true }
                    onNudge()
                } label: {
                    Text(nudged ? "Nudged" : "Nudge")
                        .font(PillarsTypography.caption.weight(.semibold))
                        .foregroundStyle(nudged ? PillarsColors.tertiaryText : PillarsColors.background)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(nudged ? Color.white.opacity(0.06) : PillarsColors.gold))
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(nudged)
                .sensoryFeedback(.success, trigger: nudged)
            }
        }
    }
}
