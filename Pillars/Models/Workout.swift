import Foundation

/// One movement in a workout. Value type — plans and the library are static content, not stored.
struct Exercise: Identifiable, Hashable {
    let id: String
    let name: String
    let targetSets: Int
    let targetReps: Int
    /// Suggested working load in lb, when applicable (`nil` for bodyweight / mobility).
    let suggestedLoad: Int?

    init(_ name: String, sets: Int, reps: Int, load: Int? = nil) {
        self.id = name
        self.name = name
        self.targetSets = sets
        self.targetReps = reps
        self.suggestedLoad = load
    }
}

/// A named training session focused on a movement pattern. Always a Body-pillar restoration.
struct WorkoutPlan: Identifiable, Hashable {
    let id: String
    let name: String
    let focus: String
    let estimatedMinutes: Int
    let exercises: [Exercise]

    init(name: String, focus: String, minutes: Int, exercises: [Exercise]) {
        self.id = name
        self.name = name
        self.focus = focus
        self.estimatedMinutes = minutes
        self.exercises = exercises
    }
}

/// A small, opinionated set of plans. Calm and finite — not a programming app.
enum WorkoutLibrary {
    static let all: [WorkoutPlan] = [upperStrength, lowerStrength, fullBody, mobility]

    static let upperStrength = WorkoutPlan(
        name: "Upper Strength", focus: "Push & pull", minutes: 42,
        exercises: [
            Exercise("Bench press", sets: 4, reps: 5, load: 185),
            Exercise("Barbell row", sets: 4, reps: 6, load: 135),
            Exercise("Overhead press", sets: 3, reps: 6, load: 95),
            Exercise("Pull-ups", sets: 3, reps: 8),
            Exercise("Face pulls", sets: 3, reps: 12, load: 40),
        ])

    static let lowerStrength = WorkoutPlan(
        name: "Lower Strength", focus: "Hinge & squat", minutes: 45,
        exercises: [
            Exercise("Back squat", sets: 4, reps: 5, load: 225),
            Exercise("Romanian deadlift", sets: 3, reps: 6, load: 185),
            Exercise("Split squat", sets: 3, reps: 8, load: 40),
            Exercise("Calf raise", sets: 3, reps: 12, load: 90),
        ])

    static let fullBody = WorkoutPlan(
        name: "Full Body", focus: "Balanced", minutes: 38,
        exercises: [
            Exercise("Goblet squat", sets: 3, reps: 8, load: 50),
            Exercise("Push-ups", sets: 3, reps: 12),
            Exercise("One-arm row", sets: 3, reps: 10, load: 55),
            Exercise("Plank", sets: 3, reps: 1),
        ])

    static let mobility = WorkoutPlan(
        name: "Mobility Reset", focus: "Restore & loosen", minutes: 18,
        exercises: [
            Exercise("Hip 90/90", sets: 2, reps: 8),
            Exercise("Thoracic openers", sets: 2, reps: 10),
            Exercise("Deep squat hold", sets: 3, reps: 1),
            Exercise("Slow breathing", sets: 1, reps: 1),
        ])
}
