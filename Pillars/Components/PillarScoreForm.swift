import SwiftUI

/// The reusable eight-pillar rating form. A glass card per pillar, each with its symbol,
/// name, prompt, and a `ScoreSelector`. Shared by the baseline assessment and the daily
/// check-in so the rating experience is identical everywhere.
struct PillarScoreForm: View {
    @Binding var scores: [PillarType: Int]

    var body: some View {
        VStack(spacing: PillarsSpacing.m) {
            ForEach(PillarType.allCases) { pillar in
                PillarGlassCard(padding: PillarsSpacing.l) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                        HStack(spacing: PillarsSpacing.s) {
                            PillarIconBadge(pillar: pillar)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pillar.displayName)
                                    .font(PillarsTypography.headline)
                                    .foregroundStyle(PillarsColors.primaryText)
                                Text(pillar.checkInPrompt)
                                    .font(PillarsTypography.caption)
                                    .foregroundStyle(PillarsColors.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        ScoreSelector(score: binding(for: pillar), accent: pillar.color)
                    }
                }
            }
        }
    }

    private func binding(for pillar: PillarType) -> Binding<Int> {
        Binding(
            get: { scores[pillar] ?? 3 },
            set: { scores[pillar] = $0 }
        )
    }
}
