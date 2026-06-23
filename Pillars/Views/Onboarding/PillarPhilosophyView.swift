import SwiftUI

/// Explains the eight pillars before the first assessment. Calm, brief, and skimmable.
struct PillarPhilosophyView: View {
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                        Text("The Idea")
                            .pillarsOverline(PillarsColors.gold)
                        Text("Eight pillars hold\nyou up.")
                            .font(PillarsTypography.display)
                            .foregroundStyle(PillarsColors.primaryText)
                            .lineSpacing(2)
                        Text("When one weakens, the whole structure leans. Pillars helps you notice which one — and restore it with a single small action. Not everything. Just the next right thing.")
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: PillarsSpacing.s) {
                        ForEach(PillarType.allCases) { pillar in
                            PillarGlassCard(padding: PillarsSpacing.m) {
                                HStack(spacing: PillarsSpacing.m) {
                                    PillarIconBadge(pillar: pillar)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(pillar.displayName)
                                            .font(PillarsTypography.headline)
                                            .foregroundStyle(PillarsColors.primaryText)
                                        Text(pillar.shortDescription)
                                            .font(PillarsTypography.caption)
                                            .foregroundStyle(PillarsColors.secondaryText)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                    }

                    Text("You can rename Purpose later — Spirit, Faith, Values, Meaning, Direction — whatever fits your life.")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.xl)
                .padding(.bottom, PillarsSpacing.l)
            }
            .scrollIndicators(.hidden)

            footer
        }
        .safeAreaInset(edge: .top) { topBar }
    }

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PillarsColors.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.05)))
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.horizontal, PillarsSpacing.screenH)
        .padding(.top, PillarsSpacing.xs)
    }

    private var footer: some View {
        PrimaryButton(title: "Continue", icon: "arrow.right") { onContinue() }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PillarsSpacing.screenH)
            .padding(.top, PillarsSpacing.s)
            .padding(.bottom, PillarsSpacing.m)
            .background(
                LinearGradient(colors: [.clear, PillarsColors.background.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
    }
}

#if DEBUG
#Preview {
    PillarPhilosophyView(onContinue: {}, onBack: {})
        .pillarsBackground()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
#endif
