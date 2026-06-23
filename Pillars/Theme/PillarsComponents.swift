import SwiftUI

// MARK: - Section header

/// Editorial section header with an optional trailing action.
struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PillarsTypography.titleSmall)
                    .foregroundStyle(PillarsColors.primaryText)
                if let subtitle {
                    Text(subtitle)
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                }
            }
            Spacer(minLength: PillarsSpacing.s)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(PillarsTypography.caption.weight(.semibold))
                        .foregroundStyle(PillarsColors.gold)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Primary / secondary buttons

/// Filled gold button — the single loud element on a screen.
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PillarsSpacing.xs) {
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(PillarsTypography.headline)
            .foregroundStyle(PillarsColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [PillarsColors.goldSoft, PillarsColors.gold],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .shadow(color: PillarsColors.gold.opacity(0.30), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Quiet, glass-outline button.
struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PillarsSpacing.xs) {
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(PillarsTypography.headline)
            .foregroundStyle(PillarsColors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule(style: .continuous).fill(Color.white.opacity(0.05))
            )
            .overlay(
                Capsule(style: .continuous).strokeBorder(PillarsColors.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// A gentle press-scale for buttons — tactile without bounce.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}

// MARK: - Pillar icon badge

/// A tinted circular badge holding a pillar's symbol. Reused across cards and forms.
struct PillarIconBadge: View {
    let pillar: PillarType
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            Circle().fill(pillar.color.opacity(0.16))
            Circle().strokeBorder(pillar.color.opacity(0.35), lineWidth: 1)
            Image(systemName: pillar.icon)
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundStyle(pillar.color)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Score dots

/// Five dots representing a 1–5 pillar score.
struct ScoreDots: View {
    let score: Int
    var accent: Color
    var total: Int = 5
    var dot: CGFloat = 7

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...total, id: \.self) { i in
                Circle()
                    .fill(i <= score ? accent : Color.white.opacity(0.12))
                    .frame(width: dot, height: dot)
            }
        }
    }
}

// MARK: - Meta chip

/// A small capsule for metadata (pillar name, mode, minutes).
struct MetaChip: View {
    let text: String
    var color: Color = PillarsColors.secondaryText
    var filled: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(filled ? PillarsColors.background : color)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(filled ? color : color.opacity(0.14))
            )
    }
}

// MARK: - Trend badge

/// Shows a delta as a small arrow + value. Tone is informational, never judgemental.
struct TrendBadge: View {
    /// Change vs the previous reference (same units as the value shown).
    let delta: Int
    var unit: String = ""

    private var isFlat: Bool { delta == 0 }
    private var isUp: Bool { delta > 0 }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isFlat ? "minus" : (isUp ? "arrow.up.right" : "arrow.down.right"))
                .font(.system(size: 10, weight: .bold))
            Text(isFlat ? "Even" : "\(abs(delta))\(unit)")
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(isFlat ? PillarsColors.tertiaryText : (isUp ? PillarsColors.positive : PillarsColors.caution))
    }
}
