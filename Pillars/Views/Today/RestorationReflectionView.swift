import SwiftUI
import SwiftData

/// A brief, private check after completing a restoration: did it help? The answer is recorded
/// only on the personal log (never shared) and is what lets Pillars learn what actually helps.
struct RestorationReflectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var actions: [PillarAction]

    let recommendation: PillarRecommendation

    private struct Option: Hashable { let label: String; let icon: String; let color: Color }
    private let options = [
        Option(label: "Yes — that helped", icon: "heart.fill", color: PillarsColors.positive),
        Option(label: "A little", icon: "leaf.fill", color: PillarsColors.gold),
        Option(label: "Not really", icon: "cloud.fill", color: PillarsColors.secondaryText),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                        PillarIconBadge(pillar: recommendation.pillar, size: 52)
                        Text("Did that help?")
                            .font(PillarsTypography.display)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("“\(recommendation.title)” is done. One quiet read, just for you — it tunes what Pillars suggests next, and is never shared.")
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: PillarsSpacing.s) {
                        ForEach(options, id: \.self) { option in
                            Button { answer(option.label) } label: {
                                PillarGlassCard(padding: PillarsSpacing.m) {
                                    HStack(spacing: PillarsSpacing.m) {
                                        Image(systemName: option.icon)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundStyle(option.color)
                                            .frame(width: 28)
                                        Text(option.label)
                                            .font(PillarsTypography.headline)
                                            .foregroundStyle(PillarsColors.primaryText)
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
                .frame(maxWidth: 540)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.l)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") { dismiss() }.foregroundStyle(PillarsColors.secondaryText)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func answer(_ helped: String) {
        RestorationLog.setHelped(recommendation, helped: helped, in: actions, context: context)
        dismiss()
    }
}
