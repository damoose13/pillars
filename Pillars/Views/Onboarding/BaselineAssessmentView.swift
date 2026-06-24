import SwiftUI
import SwiftData

/// The first real input: rate where each pillar sits today. Saved as the first
/// `DailyCheckIn` — the ground we measure from.
struct BaselineAssessmentView: View {
    var onComplete: () -> Void
    var onBack: () -> Void

    @Environment(\.modelContext) private var context
    @State private var scores: [PillarType: Int] = Dictionary(
        uniqueKeysWithValues: PillarType.allCases.map { ($0, 3) }
    )
    @State private var revealScores: [PillarType: Int]?

    var body: some View {
        ZStack {
            baselineForm
            if let revealScores {
                FoundationRevealView(scores: revealScores, onContinue: onComplete)
                    .transition(.opacity)
            }
        }
    }

    private var baselineForm: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                        Text("Step One")
                            .pillarsOverline(PillarsColors.gold)
                        Text("Set your baseline.")
                            .font(PillarsTypography.display)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("Rate where each pillar sits today. There are no wrong answers — this simply becomes the ground we measure from. You can update it anytime.")
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    PillarScoreForm(scores: $scores)
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
        PrimaryButton(title: "Create my foundation", icon: "checkmark") { save() }
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

    private func save() {
        let checkIn = DailyCheckIn(date: .now)
        for pillar in PillarType.allCases {
            checkIn.setScore(scores[pillar] ?? 3, for: pillar)
        }
        context.insert(checkIn)
        try? context.save()
        withAnimation(.smooth(duration: 0.5)) { revealScores = scores }
    }
}

#if DEBUG
#Preview {
    BaselineAssessmentView(onComplete: {}, onBack: {})
        .pillarsBackground()
        .environment(AppState())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
