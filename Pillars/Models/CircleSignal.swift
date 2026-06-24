import SwiftUI

/// A single privacy-safe event in a Circle's life — a shared win, someone joining, a gentle
/// check-in, a shared reset. It carries identity and one supportive line, **never a score and
/// never a pillar value**. The Circle activity feed renders only this shape.
struct CircleSignal: Identifiable {
    /// What kind of moment this is. Drives the icon only — never any data exposure.
    enum Kind {
        case win
        case memberJoined
        case gentleCheckIn
        case sharedReset

        var icon: String {
            switch self {
            case .win:           return "sparkles"
            case .memberJoined:  return "person.badge.plus"
            case .gentleCheckIn: return "bubble.left.and.bubble.right.fill"
            case .sharedReset:   return "arrow.triangle.2.circlepath"
            }
        }
    }

    let id: UUID
    let date: Date
    let kind: Kind
    let color: Color
    let text: String

    init(id: UUID = UUID(), date: Date, kind: Kind, color: Color, text: String) {
        self.id = id
        self.date = date
        self.kind = kind
        self.color = color
        self.text = text
    }

    var icon: String { kind.icon }
}

extension CircleSignal {
    /// Build the privacy-safe feed from voluntary wins and who joined — newest first. This never
    /// reads a member's pillar scores; it only ever sees what people chose to share.
    static func feed(wins: [SharedWin], members: [CircleMember], limit: Int = 4) -> [CircleSignal] {
        var items: [CircleSignal] = []

        for win in wins {
            items.append(CircleSignal(
                date: win.createdAt, kind: .win, color: PillarsColors.gold,
                text: "\(win.authorName) shared a win — \(win.title)"))
        }

        let palette = PillarsColors.memberPalette
        for member in members where !member.isYou {
            let color = palette[((member.colorIndex % palette.count) + palette.count) % palette.count]
            items.append(CircleSignal(
                date: member.joinedAt, kind: .memberJoined, color: color,
                text: "\(member.name) joined the Circle"))
        }

        return Array(items.sorted { $0.date > $1.date }.prefix(limit))
    }
}
