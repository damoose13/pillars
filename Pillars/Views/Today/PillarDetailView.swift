import SwiftUI
import SwiftData

/// Detail for a single pillar: what it means, where it stands, a quiet 7-day history, and
/// a few ways to support it. No diagnoses, no charts library — just a calm read.
struct PillarDetailView: View {
    let pillar: PillarType

    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query(sort: \PillarAction.createdAt, order: .reverse) private var actions: [PillarAction]
    @State private var showUpdate = false

    /// Up to seven most recent check-ins, oldest → newest, for the trend line.
    private var history: [DailyCheckIn] {
        Array(checkIns.prefix(7).reversed())
    }

    /// The user's own recent reflections on restorations for this pillar — what's helped.
    private var reflections: [PillarAction] {
        actions.filter { $0.pillar == pillar && ($0.helped?.isEmpty == false) }.prefix(3).map { $0 }
    }

    private var currentScore: Int { checkIns.first?.score(for: pillar) ?? 0 }

    private var trend: Int {
        guard checkIns.count > 1 else { return 0 }
        return checkIns[0].score(for: pillar) - checkIns[1].score(for: pillar)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                heading
                statusCard
                updateButton
                if history.count > 1 { historyCard }
                reflectionsCard
                supportCard
                ritualCard
            }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PillarsSpacing.screenH)
            .padding(.top, PillarsSpacing.m)
            .padding(.bottom, PillarsSpacing.xxl)
        }
        .scrollIndicators(.hidden)
        .pillarsBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showUpdate) { OnePillarUpdateView(pillar: pillar) }
    }

    /// Turn the read into an act: update just this pillar without a full check-in.
    private var updateButton: some View {
        SecondaryButton(title: "Update \(pillar.displayName) now", icon: "slider.horizontal.3") {
            showUpdate = true
        }
    }

    /// Turn the detail screen from "look" into "act": a ritual to anchor this pillar.
    @ViewBuilder private var ritualCard: some View {
        if let ritual = RitualLibrary.anchor(for: pillar) {
            NavigationLink {
                RitualDetailView(ritual: ritual)
            } label: {
                PillarGlassCard(highlight: true) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                        Text("A ritual for \(pillar.displayName)")
                            .pillarsOverline(PillarsColors.gold.opacity(0.9))
                        HStack(spacing: PillarsSpacing.m) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(ritual.name)
                                    .font(PillarsTypography.title)
                                    .foregroundStyle(PillarsColors.primaryText)
                                Text(ritual.summary)
                                    .font(PillarsTypography.callout)
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
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            PillarIconBadge(pillar: pillar, size: 64)
            VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
                Text(pillar.displayName)
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                Text(pillar.shortDescription)
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var statusCard: some View {
        PillarGlassCard {
            HStack(alignment: .center, spacing: PillarsSpacing.l) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today")
                        .pillarsOverline()
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(currentScore)")
                            .font(PillarsFont.serif(44, .semibold))
                            .foregroundStyle(PillarsColors.primaryText)
                        Text(PillarState.from(score: currentScore).label)
                            .font(PillarsTypography.callout.weight(.semibold))
                            .foregroundStyle(PillarState.from(score: currentScore).color)
                    }
                    ScoreDots(score: currentScore, accent: pillar.color, dot: 9)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Trend")
                        .pillarsOverline()
                    TrendBadge(delta: trend)
                    Text(checkIns.count > 1 ? "vs. last check-in" : "first reading")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                }
            }
        }
    }

    private var historyCard: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text("Recent trend")
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                Sparkline(values: history.map { $0.score(for: pillar) }, color: pillar.color)
                    .frame(height: 96)
                HStack(spacing: 0) {
                    ForEach(history.indices, id: \.self) { idx in
                        Text(history[idx].date.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(PillarsColors.tertiaryText)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    /// New: surfaces the user's own "did it help?" reflections for this pillar.
    @ViewBuilder private var reflectionsCard: some View {
        if !reflections.isEmpty {
            PillarGlassCard {
                VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                    Text("What's been helping you")
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    ForEach(reflections) { action in
                        HStack(alignment: .top, spacing: PillarsSpacing.s) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(PillarsColors.gold)
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(action.title)
                                    .font(PillarsTypography.callout.weight(.medium))
                                    .foregroundStyle(PillarsColors.primaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("\(action.helped ?? "") · \(action.createdAt.formatted(.relative(presentation: .named)))")
                                    .font(PillarsTypography.caption)
                                    .foregroundStyle(PillarsColors.secondaryText)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
        }
    }

    private var supportCard: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text("What helps")
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                ForEach(tips.indices, id: \.self) { idx in
                    let tip = tips[idx]
                    HStack(alignment: .top, spacing: PillarsSpacing.s) {
                        Circle().fill(pillar.color).frame(width: 6, height: 6).padding(.top, 7)
                        Text(tip)
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    /// A few calm, non-prescriptive supports per pillar (shared with Today's ideas section).
    private var tips: [String] { PillarGuidance.tips(for: pillar) }
}

#if DEBUG
#Preview {
    NavigationStack {
        PillarDetailView(pillar: .connect)
    }
    .environment(AppState())
    .modelContainer(PreviewData.container)
    .preferredColorScheme(.dark)
}
#endif
