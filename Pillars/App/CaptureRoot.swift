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
        case "reveal":
            FoundationRevealView(scores: [
                .body: 4, .fuel: 3, .sleep: 4, .recover: 3,
                .mind: 4, .connect: 2, .space: 4, .purpose: 5
            ])

        // Today flow.
        case "today":
            TodayDashboardView()
        case "checkin":
            DailyCheckInView()
        case "weekly":
            NavigationStack { WeeklyReviewView() }
        case "history":
            NavigationStack { HistoryView() }

        // Pillar detail.
        case "pillardetail":
            NavigationStack { PillarDetailView(pillar: .connect) }

        // Restore / rituals.
        case "moves":
            RestoreHomeView()
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
