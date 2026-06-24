import SwiftUI
import SwiftData

/// The full list of today's restoring actions, with completion tracking. Same three moves
/// the dashboard surfaces — here with room to breathe and a quiet sense of progress.
struct TodayMovesView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState

    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query private var actions: [PillarAction]

    private var result: PillarScoreResult? { PillarScoringEngine.result(from: checkIns) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    header

                    if let result {
                        let recs = RestorationEngine.restorations(for: result)
                        weakestContext(result)
                        progressCard(recs)
                        VStack(spacing: PillarsSpacing.m) {
                            ForEach(recs) { rec in
                                PillarMoveCard(
                                    recommendation: rec,
                                    isCompleted: RestorationLog.isCompleted(rec, in: actions),
                                    onToggle: { RestorationLog.toggle(rec, in: actions, context: context) }
                                )
                            }
                        }
                        ritualsLink
                        footerNote
                    } else {
                        emptyState
                        ritualsLink
                    }
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.xl)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var ritualsLink: some View {
        NavigationLink {
            RitualLibraryView()
        } label: {
            PillarGlassCard(padding: PillarsSpacing.m) {
                HStack(spacing: PillarsSpacing.m) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(PillarsColors.gold)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(PillarsColors.gold.opacity(0.12)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("The Ritual Library")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("Repeatable practices to return to")
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.secondaryText)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(PillarsColors.tertiaryText)
                }
            }
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("Today")
                .pillarsOverline(PillarsColors.gold.opacity(0.9))
            Text("Restore.")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
            Text("You don't need to fix everything. Start with one — the pillar asking for support — and let the rest follow.")
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Names the actual weakest pillar and its state, connecting Restore to the web on Today.
    private func weakestContext(_ result: PillarScoreResult) -> some View {
        let pillar = result.weakestPillar
        let state = PillarState.from(score: result.score(for: pillar))
        return HStack(spacing: PillarsSpacing.s) {
            PillarIconBadge(pillar: pillar, size: 38)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(pillar.displayName) is \(state.supportCopy)")
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("These restorations lead with it.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.secondaryText)
            }
            Spacer(minLength: 0)
        }
    }

    private func progressCard(_ recs: [PillarRecommendation]) -> some View {
        let done = recs.filter { RestorationLog.isCompleted($0, in: actions) }.count
        return PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.m) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(done) of \(recs.count) restored")
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Text(done == recs.count ? "A complete, quiet day. Well held." : "One small action is enough to shift the day.")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                ZStack {
                    Circle().stroke(Color.white.opacity(0.08), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: recs.isEmpty ? 0 : Double(done) / Double(recs.count))
                        .stroke(PillarsColors.gold, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: done == recs.count && !recs.isEmpty ? "checkmark" : "circle.grid.cross")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(PillarsColors.gold)
                }
                .frame(width: 46, height: 46)
                .animation(.easeInOut, value: done)
            }
        }
    }

    private var footerNote: some View {
        Text("Restorations refresh with each check-in. Completing one won't change your scores — it changes your day.")
            .font(PillarsTypography.caption)
            .foregroundStyle(PillarsColors.tertiaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, PillarsSpacing.xs)
    }

    private var emptyState: some View {
        PillarGlassCard(padding: PillarsSpacing.xl) {
            VStack(spacing: PillarsSpacing.m) {
                Image(systemName: "checklist")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(PillarsColors.gold)
                Text("No moves yet")
                    .font(PillarsTypography.title)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("Complete a check-in and Pillars will suggest a few small, restoring actions.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                SecondaryButton(title: "Go to Today", icon: "arrow.right") { appState.selectedTab = .today }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
#Preview {
    TodayMovesView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
