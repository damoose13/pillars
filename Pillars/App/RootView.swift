import SwiftUI

/// Routes between the onboarding flow and the main app shell based on `AppState`.
struct RootView: View {
    @Environment(AppState.self) private var appState
    @State private var showSplash = true

    var body: some View {
        #if DEBUG
        if let route = AppLaunch.captureRoute {
            CaptureRoot(route: route)
        } else {
            shell
        }
        #else
        shell
        #endif
    }

    private var shell: some View {
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
        .overlay {
            if showSplash {
                LaunchView(onFinished: { withAnimation(.smooth(duration: 0.55)) { showSplash = false } })
                    .transition(.opacity)
            }
        }
    }
}
