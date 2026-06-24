import Foundation

/// Process-wide content preferences that the pure engines read without taking new
/// parameters (mirrors the `PillarNaming` pattern). Backed by `UserDefaults` via `AppState`.
final class ContentPreferences {
    static let shared = ContentPreferences()
    private init() {}

    /// When off (the default), no temple / prayer / seva language appears anywhere —
    /// restorations and rituals stay fully secular. Users who want spiritual practices
    /// opt in from Settings.
    var spiritualRitualsEnabled = false

    /// When off (the default), suggestions stay individual. Turning it on adds secular
    /// community framings — service, volunteering, group gatherings. Independent of the
    /// spiritual toggle, so each can be enabled on its own.
    var communityContentEnabled = false
}

extension ContentPreferences {
    /// Opt-in example framings for Purpose suggestions. Secular and individual by default;
    /// spiritual and community options appear only when their own toggles are on.
    var purposeResetExamples: String {
        var parts: [String] = []
        if spiritualRitualsEnabled { parts.append("a prayer or temple moment") }
        if communityContentEnabled { parts.append("a service or community activity") }
        parts.append("a gratitude round")
        parts.append("a quiet reflection")
        return parts.joined(separator: ", ")
    }
}
