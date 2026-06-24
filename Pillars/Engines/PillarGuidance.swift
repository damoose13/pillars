import Foundation

/// Calm, non-prescriptive supports for each pillar — the "ideas" surfaced when a pillar is
/// selected on the web, and on its detail screen. Secular by default; the Purpose pillar's
/// middle line adapts to the spiritual-content preference.
enum PillarGuidance {
    static func tips(for pillar: PillarType) -> [String] {
        switch pillar {
        case .body:
            return ["A twenty-minute walk counts as a win.",
                    "Move before you ask yourself whether you feel like it.",
                    "Strength once or twice a week keeps the rest steady."]
        case .fuel:
            return ["Water first; energy follows hydration.",
                    "Anchor meals around protein.",
                    "One unhurried meal beats three rushed ones."]
        case .sleep:
            return ["Protect a consistent bedtime.",
                    "Dim the lights an hour before sleep.",
                    "Tomorrow is built the night before."]
        case .recover:
            return ["A few slow breaths reset the nervous system.",
                    "Gentle mobility on the days between effort.",
                    "Rest is part of the work, not a break from it."]
        case .mind:
            return ["Single-task one block with no inputs.",
                    "Step outside for ten minutes.",
                    "Name the noise; it loses some of its grip."]
        case .connect:
            return ["One honest message can restore a day.",
                    "Reach out before you feel ready.",
                    "Closeness costs less than it seems to."]
        case .space:
            return ["Reset one surface — bed, desk, or floor.",
                    "Outer order, inner calm.",
                    "Finish one small thing fully."]
        case .purpose:
            let middle = ContentPreferences.shared.spiritualRitualsEnabled
                ? "Five minutes to reflect, pray, or give thanks."
                : "Five minutes to reflect or name what you're grateful for."
            return ["Write the one thing that would make today count.",
                    middle,
                    "Direction matters more than speed."]
        }
    }
}
