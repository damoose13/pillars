import SwiftUI
import SwiftData

/// The cockpit. The interactive Pillar Web is the hero: it shows the shape of the day,
/// reveals the weak pillar, and leads straight into a restoration.
struct TodayDashboardView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState

    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query private var actions: [PillarAction]

    @State private var showCheckIn = false
    @State private var selectedPillar: PillarType?
    @State private var detailPillar: PillarType?

    private var result: PillarScoreResult? { PillarScoringEngine.result(from: checkIns) }

    private var hasCheckedInToday: Bool {
        guard let latest = checkIns.first else { return false }
        return Calendar.current.isDateInToday(latest.date)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PillarsSpacing.xl) {
                    topBar

                    if let result {
                        if !hasCheckedInToday { todayNudge }
                        TodayFoundationHeader(result: result, isToday: hasCheckedInToday)
                        webHero(result)
                        insightPanel(result)
                        ideasSection(result)
                        movesSection(result)
                        insightsSection
                    } else {
                        emptyState
                    }
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $detailPillar) { PillarDetailView(pillar: $0) }
            .fullScreenCover(isPresented: $showCheckIn) {
                DailyCheckInView()
            }
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(alignment: .center) {
            Text("Pillars")
                .font(PillarsFont.serif(22, .semibold))
                .foregroundStyle(PillarsColors.primaryText)
            Spacer()
            Button { showCheckIn = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: hasCheckedInToday ? "arrow.clockwise" : "plus")
                    Text(hasCheckedInToday ? "Update" : "Check in")
                }
                .font(PillarsTypography.callout.weight(.semibold))
                .foregroundStyle(PillarsColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.white.opacity(0.06)))
                .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    // MARK: Pillar Web hero

    private func webHero(_ result: PillarScoreResult) -> some View {
        VStack(spacing: PillarsSpacing.s) {
            DynamicPillarWebView(
                scores: PillarWebScore.all(from: result.pillarScores),
                mode: .hero,
                weakestPillar: result.weakestPillar,
                strongestPillar: result.strongestPillar,
                selectedPillar: selectionBinding(result)
            )
            .frame(height: 380)

            Text("Tap any pillar to explore it.")
                .font(PillarsTypography.caption)
                .foregroundStyle(PillarsColors.tertiaryText)

            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text("Foundation · \(result.systemScore)")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                    if checkIns.count > 1 { TrendBadge(delta: result.systemTrend) }
                }
                rhythmLine
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func insightPanel(_ result: PillarScoreResult) -> some View {
        let pillar = selectedPillar ?? result.weakestPillar
        let score = PillarWebScore(pillar: pillar, score: result.score(for: pillar))
        return SelectedPillarInsightPanel(
            score: score,
            onRestore: { appState.selectedTab = .moves },
            onDetail: { detailPillar = pillar }
        )
    }

    /// Ideas for whichever pillar is selected on the web — the "scroll down to explore it" payoff.
    private func ideasSection(_ result: PillarScoreResult) -> some View {
        let pillar = selectedPillar ?? result.weakestPillar
        let tips = PillarGuidance.tips(for: pillar)
        let ritual = RitualLibrary.anchor(for: pillar)
        return VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(title: "Ideas for \(pillar.displayName)", subtitle: "Small ways to support it today.")
            PillarGlassCard {
                VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                    ForEach(tips.indices, id: \.self) { i in
                        HStack(alignment: .top, spacing: PillarsSpacing.s) {
                            Circle().fill(pillar.color).frame(width: 6, height: 6).padding(.top, 7)
                            Text(tips[i])
                                .font(PillarsTypography.body)
                                .foregroundStyle(PillarsColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            if let ritual {
                NavigationLink {
                    RitualDetailView(ritual: ritual)
                } label: {
                    PillarGlassCard(padding: PillarsSpacing.m, highlight: true) {
                        HStack(spacing: PillarsSpacing.m) {
                            Image(systemName: "books.vertical")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(PillarsColors.gold)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(PillarsColors.gold.opacity(0.12)))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ritual.name)
                                    .font(PillarsTypography.headline)
                                    .foregroundStyle(PillarsColors.primaryText)
                                Text("A ritual for \(pillar.displayName)")
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
        }
    }

    /// Selection defaults to the weakest pillar — the web leads with the weak point.
    private func selectionBinding(_ result: PillarScoreResult) -> Binding<PillarType?> {
        Binding(
            get: { selectedPillar ?? result.weakestPillar },
            set: { selectedPillar = $0 }
        )
    }

    /// A calm continuity signal — not a streak, just a quiet rhythm.
    @ViewBuilder private var rhythmLine: some View {
        if checkInDaysThisWeek >= 2 {
            Text("A steady rhythm — \(checkInDaysThisWeek) of the last 7 days.")
                .font(PillarsTypography.caption)
                .foregroundStyle(PillarsColors.secondaryText)
        }
    }

    /// A gentle prompt when the day's check-in hasn't happened yet.
    private var todayNudge: some View {
        Button { showCheckIn = true } label: {
            PillarGlassCard(padding: PillarsSpacing.m, highlight: true) {
                HStack(spacing: PillarsSpacing.m) {
                    ZStack {
                        Circle().fill(PillarsColors.gold.opacity(0.14))
                        Image(systemName: "sun.horizon")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(PillarsColors.gold)
                    }
                    .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("How are you today?")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("You're looking at where you left off. A fresh check-in takes a minute.")
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
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

    /// Distinct days with a check-in over the last 7 days.
    private var checkInDaysThisWeek: Int {
        let cal = Calendar.current
        let cutoff = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: .now)) ?? .now
        let days = checkIns.filter { $0.date >= cutoff }.map { cal.startOfDay(for: $0.date) }
        return Set(days).count
    }

    // MARK: Restorations

    private func movesSection(_ result: PillarScoreResult) -> some View {
        let recs = RestorationEngine.restorations(for: result)
        return VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(
                title: "Today's Restorations",
                subtitle: "Small restoration beats total overhaul.",
                actionTitle: "All",
                action: { appState.selectedTab = .moves }
            )
            ForEach(recs) { rec in
                PillarMoveCard(
                    recommendation: rec,
                    isCompleted: RestorationLog.isCompleted(rec, in: actions),
                    onToggle: { RestorationLog.toggle(rec, in: actions, context: context) }
                )
            }
        }
    }

    // MARK: Insights (Weekly Review · History)

    private var insightsSection: some View {
        let weekly = NavigationLink {
            WeeklyReviewView()
        } label: {
            NavCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "This week",
                subtitle: "A gentle weekly read"
            )
        }
        .buttonStyle(PressableButtonStyle())

        let history = NavigationLink {
            HistoryView()
        } label: {
            NavCard(
                icon: "clock.arrow.circlepath",
                title: "History",
                subtitle: "Every check-in, private"
            )
        }
        .buttonStyle(PressableButtonStyle())

        return ViewThatFits(in: .horizontal) {
            HStack(spacing: PillarsSpacing.m) { weekly; history }
            VStack(spacing: PillarsSpacing.m) { weekly; history }
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        PillarGlassCard(padding: PillarsSpacing.xl, highlight: true) {
            VStack(spacing: PillarsSpacing.m) {
                Image(systemName: "circle.hexagongrid")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(PillarsColors.gold)
                Text("How are your pillars today?")
                    .font(PillarsTypography.title)
                    .foregroundStyle(PillarsColors.primaryText)
                    .multilineTextAlignment(.center)
                Text("Eight pillars, about a minute. See what's holding you up — and the one thing that needs you.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                PrimaryButton(title: "Start check-in", icon: "arrow.right") { showCheckIn = true }
                    .padding(.top, PillarsSpacing.xs)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, PillarsSpacing.xxl)
    }
}

/// A compact navigation tile (Weekly Review / History) for the dashboard.
private struct NavCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.s) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(PillarsColors.gold)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(PillarsColors.gold.opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Text(subtitle)
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
        }
    }
}

#if DEBUG
#Preview {
    TodayDashboardView()
        .environment(AppState())
        .environment(EntitlementManager.preview([.plus, .circlePass]))
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
