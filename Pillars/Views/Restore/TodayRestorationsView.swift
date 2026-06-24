import SwiftUI
import SwiftData

/// Section: the 1–3 restoring moves recommended for today, with completion + reflection.
struct TodayRestorationsView: View {
    let result: PillarScoreResult

    @Environment(\.modelContext) private var context
    @Query private var actions: [PillarAction]
    @State private var reflectingRec: PillarRecommendation?

    var body: some View {
        let recs = RestorationEngine.restorations(for: result)
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(title: "Today's Restorations",
                          subtitle: "One small action is enough to shift the day.")
            ForEach(recs) { rec in
                PillarMoveCard(
                    recommendation: rec,
                    isCompleted: RestorationLog.isCompleted(rec, in: actions),
                    onToggle: {
                        let wasCompleted = RestorationLog.isCompleted(rec, in: actions)
                        RestorationLog.toggle(rec, in: actions, context: context)
                        if !wasCompleted { reflectingRec = rec }
                    }
                )
            }
        }
        .sheet(item: $reflectingRec) { rec in
            RestorationReflectionView(recommendation: rec)
        }
    }
}
