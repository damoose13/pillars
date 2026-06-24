import Foundation

/// Closes the restoration loop. The reflection sheet records a private "did it help?" on each
/// completed restoration; this reads that history back so Pillars can gently surface what has
/// actually worked for *this* person — and quietly order it first.
///
/// It only ever reinforces what helped. It never shames what didn't: a "Not really" simply
/// carries no positive weight, it never produces a negative label.
enum RestorationEffectiveness {

    /// True when this person's own most recent reflection on this exact restoration was positive
    /// ("Yes — that helped"). Used to show a soft "Helped you before" cue.
    static func helpedBefore(_ recommendation: PillarRecommendation, in actions: [PillarAction]) -> Bool {
        let reflections: [(date: Date, helped: String)] = actions.compactMap { action in
            guard action.title == recommendation.title,
                  action.pillar == recommendation.pillar,
                  let helped = action.helped else { return nil }
            return (action.completedAt ?? action.createdAt, helped)
        }
        guard let latest = reflections.max(by: { $0.date < $1.date }) else { return false }
        return latest.helped.hasPrefix("Yes")
    }

    /// Today's restorations re-ordered so what's helped before surfaces first. Stable otherwise,
    /// so the engine's score-driven priority is preserved among equals.
    static func ordered(_ recs: [PillarRecommendation], by actions: [PillarAction]) -> [PillarRecommendation] {
        recs.enumerated()
            .sorted { lhs, rhs in
                let l = helpedBefore(lhs.element, in: actions)
                let r = helpedBefore(rhs.element, in: actions)
                if l != r { return l && !r }
                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }
}
