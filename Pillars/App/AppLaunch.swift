import SwiftUI
import SwiftData

/// Launch-time configuration.
///
/// In normal use this is inert. When the app is launched with `--uitest` (used by the
/// macOS CI screenshot job), it boots into a seeded, onboarded state with all features
/// unlocked and an optional starting tab via `--screen <today|map|moves|circle|settings>`.
/// This lets CI capture any main screen deterministically without UI automation. The
/// seeding path is DEBUG-only and never ships in release.
enum AppLaunch {

    static var isUITest: Bool {
        #if DEBUG
        return CommandLine.arguments.contains("--uitest")
        #else
        return false
        #endif
    }

    /// A specific screen to render directly (for CI page captures). DEBUG-only.
    static var captureRoute: String? {
        #if DEBUG
        guard let idx = CommandLine.arguments.firstIndex(of: "--route"),
              idx + 1 < CommandLine.arguments.count else { return nil }
        return CommandLine.arguments[idx + 1]
        #else
        return nil
        #endif
    }

    static var initialTab: AppTab {
        guard let idx = CommandLine.arguments.firstIndex(of: "--screen"),
              idx + 1 < CommandLine.arguments.count else { return .today }
        switch CommandLine.arguments[idx + 1] {
        case "map": return .map
        case "moves": return .moves
        case "circle": return .circle
        case "settings": return .settings
        default: return .today
        }
    }

    @MainActor static func makeAppState() -> AppState {
        let state = AppState()
        if isUITest {
            state.hasCompletedOnboarding = true
            state.selectedTab = initialTab
        }
        return state
    }

    @MainActor static func makeEntitlements() -> EntitlementManager {
        let manager = EntitlementManager()
        if isUITest { manager.setMockTiers([.plus, .circlePass]) }
        return manager
    }

    @MainActor static func makeContainer() -> ModelContainer {
        let schema = Schema(versionedSchema: PillarsSchemaV1.self)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITest)
        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: PillarsMigrationPlan.self,
                configurations: [config]
            )
            if isUITest { seed(container.mainContext) }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    @MainActor private static func seed(_ context: ModelContext) {
        let calendar = Calendar.current
        let yesterday = DailyCheckIn(
            date: calendar.date(byAdding: .day, value: -1, to: .now) ?? .now,
            bodyScore: 4, fuelScore: 3, sleepScore: 3, recoverScore: 3,
            mindScore: 3, connectScore: 1, spaceScore: 3, purposeScore: 2)
        let today = DailyCheckIn(
            date: .now,
            bodyScore: 4, fuelScore: 3, sleepScore: 4, recoverScore: 3,
            mindScore: 3, connectScore: 2, spaceScore: 4, purposeScore: 2)
        context.insert(yesterday)
        context.insert(today)

        context.insert(PillarAction(
            title: "Reach one person honestly", subtitle: "A short, real message.",
            pillar: .connect, isCompleted: true, completedAt: .now))

        let circle = CircleGroup(name: "My Circle")
        context.insert(circle)
        context.insert(CircleMember(
            name: "You", colorIndex: 0, isYou: true,
            bodyScore: 4, fuelScore: 3, sleepScore: 4, recoverScore: 3,
            mindScore: 3, connectScore: 2, spaceScore: 4, purposeScore: 2))
        context.insert(CircleMember.mock(name: "Maya", colorIndex: 1))
        context.insert(CircleMember.mock(name: "Theo", colorIndex: 2))
        context.insert(SharedWin(
            title: "Walked at sunrise", pillar: .body,
            note: "Cleared my head before the day started.", authorName: "Maya"))

        try? context.save()
    }
}
