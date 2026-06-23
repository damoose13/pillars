import SwiftUI
import SwiftData

#if DEBUG
/// In-memory SwiftData container with a couple of seeded check-ins, used by `#Preview`s.
enum PreviewData {
    @MainActor static let container: ModelContainer = {
        let schema = Schema([DailyCheckIn.self, PillarAction.self, CircleGroup.self, SharedWin.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext

        // Yesterday — slightly lower, to produce visible trends.
        let yesterday = DailyCheckIn(
            date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
            bodyScore: 4, fuelScore: 3, sleepScore: 3, recoverScore: 3,
            mindScore: 3, connectScore: 1, spaceScore: 3, purposeScore: 2
        )
        // Today — Connect and Purpose are the soft spots.
        let today = DailyCheckIn(
            date: .now,
            bodyScore: 4, fuelScore: 3, sleepScore: 4, recoverScore: 3,
            mindScore: 3, connectScore: 2, spaceScore: 4, purposeScore: 2
        )
        context.insert(yesterday)
        context.insert(today)
        return container
    }()
}
#endif
