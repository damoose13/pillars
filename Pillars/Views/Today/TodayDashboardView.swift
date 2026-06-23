import SwiftUI
import SwiftData

/// The cockpit. A single, calm read of the day: foundation header, the system-score orb,
/// the pillars at the extremes, today's three moves, and a compact pillar map.
struct TodayDashboardView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState

    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query private var actions: [PillarAction]

    @State private var showCheckIn = false

    private var result: PillarScoreResult? { PillarScoringEngine.result(from: checkIns) }

    private var hasCheckedInToday: Bool {
        guard let latest = checkIns.first else { return false }
        return Calendar.current.isDateInToday(latest.date)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: PillarsSpacing.xl) {
                topBar

                if let result {
                    TodayFoundationHeader(result: result)
                    orbSection(result)
                    highlights(result)
                    movesSection(result)
                    mapSection(result)
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
        .fullScreenCover(isPresented: $showCheckIn) {
            DailyCheckInView()
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

    // MARK: Orb

    private func orbSection(_ result: PillarScoreResult) -> some View {
        VStack(spacing: PillarsSpacing.m) {
            PillarScoreOrb(score: result.systemScore)
            if checkIns.count > 1 {
                HStack(spacing: 8) {
                    TrendBadge(delta: result.systemTrend)
                    Text("vs. last check-in")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                }
            } else {
                Text("Your baseline. Check in again tomorrow to see movement.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PillarsSpacing.xs)
    }

    // MARK: Highlights (weakest / strongest)

    private func highlights(_ result: PillarScoreResult) -> some View {
        let weakest = PillarHighlightCard(
            label: "Needs support",
            pillar: result.weakestPillar,
            score: result.score(for: result.weakestPillar),
            trend: result.trend(for: result.weakestPillar),
            emphasized: true
        )
        let strongest = PillarHighlightCard(
            label: "Holding firm",
            pillar: result.strongestPillar,
            score: result.score(for: result.strongestPillar),
            trend: result.trend(for: result.strongestPillar),
            emphasized: false
        )
        // Side-by-side normally; stacks on narrow widths.
        return ViewThatFits(in: .horizontal) {
            HStack(spacing: PillarsSpacing.m) { weakest; strongest }
            VStack(spacing: PillarsSpacing.m) { weakest; strongest }
        }
    }

    // MARK: Moves

    private func movesSection(_ result: PillarScoreResult) -> some View {
        let recs = RecommendationEngine.recommendations(for: result)
        return VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(
                title: "Today's Moves",
                subtitle: "Small restoration beats total overhaul.",
                actionTitle: "All",
                action: { appState.selectedTab = .moves }
            )
            ForEach(recs) { rec in
                PillarMoveCard(
                    recommendation: rec,
                    isCompleted: isDone(rec),
                    onToggle: { toggle(rec) }
                )
            }
        }
    }

    // MARK: Map

    private func mapSection(_ result: PillarScoreResult) -> some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(
                title: "Pillar Map",
                subtitle: "All eight, at a glance.",
                actionTitle: "Expand",
                action: { appState.selectedTab = .map }
            )
            PillarGlassCard {
                PillarRadialMap(scores: result.pillarScores, showLabels: false)
                    .frame(height: 230)
                    .frame(maxWidth: .infinity)
            }
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

    // MARK: Completion state

    private func isDone(_ rec: PillarRecommendation) -> Bool {
        actions.contains { $0.matches(rec) && $0.isCompleted }
    }

    private func toggle(_ rec: PillarRecommendation) {
        if let existing = actions.first(where: { $0.matches(rec) }) {
            existing.isCompleted.toggle()
            existing.completedAt = existing.isCompleted ? .now : nil
        } else {
            let action = PillarAction(
                title: rec.title, subtitle: rec.subtitle, pillar: rec.pillar,
                isCompleted: true, createdAt: .now, completedAt: .now
            )
            context.insert(action)
        }
        try? context.save()
    }
}

/// One of the two "extremes" cards on the dashboard.
private struct PillarHighlightCard: View {
    let label: String
    let pillar: PillarType
    let score: Int
    let trend: Int
    let emphasized: Bool

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m, highlight: emphasized) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text(label).pillarsOverline(emphasized ? PillarsColors.gold.opacity(0.9) : PillarsColors.secondaryText)
                HStack(spacing: PillarsSpacing.s) {
                    PillarIconBadge(pillar: pillar, size: 40)
                    Text(pillar.displayName)
                        .font(PillarsTypography.titleSmall)
                        .foregroundStyle(PillarsColors.primaryText)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                HStack {
                    ScoreDots(score: score, accent: pillar.color)
                    Spacer(minLength: PillarsSpacing.xs)
                    TrendBadge(delta: trend)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
#Preview {
    TodayDashboardView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
