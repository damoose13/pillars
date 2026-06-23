import SwiftUI
import SwiftData

/// A weekly read of the past seven check-ins: average, movement, the strongest and
/// weakest pillars, one quiet pattern, next week's focus, and three suggested actions.
struct WeeklyReviewView: View {
    @Environment(EntitlementManager.self) private var entitlements
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query private var actions: [PillarAction]

    @State private var showPaywall = false

    private var review: WeeklyReview? { WeeklyReviewEngine.review(from: checkIns, actions: actions) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                header
                if !entitlements.isEntitled(to: .weeklyReview) {
                    LockedFeatureCard(feature: .weeklyReview) { showPaywall = true }
                    if review != nil { previewTeaser }
                } else if let review {
                    summaryCard(review)
                    highlightsRow(review)
                    supportedCard(review)
                    patternCard(review)
                    focusCard(review)
                    suggestionsSection(review)
                    closingNote
                } else {
                    gate
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
        .navigationTitle("Weekly Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showPaywall) { PaywallView(highlightTier: .plus) }
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("This week")
                .pillarsOverline(PillarsColors.gold.opacity(0.9))
            Text("Your week,\ngently read.")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
                .lineSpacing(2)
        }
    }

    /// A blurred taste of the review shown beneath the lock, so the value is legible.
    private var previewTeaser: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("What you'll see")
                    .pillarsOverline()
                Text("Your weekly average, strongest and weakest pillars, the one pattern worth noticing, and a focus for the week ahead.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .blur(radius: 0.5)
        .opacity(0.9)
    }

    private func summaryCard(_ review: WeeklyReview) -> some View {
        PillarGlassCard {
            HStack(spacing: PillarsSpacing.l) {
                PillarScoreOrb(score: review.averageSystemScore, caption: "Weekly Avg", size: 132, lineWidth: 10)
                VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                    HStack(spacing: 8) {
                        TrendBadge(delta: review.systemTrend)
                        Text("across the week")
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.tertiaryText)
                    }
                    Text("\(review.checkInCount) check-ins")
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Text("A steady week holds its shape more than it climbs. Movement in either direction is information, not a verdict.")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func highlightsRow(_ review: WeeklyReview) -> some View {
        let strongest = MiniStat(label: "Strongest", pillar: review.strongestPillar, value: review.average(for: review.strongestPillar))
        let weakest = MiniStat(label: "Needs support", pillar: review.weakestPillar, value: review.average(for: review.weakestPillar), emphasized: true)
        let improved: AnyView = {
            if let p = review.mostImprovedPillar {
                return AnyView(MiniStat(label: "Most improved", pillar: p, value: review.average(for: p)))
            }
            return AnyView(MiniStatPlaceholder(label: "Most improved", text: "Holding steady"))
        }()

        return ViewThatFits(in: .horizontal) {
            HStack(spacing: PillarsSpacing.s) { weakest; strongest; improved }
            VStack(spacing: PillarsSpacing.s) { weakest; strongest; improved }
        }
    }

    private func patternCard(_ review: WeeklyReview) -> some View {
        PillarGlassCard(highlight: true) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Label { Text("A pattern") } icon: { Image(systemName: "waveform.path.ecg") }
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                Text(review.hiddenPattern)
                    .font(PillarsTypography.titleSmall)
                    .foregroundStyle(PillarsColors.primaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// What the user actually showed up for this week — the recorded effect of the loop.
    private func supportedCard(_ review: WeeklyReview) -> some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.m) {
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(PillarsColors.gold)
                    .frame(width: 40)
                if let supported = review.mostSupportedPillar {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You showed up most for \(supported.displayName)")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Restoration leaves a mark. This is where you invested.")
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.secondaryText)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No restorations logged yet")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("Completing one this week teaches Pillars what helps you.")
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func focusCard(_ review: WeeklyReview) -> some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text("Highest leverage next week")
                    .pillarsOverline()
                HStack(spacing: PillarsSpacing.m) {
                    PillarIconBadge(pillar: review.highestLeveragePillar, size: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(review.highestLeveragePillar.displayName)
                            .font(PillarsTypography.title)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("Support this one and the rest tend to rise with it.")
                            .font(PillarsTypography.callout)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func suggestionsSection(_ review: WeeklyReview) -> some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(title: "For the week ahead", subtitle: "Three small places to begin.")
            ForEach(review.recommendations) { rec in
                SuggestionCard(recommendation: rec)
            }
        }
    }

    private var closingNote: some View {
        VStack(spacing: PillarsSpacing.xs) {
            Text("You do not need to fix everything.")
                .font(PillarsFont.serif(19, .medium))
                .foregroundStyle(PillarsColors.primaryText)
            Text("Small restoration beats total overhaul.")
                .font(PillarsTypography.callout)
                .foregroundStyle(PillarsColors.secondaryText)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, PillarsSpacing.s)
    }

    private var gate: some View {
        PillarGlassCard(padding: PillarsSpacing.xl) {
            VStack(spacing: PillarsSpacing.m) {
                Image(systemName: "calendar")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(PillarsColors.gold)
                Text("Your review unlocks soon")
                    .font(PillarsTypography.title)
                    .foregroundStyle(PillarsColors.primaryText)
                    .multilineTextAlignment(.center)
                Text("Check in for a couple more days and Pillars will gather the week into one calm read.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Building blocks

/// A compact stat tile for the highlights row.
private struct MiniStat: View {
    let label: String
    let pillar: PillarType
    let value: Double
    var emphasized: Bool = false

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m, highlight: emphasized) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text(label)
                    .pillarsOverline(emphasized ? PillarsColors.gold.opacity(0.9) : PillarsColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                PillarIconBadge(pillar: pillar, size: 36)
                Text(pillar.displayName)
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(String(format: "%.1f", value) + " avg")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct MiniStatPlaceholder: View {
    let label: String
    let text: String

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text(label).pillarsOverline().lineLimit(1).minimumScaleFactor(0.8)
                Image(systemName: "equal.circle")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(PillarsColors.secondaryText)
                Text(text)
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("no single mover")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// A read-only suggestion card (no completion control) for the week ahead.
private struct SuggestionCard: View {
    let recommendation: PillarRecommendation

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(alignment: .top, spacing: PillarsSpacing.m) {
                PillarIconBadge(pillar: recommendation.pillar, size: 46)
                VStack(alignment: .leading, spacing: 6) {
                    Text(recommendation.title)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(recommendation.subtitle)
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1.5)
                    HStack(spacing: 6) {
                        MetaChip(text: recommendation.pillar.displayName, color: recommendation.pillar.color)
                        MetaChip(text: recommendation.mode.label)
                        if recommendation.estimatedMinutes > 0 {
                            MetaChip(text: "\(recommendation.estimatedMinutes) min")
                        }
                    }
                    .padding(.top, 3)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        WeeklyReviewView()
    }
    .environment(AppState())
    .environment(EntitlementManager.preview([.plus]))
    .modelContainer(PreviewData.container)
    .preferredColorScheme(.dark)
}
#endif
