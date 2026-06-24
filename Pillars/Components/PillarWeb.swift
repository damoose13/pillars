import SwiftUI

/// How a `DynamicPillarWebView` is being used — drives size, labels, and emphasis.
enum PillarWebMode {
    case background  // faint brand motif
    case mini        // tiny, in lists
    case standard    // map / panels
    case hero        // Today's centerpiece
    case weekly      // weekly average
    case blurred     // privacy-safe Circle trend
}

/// One pillar's score for the web. Scores stay 1–5 internally; the UI leans on `state`.
struct PillarWebScore: Identifiable, Equatable {
    let pillar: PillarType
    let score: Int

    var id: PillarType { pillar }
    var state: PillarState { PillarState.from(score: score) }
    var normalized: CGFloat { CGFloat(max(1, min(score, 5))) / 5.0 }

    /// Build the full ordered set from a scores dictionary.
    static func all(from scores: [PillarType: Int]) -> [PillarWebScore] {
        PillarType.allCases.map { PillarWebScore(pillar: $0, score: scores[$0] ?? 3) }
    }
}

/// A closed polygon through arbitrary points (the web's grid rings and data shape).
struct PolygonShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() { path.addLine(to: point) }
        path.closeSubpath()
        return path
    }
}

extension PillarType {
    /// One calm, secular line of insight for the selected pillar, tuned to its state.
    func insightCopy(for state: PillarState) -> String {
        let needsCare = state.isAskingForSupport
        switch self {
        case .body:
            return needsCare ? "Your body may need gentle movement before the day asks for more."
                             : "Your body is helping hold the rest of the structure."
        case .fuel:
            return needsCare ? "Steady energy starts with simple nourishment, not perfection."
                             : "Fuel is supporting your rhythm today."
        case .sleep:
            return needsCare ? "Your system may need a softer evening and a cleaner wind-down."
                             : "Sleep is giving the day a stronger base."
        case .recover:
            return needsCare ? "Recovery is asking for less force and more restoration."
                             : "Recovery is helping your system stay steady."
        case .mind:
            return needsCare ? "Your mind may be carrying too many open loops."
                             : "Your mind is holding enough clarity to support the day."
        case .connect:
            return needsCare ? "One honest message can restore more than it costs."
                             : "Connection is helping the day feel less carried alone."
        case .space:
            return needsCare ? "Your environment may be pulling attention from what matters."
                             : "Your space is helping the rest of the day breathe."
        case .purpose:
            return needsCare ? "Direction may need one small action aligned with what matters."
                             : "Purpose is giving the day a clearer line."
        }
    }
}
