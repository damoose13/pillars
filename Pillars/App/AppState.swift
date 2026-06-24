import SwiftUI
import Observation

/// The main tabs of the app shell.
enum AppTab: Hashable {
    case today, moves, circle, settings
}

/// Lightweight, observable app-level state: onboarding status, the selected tab, and the
/// custom name for the Purpose pillar. Persisted to `UserDefaults` (not health data — just
/// preferences), keeping all actual check-in data in SwiftData.
@Observable
final class AppState {

    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
    }

    /// Custom name for the Purpose pillar ("" means use the default).
    var purposeAlias: String {
        didSet {
            defaults.set(purposeAlias, forKey: Keys.purposeAlias)
            PillarNaming.shared.purposeAlias = purposeAlias.isEmpty ? nil : purposeAlias
        }
    }

    /// Opt-in to spiritual practices (temple, prayer, seva). Off by default — secular-first.
    var spiritualRitualsEnabled: Bool {
        didSet {
            defaults.set(spiritualRitualsEnabled, forKey: Keys.spiritual)
            ContentPreferences.shared.spiritualRitualsEnabled = spiritualRitualsEnabled
        }
    }

    /// Opt-in to secular community framings (service, volunteering, group gatherings). Off by
    /// default — independent of the spiritual toggle.
    var communityContentEnabled: Bool {
        didSet {
            defaults.set(communityContentEnabled, forKey: Keys.community)
            ContentPreferences.shared.communityContentEnabled = communityContentEnabled
        }
    }

    var selectedTab: AppTab = .today

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.onboarding)
        let alias = defaults.string(forKey: Keys.purposeAlias) ?? ""
        self.purposeAlias = alias
        self.spiritualRitualsEnabled = defaults.bool(forKey: Keys.spiritual)
        self.communityContentEnabled = defaults.bool(forKey: Keys.community)
        // `didSet` doesn't fire during init, so seed the resolvers explicitly.
        PillarNaming.shared.purposeAlias = alias.isEmpty ? nil : alias
        ContentPreferences.shared.spiritualRitualsEnabled = defaults.bool(forKey: Keys.spiritual)
        ContentPreferences.shared.communityContentEnabled = defaults.bool(forKey: Keys.community)
    }

    func completeOnboarding() {
        withAnimation(.smooth) { hasCompletedOnboarding = true }
        selectedTab = .today
    }

    /// Resets onboarding so the welcome flow is shown again (used by "clear data").
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }

    private enum Keys {
        static let onboarding = "pillars.hasCompletedOnboarding"
        static let purposeAlias = "pillars.purposeAlias"
        static let spiritual = "pillars.spiritualRitualsEnabled"
        static let community = "pillars.communityContentEnabled"
    }
}
