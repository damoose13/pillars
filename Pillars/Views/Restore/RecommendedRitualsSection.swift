import SwiftUI

/// Section: rituals matching the pillars currently asking for support.
struct RecommendedRitualsSection: View {
    let result: PillarScoreResult

    private var rituals: [Ritual] {
        var seen = Set<String>()
        var out: [Ritual] = []
        for pillar in [result.weakestPillar, result.secondWeakestPillar] {
            for ritual in RitualLibrary.rituals(for: pillar) where !seen.contains(ritual.id) {
                seen.insert(ritual.id)
                out.append(ritual)
            }
        }
        return Array(out.prefix(3))
    }

    var body: some View {
        if !rituals.isEmpty {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                SectionHeader(title: "Recommended Rituals",
                              subtitle: "Practices for the pillars asking for support.")
                ForEach(rituals) { ritual in
                    NavigationLink {
                        RitualDetailView(ritual: ritual)
                    } label: {
                        RestoreRitualCard(ritual: ritual, recommended: true)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
