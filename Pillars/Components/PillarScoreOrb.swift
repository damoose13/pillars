import SwiftUI

/// The cockpit centerpiece: a glowing circular gauge showing the 0–100 system score.
///
/// A faint inner glow, a quiet track, and a gold progress ring with a soft halo. The
/// number is large editorial serif and animates between values.
struct PillarScoreOrb: View {
    /// 0–100.
    let score: Int
    var caption: String = "System Score"
    var accent: Color = PillarsColors.gold
    var size: CGFloat = 224
    var lineWidth: CGFloat = 14

    private var progress: Double { Double(min(100, max(0, score))) / 100 }

    var body: some View {
        ZStack {
            // Ambient glow.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.30), .clear],
                        center: .center, startRadius: 0, endRadius: size * 0.58
                    )
                )
                .blur(radius: 22)

            // Track.
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: lineWidth)

            // Progress.
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [accent.opacity(0.45), accent, PillarsColors.goldSoft]),
                        center: .center,
                        startAngle: .degrees(0), endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: accent.opacity(0.45), radius: 9)

            // Center readout.
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(PillarsFont.serif(min(size * 0.36, 86), .semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(caption)
                    .pillarsOverline()
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.7), value: progress)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(caption)
        .accessibilityValue("\(score) out of 100")
    }
}
