import SwiftUI

/// The main shell once onboarded: Today, Map, Moves, Settings.
struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            TodayDashboardView()
                .tag(AppTab.today)
                .tabItem { Label("Today", systemImage: "gauge.medium") }

            PillarMapView()
                .tag(AppTab.map)
                .tabItem { Label("Map", systemImage: "circle.hexagongrid") }

            TodayMovesView()
                .tag(AppTab.moves)
                .tabItem { Label("Restore", systemImage: "checklist") }

            CircleHomeView()
                .tag(AppTab.circle)
                .tabItem { Label("Circle", systemImage: "person.3") }

            SettingsView()
                .tag(AppTab.settings)
                .tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
        }
        .tint(PillarsColors.gold)
    }
}
