import SwiftUI
import SwiftData

@main
struct PillarsApp: App {
    /// App-level, observable preferences/state.
    @State private var appState = AppLaunch.makeAppState()
    /// Subscription state & feature gating (StoreKit 2, with offline mock mode).
    @State private var entitlements = AppLaunch.makeEntitlements()
    /// Local daily check-in reminder.
    @State private var notifications = NotificationManager()

    /// Local-first SwiftData store (in-memory + seeded under `--uitest`).
    let modelContainer: ModelContainer = AppLaunch.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(entitlements)
                .environment(notifications)
                .tint(PillarsColors.gold)
                .preferredColorScheme(.dark)
                // Allow larger text for accessibility, but clamp extremes so the editorial
                // layout never breaks.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .task { await entitlements.start() }
                .task { await notifications.refresh() }
        }
        .modelContainer(modelContainer)
    }
}
