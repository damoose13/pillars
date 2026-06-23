import SwiftUI

/// Drives the three-step onboarding: Welcome → Philosophy → Baseline.
struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @State private var step: Step = .welcome

    enum Step { case welcome, philosophy, baseline }

    var body: some View {
        ZStack {
            switch step {
            case .welcome:
                WelcomeView(onBegin: { advance(to: .philosophy) })
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading).combined(with: .opacity)))
            case .philosophy:
                PillarPhilosophyView(
                    onContinue: { advance(to: .baseline) },
                    onBack: { advance(to: .welcome) }
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            case .baseline:
                BaselineAssessmentView(
                    onComplete: { appState.completeOnboarding() },
                    onBack: { advance(to: .philosophy) }
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .pillarsBackground()
    }

    private func advance(to next: Step) {
        withAnimation(.smooth(duration: 0.4)) { step = next }
    }
}
