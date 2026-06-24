import SwiftUI

/// The first screen. Editorial, quiet, confident — a faint radial map glows behind the
/// wordmark to hint at the eight pillars without explaining anything yet.
struct WelcomeView: View {
    var onBegin: () -> Void

    // A calm, balanced sample used only as decoration behind the title.
    private let motif: [PillarType: Int] = [
        .body: 4, .fuel: 3, .sleep: 4, .recover: 3,
        .mind: 4, .connect: 3, .space: 4, .purpose: 5
    ]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: PillarsSpacing.xl) {
                Spacer(minLength: PillarsSpacing.l)

                ZStack {
                    DynamicPillarWebView(scores: PillarWebScore.all(from: motif), mode: .background)
                        .frame(width: min(geo.size.width * 0.9, 360), height: min(geo.size.width * 0.9, 360))
                        .opacity(0.5)
                        .blur(radius: 1.5)

                    VStack(spacing: PillarsSpacing.m) {
                        Text("Pillars")
                            .pillarsOverline(PillarsColors.gold)
                        Text("The quiet operating\nsystem for a\nsteady life.")
                            .font(PillarsTypography.displayXL)
                            .foregroundStyle(PillarsColors.primaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .minimumScaleFactor(0.7)
                    }
                }

                Text("Check in across eight pillars. See what's holding you up — and the one small thing that will restore the rest.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, PillarsSpacing.l)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                VStack(spacing: PillarsSpacing.m) {
                    PrimaryButton(title: "Begin", icon: "arrow.right") { onBegin() }
                    Label("Private by design. Everything stays on your device.", systemImage: "lock.fill")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                        .labelStyle(.titleAndIcon)
                }
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PillarsSpacing.screenH)
            .padding(.vertical, PillarsSpacing.xl)
        }
    }
}

#if DEBUG
#Preview {
    WelcomeView(onBegin: {})
        .pillarsBackground()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
#endif
