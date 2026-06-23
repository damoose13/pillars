import SwiftUI

/// Explains, plainly, how a Circle supports people without exposing private scores. Shown
/// as a sheet from Circle home and during creation.
struct PrivacyExplainerView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 40, weight: .light))
                            .foregroundStyle(PillarsColors.gold)
                        Text("A Circle that\nnever exposes you.")
                            .font(PillarsTypography.display)
                            .foregroundStyle(PillarsColors.primaryText)
                            .lineSpacing(2)
                        Text("Circles are built to let trusted people support each other — without ever sharing private body, mood, sleep, food, spiritual, or journal data. The smaller the Circle, the less it ever shows.")
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: PillarsSpacing.m) {
                        ruleCard(
                            range: "2 people",
                            title: "Wins only",
                            detail: "No aggregate scores at all — an average of two can reveal an individual. You'll see voluntary shared wins and suggestions, nothing more."
                        )
                        ruleCard(
                            range: "3 people",
                            title: "One blurred trend",
                            detail: "A single, vague signal like \u{201C}Connect is quiet.\u{201D} No values, no names, no individual data."
                        )
                        ruleCard(
                            range: "4+ people",
                            title: "Aggregate trends",
                            detail: "Soft pillar trend labels for the group. Still no numbers, and individual scores never leave each person's device."
                        )
                        ruleCard(
                            range: "Any size",
                            title: "Your wins, your choice",
                            detail: "You can always choose to share a win. Nothing is shared unless you decide to share it."
                        )
                    }

                    Text("Pillars never shames anyone, never ranks people, and never makes medical claims. A Circle is for support — not surveillance.")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(PillarsColors.gold)
                }
            }
        }
    }

    private func ruleCard(range: String, title: String, detail: String) -> some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(alignment: .top, spacing: PillarsSpacing.m) {
                Text(range)
                    .font(PillarsTypography.caption.weight(.bold))
                    .foregroundStyle(PillarsColors.background)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(PillarsColors.goldSoft))
                    .fixedSize()
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Text(detail)
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .lineSpacing(1.5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    PrivacyExplainerView().preferredColorScheme(.dark)
}
#endif
