import SwiftUI
import SwiftData

@main
struct PillarsApp: App {
    /// App-level, observable preferences/state.
    @State private var appState = AppState()

    /// Local-first SwiftData store. Circle models are registered now so the schema is
    /// stable, even though the Circle feature layer ships later.
    let modelContainer: ModelContainer = {
        let schema = Schema([
            DailyCheckIn.self,
            PillarAction.self,
            CircleGroup.self,
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
                .tint(PillarsColors.gold)
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
