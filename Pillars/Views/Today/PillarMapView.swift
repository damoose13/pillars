import SwiftUI
import SwiftData

/// The full pillar map: a large radar of all eight pillars, followed by an ordered list
/// (weakest first) that drills into each pillar's detail.
struct PillarMapView: View {
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    private var result: PillarScoreResult? { PillarScoringEngine.result(from: checkIns) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    header

                    if let result {
                        PillarGlassCard {
                            PillarRadialMap(scores: result.pillarScores, showLabels: true)
                                .frame(height: 360)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, PillarsSpacing.s)
                        }

                        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                            SectionHeader(title: "By need", subtitle: "Weakest first — where attention pays off most.")
                            VStack(spacing: PillarsSpacing.s) {
                                ForEach(result.pillarsByNeed) { pillar in
                                    NavigationLink {
                                        PillarDetailView(pillar: pillar)
                                    } label: {
                                        PillarListRow(
                                            pillar: pillar,
                                            score: result.score(for: pillar),
                                            trend: result.trend(for: pillar)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    } else {
                        emptyState
                    }
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.l)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("Pillar Map")
                .pillarsOverline(PillarsColors.gold.opacity(0.9))
            Text("The shape of\nyour day.")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
                .lineSpacing(2)
            Text("A balanced life fills the map evenly. Where it pulls inward is simply where your structure is asking for support.")
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var emptyState: some View {
        PillarGlassCard(padding: PillarsSpacing.xl) {
            VStack(spacing: PillarsSpacing.m) {
                Image(systemName: "circle.hexagongrid")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(PillarsColors.gold)
                Text("Your map appears after your first check-in.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

/// A tappable pillar row used in the map list.
private struct PillarListRow: View {
    let pillar: PillarType
    let score: Int
    let trend: Int

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.m) {
                PillarIconBadge(pillar: pillar)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: PillarsSpacing.xs) {
                        Text(pillar.displayName)
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text(PillarState.from(score: score).label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(PillarState.from(score: score).color)
                    }
                    ScoreDots(score: score, accent: pillar.color)
                }
                Spacer(minLength: PillarsSpacing.xs)
                TrendBadge(delta: trend)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
        }
    }
}

#if DEBUG
#Preview {
    PillarMapView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
