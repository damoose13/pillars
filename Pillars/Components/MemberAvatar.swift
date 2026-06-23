import SwiftUI

/// A circular member avatar showing initials over a muted tint. Displays *identity only* —
/// never any score or signal. The current user ("You") gets a quiet gold ring.
struct MemberAvatar: View {
    let name: String
    let colorIndex: Int
    var isYou: Bool = false
    var size: CGFloat = 44

    private var color: Color {
        let palette = PillarsColors.memberPalette
        return palette[abs(colorIndex) % palette.count]
    }

    private var initials: String {
        let parts = name.split(separator: " ")
        if let first = parts.first?.first {
            if parts.count > 1, let second = parts[1].first {
                return "\(first)\(second)".uppercased()
            }
            return String(first).uppercased()
        }
        return "?"
    }

    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.9))
            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(PillarsColors.background)
        }
        .frame(width: size, height: size)
        .overlay(
            Circle().strokeBorder(isYou ? PillarsColors.gold : Color.white.opacity(0.12), lineWidth: isYou ? 2 : 1)
        )
    }
}
