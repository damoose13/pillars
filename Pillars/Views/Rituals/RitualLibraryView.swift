import SwiftUI
import SwiftData

/// Browse the repeatable rituals — the practices a person can return to. A retention
/// surface: not "today's tasks" but a library to build a life around. Rituals matching the
/// pillar that's asking for support are marked "Recommended" and floated to the top.
struct RitualLibraryView: View {
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    @State private var filter: PillarType?

    private var result: PillarScoreResult? { PillarScoringEngine.result(from: checkIns) }

    /// The pillars currently asking for support — their rituals get the "Recommended" tag.
    private var recommended: Set<PillarType> {
        guard let result else { return [] }
        return [result.weakestPillar, result.secondWeakestPillar]
    }

    /// Rituals after the active filter, recommended ones first.
    private var rituals: [Ritual] {
        let base = RitualLibrary.all.filter { filter == nil || $0.pillar == filter }
        return base.sorted { a, b in
            let ra = recommended.contains(a.pillar), rb = recommended.contains(b.pillar)
            if ra != rb { return ra }
            return false
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.l) {
                VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                    Text("The library")
                        .pillarsOverline(PillarsColors.gold.opacity(0.9))
                    Text("Rituals worth\nreturning to.")
                        .font(PillarsTypography.display)
                        .foregroundStyle(PillarsColors.primaryText)
                        .lineSpacing(2)
                    Text("Small, repeatable practices — not tasks to finish. Keep the ones that fit your life.")
                        .font(PillarsTypography.body)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                filterChips

                VStack(spacing: PillarsSpacing.s) {
                    ForEach(rituals) { ritual in
                        NavigationLink {
                            RitualDetailView(ritual: ritual)
                        } label: {
                            RitualRow(ritual: ritual, recommended: recommended.contains(ritual.pillar))
                        }
                        .buttonStyle(.plain)
                    }
                    if rituals.isEmpty {
                        Text("No rituals for this pillar yet.")
                            .font(PillarsTypography.callout)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PillarsSpacing.l)
                    }
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
        .navigationTitle("Rituals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    /// A horizontal row of pillar filters — "All" plus each pillar.
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", color: PillarsColors.gold, active: filter == nil) { filter = nil }
                ForEach(PillarType.allCases) { pillar in
                    chip(title: pillar.displayName, color: pillar.color, active: filter == pillar) {
                        filter = (filter == pillar) ? nil : pillar
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func chip(title: String, color: Color, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation(.snappy(duration: 0.2)) { action() } }) {
            Text(title)
                .font(PillarsTypography.caption.weight(.semibold))
                .foregroundStyle(active ? PillarsColors.background : PillarsColors.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(active ? color : Color.white.opacity(0.05)))
                .overlay(Capsule().strokeBorder(active ? Color.clear : PillarsColors.cardBorder, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct RitualRow: View {
    let ritual: Ritual
    var recommended: Bool = false

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m, highlight: recommended) {
            HStack(spacing: PillarsSpacing.m) {
                PillarIconBadge(pillar: ritual.pillar, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(ritual.name)
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        if recommended {
                            Text("Recommended")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(PillarsColors.background)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(PillarsColors.gold))
                        }
                    }
                    Text(ritual.summary)
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Circle().fill(ritual.tone.color).frame(width: 6, height: 6)
                        Text(ritual.tone.label.lowercased())
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(ritual.tone.color)
                        if ritual.estimatedMinutes > 0 {
                            Text("· \(ritual.estimatedMinutes) min")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(PillarsColors.tertiaryText)
                        }
                        if ritual.shareable {
                            Image(systemName: "person.2")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(PillarsColors.tertiaryText)
                        }
                    }
                    .padding(.top, 1)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack { RitualLibraryView() }
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
