import SwiftUI
import SwiftData

@main
struct PillarsApp: App {
    /// App-level, observable preferences/state.
    @State private var appState = AppState()
    /// Subscription state & feature gating (StoreKit 2, with offline mock mode).
    @State private var entitlements = EntitlementManager()
    /// Local daily check-in reminder.
    @State private var notifications = NotificationManager()

    /// Local-first SwiftData store. Circle models are registered now so the schema is
    /// stable, even though the Circle feature layer ships later.
    let modelContainer: ModelContainer = {
        let schema = Schema([
            DailyCheckIn.self,
            PillarAction.self,
            CircleGroup.self,
            CircleMember.self,
            SharedWin.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(entitlements)
                .environment(notifications)
                .tint(PillarsColors.gold)
                .preferredColorScheme(.dark)
                .task { await entitlements.start() }
                .task { await notifications.refresh() }
        }
        .modelContainer(modelContainer)
    }
}
