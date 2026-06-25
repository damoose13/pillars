import Foundation

/// A point-in-time physiological read from the **Pillars Band**. Until the hardware ships these
/// come from Apple Health or a simulated source; the shape is identical, so the rest of the app
/// (Devices screen, ReadinessEngine, Training adjustments) never needs to know the origin.
///
/// Every field is optional: a band that hasn't measured something yet, or a metric Health can't
/// provide, simply leaves it `nil`. Absence never pushes a pillar down — it's just unknown.
struct BandSignals: Hashable {
    /// Resting heart rate, beats per minute. Lower trends with better recovery.
    var restingHeartRate: Int?
    /// Heart-rate variability (SDNN), milliseconds. Higher trends with better recovery.
    var heartRateVariability: Int?
    /// Hours asleep last night.
    var sleepHours: Double?
    /// A 0–100 sleep-quality score (duration + consistency + depth), as the band would compute it.
    var sleepScore: Int?
    /// Breaths per minute overnight, if measured.
    var respiratoryRate: Double?
    /// When this read was taken.
    var capturedAt: Date

    /// Whether there's any signal at all to show.
    var hasAnySignal: Bool {
        restingHeartRate != nil || heartRateVariability != nil
            || sleepHours != nil || sleepScore != nil || respiratoryRate != nil
    }

    /// A stable, plausible read used for simulation and CI screenshots — deterministic so the
    /// Devices screen looks the same every build. Tuned to read as a calm, well-recovered morning.
    static func simulated(capturedAt: Date) -> BandSignals {
        BandSignals(
            restingHeartRate: 54,
            heartRateVariability: 68,
            sleepHours: 7.4,
            sleepScore: 82,
            respiratoryRate: 13.6,
            capturedAt: capturedAt
        )
    }
}
