import SwiftUI

/// A tactile 1–5 selector styled as a rising "level": segments fill up to the chosen
/// value, with a word label beneath. Calmer and more legible than a row of numbers.
struct ScoreSelector: View {
    @Binding var score: Int
    var accent: Color = PillarsColors.gold

    private let labels = ["Poor", "Rough", "Okay", "Good", "Strong"]

    var body: some View {
        VStack(spacing: PillarsSpacing.s) {
            HStack(spacing: 7) {
                ForEach(1...5, id: \.self) { value in
                    segment(for: value)
                }
            }

            HStack {
                Text("\(score)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent)
                Text(labels[max(0, min(4, score - 1))])
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.primaryText)
                    .contentTransition(.opacity)
                Spacer()
            }
        }
        .sensoryFeedback(.selection, trigger: score)
    }

    private func segment(for value: Int) -> some View {
        let isActive = value <= score
        return RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(isActive ? AnyShapeStyle(accent.opacity(0.9)) : AnyShapeStyle(Color.white.opacity(0.06)))
            .frame(height: 46)
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(value == score ? Color.white.opacity(0.30) : Color.clear, lineWidth: 1.5)
            }
            .overlay {
                // A subtle index numeral, brightest at the selected step.
                Text("\(value)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isActive ? PillarsColors.background.opacity(0.85) : PillarsColors.tertiaryText)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.snappy(duration: 0.2)) { score = value }
            }
            .accessibilityElement()
            .accessibilityLabel("\(labels[value - 1])")
            .accessibilityAddTraits(value == score ? [.isSelected, .isButton] : .isButton)
    }
}
