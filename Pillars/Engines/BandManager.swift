import Foundation
import Observation

/// The app-side of the **Pillars Band**: pairing state and the latest physiological read.
///
/// The band hardware can't exist in this SwiftUI repo, so this is the integration *seam*. When
/// paired it currently surfaces a simulated read; once the band (or Apple Health) is wired in,
/// only `sync()` changes — every consumer (Devices screen, ReadinessEngine, Training adjustments)
/// already speaks `BandSignals` and is unaffected.
///
/// Default is **unpaired**: the app never fabricates health data until the user opts in.
@MainActor
@Observable
final class BandManager {
    private(set) var isPaired: Bool
    private(set) var latest: BandSignals?
    private(set) var isSyncing = false

    private enum Keys { static let paired = "pillars.bandPaired" }

    init() {
        isPaired = UserDefaults.standard.bool(forKey: Keys.paired)
        if isPaired { latest = BandSignals.simulated(capturedAt: .now) }
    }

    /// Pair the band. Real hardware would run BLE discovery; here we simulate a successful pair
    /// and take a first read.
    func pair() async {
        isSyncing = true
        isPaired = true
        UserDefaults.standard.set(true, forKey: Keys.paired)
        await sync()
        isSyncing = false
    }

    /// Forget the band and drop its data from the session.
    func unpair() {
        isPaired = false
        latest = nil
        UserDefaults.standard.set(false, forKey: Keys.paired)
    }

    /// Pull the latest read from the band. Simulated until hardware/HealthKit wiring lands.
    func sync() async {
        guard isPaired else { return }
        latest = BandSignals.simulated(capturedAt: .now)
    }

    /// The readiness read for the latest signals, if any.
    var readiness: ReadinessReading? {
        latest.flatMap(ReadinessEngine.reading(from:))
    }

    /// A paired manager seeded with a simulated read — for previews and CI capture only.
    static func previewPaired() -> BandManager {
        let manager = BandManager()
        manager.isPaired = true
        manager.latest = BandSignals.simulated(capturedAt: .now)
        return manager
    }
}
