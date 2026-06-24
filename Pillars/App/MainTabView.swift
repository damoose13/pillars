import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// The main shell once onboarded: Today, Map, Restore, Circle, Settings.
struct MainTabView: View {
    @Environment(AppState.self) private var appState

    init() {
        #if canImport(UIKit)
        // A premium, materialised tab bar that floats over the warm ground rather than a flat
        // opaque bar — blurred, with a hairline top edge and muted unselected items.
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.045, blue: 0.06, alpha: 0.55)
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.10)

        let muted = UIColor(red: 0.50, green: 0.48, blue: 0.44, alpha: 1)
        for item in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            item.normal.iconColor = muted
            item.normal.titleTextAttributes = [.foregroundColor: muted]
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }

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
