import Foundation

/// How ready the body looks *today*, distilled from band signals. This is the **Signal** side of
/// Felt + Signal: it informs, it never overrides what the user reports. Rule-based and calm —
/// no diagnoses, no medical claims, just a gentle read that can shape today's training.
enum ReadinessBand: String, Hashable {
    case ready, steady, easeIn, holdBack

    var label: String {
        switch self {
        case .ready:    return "Ready"
        case .steady:   return "Steady"
        case .easeIn:   return "Ease in"
        case .holdBack: return "Hold back"
        }
    }
}

/// A readiness read: a 0–100 score, a band, and plain language.
struct ReadinessReading: Hashable {
    let score: Int
    let band: ReadinessBand
    let headline: String
    let detail: String
}

enum ReadinessEngine {

    /// A readiness read from whatever band signals are present, or `nil` if there's nothing to
    /// go on. Components are weighted and renormalised over only the metrics we actually have.
    static func reading(from s: BandSignals) -> ReadinessReading? {
        var weighted = 0.0, totalWeight = 0.0
        func add(_ value: Double?, weight: Double) {
            guard let value else { return }
            weighted += value * weight
            totalWeight += weight
        }

        add(s.heartRateVariability.map { norm(Double($0), lo: 30, hi: 90) }, weight: 0.30)
        add(s.restingHeartRate.map { norm(Double($0), lo: 70, hi: 45) }, weight: 0.20) // inverted: lower is better
        add(s.sleepHours.map { norm($0, lo: 5, hi: 8) }, weight: 0.20)
        add(s.sleepScore.map { Double($0) }, weight: 0.30)

        guard totalWeight > 0 else { return nil }
        let score = Int((weighted / totalWeight).rounded())
        let band = band(for: score)
        return ReadinessReading(score: score, band: band, headline: band.label, detail: detail(for: band))
    }

    /// Signal-side 1–5 suggestions the band can speak to: Recover and Sleep. Body is left to
    /// actual training, not inferred from a resting read. Empty when no signal is present.
    static func signalScores(from s: BandSignals) -> [PillarType: Int] {
        var out: [PillarType: Int] = [:]
        if let reading = reading(from: s) {
            out[.recover] = score1to5(for: reading.band)
        }
        if let hours = s.sleepHours {
            out[.sleep] = hours >= 7.5 ? 5 : hours >= 6.5 ? 4 : hours >= 5.5 ? 3 : hours >= 4.5 ? 2 : 1
        } else if let sleepScore = s.sleepScore {
            out[.sleep] = sleepScore >= 85 ? 5 : sleepScore >= 70 ? 4 : sleepScore >= 55 ? 3 : sleepScore >= 40 ? 2 : 1
        }
        return out
    }

    // MARK: Helpers

    /// Linear map of `value` from `lo`→0, `hi`→100, clamped. `hi` may be below `lo` to invert.
    private static func norm(_ value: Double, lo: Double, hi: Double) -> Double {
        guard lo != hi else { return 50 }
        let t = (value - lo) / (hi - lo)
        return min(100, max(0, t * 100))
    }

    private static func band(for score: Int) -> ReadinessBand {
        switch score {
        case 75...:  return .ready
        case 60..<75: return .steady
        case 45..<60: return .easeIn
        default:      return .holdBack
        }
    }

    private static func score1to5(for band: ReadinessBand) -> Int {
        switch band {
        case .ready:    return 5
        case .steady:   return 4
        case .easeIn:   return 3
        case .holdBack: return 2
        }
    }

    private static func detail(for band: ReadinessBand) -> String {
        switch band {
        case .ready:
            return "Recovery signals look strong. A good day to train as planned."
        case .steady:
            return "Solid recovery. Train as planned and listen as you go."
        case .easeIn:
            return "Recovery is a little down. Keep the load, but trim the volume."
        case .holdBack:
            return "Your body is still recovering. Favor mobility, a walk, or rest today."
        }
    }
}
