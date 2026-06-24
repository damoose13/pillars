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
}
