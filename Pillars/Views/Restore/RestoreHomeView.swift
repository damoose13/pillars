import SwiftUI
import SwiftData

/// The Restore tab — the main destination for action. A "Move" is a one-time action for today;
/// a "Ritual" is a repeatable practice; a "Restoration" is the parent concept. This home brings
/// today's moves, recommended rituals, saved rituals, and recent completions into one place.
struct RestoreHomeView: View {
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    private var result: PillarScoreResult? { PillarScoringEngine.result(from: checkIns) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    header

                    if let result {
                        TodayRestorationsView(result: result)
                        RecommendedRitualsSection(result: result)
                    } else {
                        RestoreEmptyCard(icon: "checklist",
                                         title: "Restorations appear after your first check-in",
                                         message: "Check in and Pillars will suggest a few small, restoring actions.")
                    }

                    SavedRitualsSection()
                    CompletedRestorationsSection()
                    ritualsLibraryLink
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.xl)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("Restore")
                .pillarsOverline(PillarsColors.gold.opacity(0.9))
            Text("Restore.")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
            Text("One small action is enough to shift the day.")
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var ritualsLibraryLink: some View {
        NavigationLink {
            RitualLibraryView()
        } label: {
            PillarGlassCard(padding: PillarsSpacing.m) {
                HStack(spacing: PillarsSpacing.m) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(PillarsColors.gold)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(PillarsColors.gold.opacity(0.12)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("The Ritual Library")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("Every repeatable practice")
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.secondaryText)
                    }
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

#if DEBUG
#Preview {
    RestoreHomeView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
