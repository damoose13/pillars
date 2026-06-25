import Foundation

/// One exercise as adjusted for *today* — the plan met by the body's current readiness.
struct PlannedSet: Identifiable, Hashable {
    var id: String { exercise.id }
    let exercise: Exercise
    let sets: Int
    let reps: Int
    let load: Int?
}

/// A session ready to train: the plan, today's adjusted sets, the readiness it was shaped by,
/// and a plain-language note when recovery changed the prescription.
struct WorkoutSession: Hashable {
    let plan: WorkoutPlan
    let sets: [PlannedSet]
    let readiness: ReadinessReading?
    let adjustmentNote: String?
}

/// FitOS Training Engine. Turns a plan into today's session, **matched to readiness** — the
/// bridge between the Pillars Band and a workout. Training is a restoration when it fits the
/// body's current state, so low recovery trims volume (and protects load) rather than pushing.
enum TrainingEngine {

    /// Build today's session from a plan and an optional readiness read.
    /// - ready / steady: as planned.
    /// - ease in: hold the load, drop one set per lift.
    /// - hold back: hold the load, drop to a minimum, and suggest a lighter focus.
    static func session(for plan: WorkoutPlan, readiness: ReadinessReading?) -> WorkoutSession {
        let band = readiness?.band ?? .steady
        let setDelta: Int
        let note: String?
        switch band {
        case .ready:
            setDelta = 0; note = nil
        case .steady:
            setDelta = 0; note = nil
        case .easeIn:
            setDelta = -1
            note = "Recovery is a little down — held the load, trimmed a set per lift."
        case .holdBack:
            setDelta = -2
            note = "Low recovery — kept it light. Mobility or a walk may serve you better today."
        }
        let sets = plan.exercises.map { ex in
            PlannedSet(exercise: ex, sets: max(1, ex.targetSets + setDelta), reps: ex.targetReps, load: ex.suggestedLoad)
        }
        return WorkoutSession(plan: plan, sets: sets, readiness: readiness, adjustmentNote: note)
    }

    /// Which plan to suggest today. With low readiness, steer toward the Mobility Reset; otherwise
    /// the first strength plan. (Kept simple — the user always chooses.)
    static func suggestedPlan(readiness: ReadinessReading?) -> WorkoutPlan {
        if readiness?.band == .holdBack { return WorkoutLibrary.mobility }
        return WorkoutLibrary.upperStrength
    }

    /// Pillar effects after completing a session, as bounded ±1 nudges to today's check-in:
    /// Body and Mind lift, Recover dips (you just spent). Mobility doesn't tax recovery.
    static func pillarDeltas(for session: WorkoutSession) -> [PillarType: Int] {
        if session.plan.id == WorkoutLibrary.mobility.id {
            return [.body: +1, .recover: +1, .mind: +1]
        }
        return [.body: +1, .mind: +1, .recover: -1]
    }

    /// The natural next restoration after training: refuel. Reuses the recommendation type so it
    /// flows through the same cards and reflection as any other restoration.
    static func postWorkoutRestoration() -> PillarRecommendation {
        PillarRecommendation(
            title: "Refuel within the hour",
            subtitle: "About 40g of protein and a glass of water. You just spent — put something back.",
            pillar: .fuel, mode: .solo, estimatedMinutes: 10, emotionalTone: .grounding)
    }
}
