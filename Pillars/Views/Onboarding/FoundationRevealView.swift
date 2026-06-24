import SwiftUI

/// The payoff of onboarding: the moment the user's first Pillar Web appears. Built from their
/// baseline scores, it draws in, names the pillar asking for support, and invites them in.
struct FoundationRevealView: View {
    let scores: [PillarType: Int]
    var onContinue: () -> Void = {}

    @State private var appeared = false

    private var weakest: PillarType {
        scores.min { a, b in
            a.value != b.value ? a.value < b.value
                : (PillarType.allCases.firstIndex(of: a.key) ?? 0) < (PillarType.allCases.firstIndex(of: b.key) ?? 0)
        }?.key ?? .connect
    }

    var body: some View {
        ZStack {
            PillarsBackground()

            VStack(spacing: PillarsSpacing.l) {
                Spacer(minLength: 0)

                VStack(spacing: PillarsSpacing.xs) {
                    Text("Your foundation")
                        .pillarsOverline(PillarsColors.gold)
                    Text("This is the shape\nof your day.")
                        .font(PillarsTypography.display)
                        .foregroundStyle(PillarsColors.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)

                DynamicPillarWebView(
                    scores: PillarWebScore.all(from: scores),
                    mode: .hero,
                    weakestPillar: weakest
                )
                .frame(height: 320)
                .padding(.horizontal, PillarsSpacing.l)

                Text("Everything's holding you up. \(weakest.displayName) is the one asking for support — that's where Pillars will start.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, PillarsSpacing.xl)
                    .opacity(appeared ? 1 : 0)

                Spacer(minLength: 0)

                PrimaryButton(title: "Enter Pillars", icon: "arrow.right", action: onContinue)
                    .padding(.horizontal, PillarsSpacing.screenH)
                    .padding(.bottom, PillarsSpacing.xl)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.smooth(duration: 0.7).delay(0.35)) { appeared = true }
        }
    }
}

#if DEBUG
#Preview {
    FoundationRevealView(scores: [
        .body: 4, .fuel: 3, .sleep: 4, .recover: 3,
        .mind: 4, .connect: 2, .space: 4, .purpose: 5
    ])
    .preferredColorScheme(.dark)
}
#endif
