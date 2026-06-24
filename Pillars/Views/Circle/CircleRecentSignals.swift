import SwiftUI

/// A calm, privacy-safe activity stream for a Circle: the voluntary wins people shared and who
/// joined — a sense of life and momentum, never anyone's scores.
struct CircleRecentSignals: View {
    let wins: [SharedWin]
    let members: [CircleMember]

    private struct Signal: Identifiable {
        let id = UUID()
        let date: Date
        let icon: String
        let color: Color
        let text: String
    }

    private var signals: [Signal] {
        var items: [Signal] = []
        for win in wins {
            items.append(Signal(date: win.createdAt, icon: "sparkles", color: PillarsColors.gold,
                                text: "\(win.authorName) shared a win — \(win.title)"))
        }
        let palette = PillarsColors.memberPalette
        for member in members where !member.isYou {
            let color = palette[((member.colorIndex % palette.count) + palette.count) % palette.count]
            items.append(Signal(date: member.joinedAt, icon: "person.badge.plus", color: color,
                                text: "\(member.name) joined the Circle"))
        }
        return items.sorted { $0.date > $1.date }.prefix(4).map { $0 }
    }

    var body: some View {
        if !signals.isEmpty {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                SectionHeader(title: "Recently together", subtitle: "Voluntary moments — never scores.")
                PillarGlassCard(padding: PillarsSpacing.m) {
                    VStack(spacing: 0) {
                        ForEach(Array(signals.enumerated()), id: \.element.id) { index, signal in
                            HStack(spacing: PillarsSpacing.s) {
                                ZStack {
                                    Circle().fill(signal.color.opacity(0.16))
                                    Image(systemName: signal.icon)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(signal.color)
                                }
                                .frame(width: 32, height: 32)
                                Text(signal.text)
                                    .font(PillarsTypography.callout)
                                    .foregroundStyle(PillarsColors.primaryText)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: PillarsSpacing.xs)
                                Text(signal.date.formatted(.relative(presentation: .named)))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(PillarsColors.tertiaryText)
                            }
                            .padding(.vertical, PillarsSpacing.xs)
                            if index < signals.count - 1 {
                                Divider().overlay(PillarsColors.cardBorder)
                            }
                        }
                    }
                }
            }
        }
    }
}
