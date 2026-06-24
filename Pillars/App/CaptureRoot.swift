#if DEBUG
import SwiftUI

/// Renders a single screen directly, bypassing the tab shell — used only by the CI page
/// capture job (`--uitest --route <name>`) so every page can be screenshotted
/// deterministically, including ones normally reached via navigation or sheets.
struct CaptureRoot: View {
    let route: String

    var body: some View {
        switch route {
        case "launch":
            LaunchView()

        // Onboarding (normally hosted by OnboardingContainerView, which supplies the bg).
        case "welcome":
            WelcomeView(onBegin: {}).pillarsBackground()
        case "philosophy":
            PillarPhilosophyView(onContinue: {}, onBack: {}).pillarsBackground()
        case "baseline":
            BaselineAssessmentView(onComplete: {}, onBack: {}).pillarsBackground()

        // Today flow.
        case "today":
            TodayDashboardView()
        case "checkin":
            DailyCheckInView()
        case "weekly":
            NavigationStack { WeeklyReviewView() }
        case "history":
            NavigationStack { HistoryView() }

        // Map flow.
        case "map":
            PillarMapView()
        case "pillardetail":
            NavigationStack { PillarDetailView(pillar: .connect) }

        // Moves / rituals.
        case "moves":
            TodayMovesView()
        case "rituals":
            NavigationStack { RitualLibraryView() }
        case "ritualdetail":
            NavigationStack { RitualDetailView(ritual: RitualLibrary.ritual(id: "gratitude-circle") ?? RitualLibrary.all[0]) }

        // Circle flow.
        case "circle":
            CircleHomeView()
        case "privacy":
            PrivacyExplainerView()
        case "sharedwin":
            SharedWinComposerView()
        case "sharedreset":
            SharedResetFlowView()

        // Monetization / settings.
        case "paywall":
            PaywallView()
        case "settings":
            SettingsView()

        default:
            TodayDashboardView()
        }
    }
}
#endif
