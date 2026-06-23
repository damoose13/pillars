import SwiftUI
import SwiftData

#if DEBUG
/// In-memory SwiftData container with a couple of seeded check-ins, used by `#Preview`s.
enum PreviewData {
    @MainActor static let container: ModelContainer = {
        let schema = Schema([DailyCheckIn.self, PillarAction.self, CircleGroup.self, CircleMember.self, SharedWin.self])
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

        // A couple of completed restorations, so "most supported" has something to show.
        context.insert(PillarAction(title: "Reach one person honestly", subtitle: "A short, real message.",
                                    pillar: .connect, isCompleted: true, completedAt: .now))
        context.insert(PillarAction(title: "Clear one surface", subtitle: "Bed, desk, or floor.",
                                    pillar: .space, isCompleted: true, completedAt: .now))

        // A sample Circle of three (you + two), so Circle previews have content.
        let circle = CircleGroup(name: "My Circle")
        context.insert(circle)
        let you = CircleMember(name: "You", colorIndex: 0, isYou: true,
                               bodyScore: 4, fuelScore: 3, sleepScore: 4, recoverScore: 3,
                               mindScore: 3, connectScore: 2, spaceScore: 4, purposeScore: 2)
        context.insert(you)
        context.insert(CircleMember.mock(name: "Maya", colorIndex: 1))
        context.insert(CircleMember.mock(name: "Theo", colorIndex: 2))
        context.insert(SharedWin(title: "Walked at sunrise", pillar: .body,
                                 note: "Cleared my head before the day started.", authorName: "Maya"))
        return container
    }()
}
#endif
