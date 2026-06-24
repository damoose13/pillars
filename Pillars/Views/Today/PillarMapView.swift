import SwiftUI
import SwiftData

/// The full pillar map: a large radar of all eight pillars, followed by an ordered list
/// (weakest first) that drills into each pillar's detail.
struct PillarMapView: View {
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    @State private var selectedPillar: PillarType?
    @State private var detailPillar: PillarType?

    private var result: PillarScoreResult? { PillarScoringEngine.result(from: checkIns) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    header

                    if let result {
                        webCard(result)
                        insightPanel(result)

                        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                            SectionHeader(title: "By need", subtitle: "Weakest first — where attention pays off most.")
                            VStack(spacing: PillarsSpacing.s) {
                                ForEach(result.pillarsByNeed) { pillar in
                                    Button {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                            selectedPillar = pillar
                                        }
                                    } label: {
                                        PillarListRow(
                                            pillar: pillar,
                                            score: result.score(for: pillar),
                                            trend: result.trend(for: pillar),
                                            isSelected: (selectedPillar ?? result.weakestPillar) == pillar
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
            .navigationDestination(item: $detailPillar) { PillarDetailView(pillar: $0) }
        }
    }

    /// The interactive web — tap a pillar to select it; the list and insight panel follow.
    private func webCard(_ result: PillarScoreResult) -> some View {
        PillarGlassCard {
            DynamicPillarWebView(
                scores: PillarWebScore.all(from: result.pillarScores),
                mode: .standard,
                weakestPillar: result.weakestPillar,
                strongestPillar: result.strongestPillar,
                selectedPillar: selectionBinding(result)
            )
            .frame(height: 340)
            .frame(maxWidth: .infinity)
            .padding(.vertical, PillarsSpacing.s)
        }
    }

    private func insightPanel(_ result: PillarScoreResult) -> some View {
        let pillar = selectedPillar ?? result.weakestPillar
        return SelectedPillarInsightPanel(
            score: PillarWebScore(pillar: pillar, score: result.score(for: pillar)),
            onRestore: { detailPillar = pillar },
            onDetail: { detailPillar = pillar }
        )
    }

    private func selectionBinding(_ result: PillarScoreResult) -> Binding<PillarType?> {
        Binding(
            get: { selectedPillar ?? result.weakestPillar },
            set: { selectedPillar = $0 }
        )
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

/// A tappable pillar row used in the map list. Selecting it highlights the matching web point.
private struct PillarListRow: View {
    let pillar: PillarType
    let score: Int
    let trend: Int
    var isSelected: Bool = false

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m, highlight: isSelected) {
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
