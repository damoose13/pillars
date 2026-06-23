import Foundation

/// The catalog of named, repeatable rituals. Curated, not generated — calm practices a
/// person can build a life around.
enum RitualLibrary {

    static let all: [Ritual] = [
        Ritual(
            id: "room-reset", name: "10-Minute Room Reset",
            summary: "Reset one surface — bed, desk, or floor — and let the room exhale.",
            pillar: .space, mode: .solo, estimatedMinutes: 10, tone: .grounding, shareable: false,
            steps: ["Pick one surface.", "Clear what doesn't belong.", "Wipe it down.", "Notice how the room feels."],
            shareMessage: nil),

        Ritual(
            id: "honest-text", name: "Honest Text",
            summary: "One short, real message to someone you've been meaning to reach.",
            pillar: .connect, mode: .onePerson, estimatedMinutes: 5, tone: .tender, shareable: true,
            steps: ["Think of one person.", "Write how you actually are — a sentence is enough.", "Send it before you overthink."],
            shareMessage: "Thinking of you today. No agenda — just wanted to say you're on my mind. How are you, really?"),

        Ritual(
            id: "temple-morning", name: "Temple Morning",
            summary: "A slow, intentional morning — temple, prayer, or quiet devotion.",
            pillar: .purpose, mode: .community, estimatedMinutes: 60, tone: .reflective, shareable: true,
            steps: ["Arrive without rushing.", "Offer your attention fully.", "Carry one intention into the day."],
            shareMessage: "Heading to temple this morning for a slow start. You're welcome to join — no pressure, just an open invite."),

        Ritual(
            id: "gratitude-circle", name: "Gratitude Circle",
            summary: "Three good things each, said out loud, together.",
            pillar: .connect, mode: .circle, estimatedMinutes: 20, tone: .connecting, shareable: true,
            steps: ["Gather, even briefly.", "Each person names three good things.", "No fixing — just listening."],
            shareMessage: "Want to do a 10-minute gratitude circle this week? Three good things each, that's it. I'm in if you are."),

        Ritual(
            id: "sunday-reset", name: "Sunday Reset",
            summary: "Tidy, plan, and soften the edges before the week begins.",
            pillar: .space, mode: .circle, estimatedMinutes: 30, tone: .grounding, shareable: true,
            steps: ["Reset your main spaces.", "Glance at the week ahead.", "Choose one thing to protect."],
            shareMessage: "Doing a Sunday reset later — tidy, plan, breathe. Want to do ours at the same time and compare notes?"),

        Ritual(
            id: "morning-walk", name: "Morning Light Walk",
            summary: "Twenty minutes outside, early, before the day asks for anything.",
            pillar: .body, mode: .solo, estimatedMinutes: 20, tone: .energizing, shareable: false,
            steps: ["Get outside within an hour of waking.", "Walk without your phone.", "Let the light do its work."],
            shareMessage: nil),

        Ritual(
            id: "wind-down", name: "Phone-Down Wind-Down",
            summary: "Screens away an hour before bed. Let your mind set with the day.",
            pillar: .sleep, mode: .solo, estimatedMinutes: 30, tone: .settling, shareable: false,
            steps: ["Put the phone in another room.", "Dim the lights.", "Do one quiet thing until you're sleepy."],
            shareMessage: nil),

        Ritual(
            id: "walk-with-one", name: "Walk With One Person",
            summary: "Twenty minutes outdoors with someone — movement and connection at once.",
            pillar: .body, mode: .onePerson, estimatedMinutes: 20, tone: .connecting, shareable: true,
            steps: ["Invite one person.", "Leave the phones in pockets.", "Walk and talk, no destination."],
            shareMessage: "Free for a 20-minute walk? No plan, just movement and a catch-up. Would be good to see you."),

        Ritual(
            id: "family-checkin", name: "Family Check-In",
            summary: "A short, regular moment to ask how everyone actually is.",
            pillar: .connect, mode: .circle, estimatedMinutes: 20, tone: .tender, shareable: true,
            steps: ["Gather the people close to you.", "Each shares one high and one low.", "Close with one thing you appreciate."],
            shareMessage: "Can we do a quick family check-in this week? One high, one low each. I'd love that."),

        Ritual(
            id: "seva-service", name: "Seva / Service Activity",
            summary: "Give an hour to something beyond yourself.",
            pillar: .purpose, mode: .community, estimatedMinutes: 60, tone: .reflective, shareable: true,
            steps: ["Pick one act of service.", "Show up with full attention.", "Notice what it gives back."],
            shareMessage: "Thinking of doing some seva this weekend — an hour of service. Want to come along? It always gives more than it takes.")
    ]

    static func ritual(id: String) -> Ritual? { all.first { $0.id == id } }

    static func rituals(for pillar: PillarType) -> [Ritual] { all.filter { $0.pillar == pillar } }

    /// Rituals suitable to start as a shared Circle reset.
    static var sharedResets: [Ritual] {
        all.filter { $0.shareable && $0.mode != .solo }
    }

    /// The best repeatable ritual to anchor a pillar that's asking for support.
    static func anchor(for pillar: PillarType) -> Ritual? {
        rituals(for: pillar).min { $0.estimatedMinutes < $1.estimatedMinutes }
    }
}
