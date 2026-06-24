import SwiftUI
import SwiftData

/// Section: restorations completed recently — what you showed up for.
struct CompletedRestorationsSection: View {
    @Query private var actions: [PillarAction]

    private var completed: [PillarAction] {
        actions
            .filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(title: "Completed Recently", subtitle: "What you showed up for.")
            if completed.isEmpty {
                RestoreEmptyCard(icon: "checkmark.seal",
                                 title: "Nothing completed yet",
                                 message: "Complete a restoration and it'll appear here.")
            } else {
                ForEach(completed) { action in
                    CompletedRestorationRow(action: action)
                }
            }
        }
    }
}
