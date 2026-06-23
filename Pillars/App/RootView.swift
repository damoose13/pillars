import SwiftUI

/// Routes between the onboarding flow and the main app shell based on `AppState`.
struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            if appState.hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingContainerView()
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.4), value: appState.hasCompletedOnboarding)
    }
}
