import SwiftUI
import SwiftData

/// A single member's profile, showing **only** what their own visibility level permits.
/// This is the permission boundary in the flesh: a private member reveals nothing, a
/// soft-status member reveals one gentle word, and only a member who explicitly chose to
/// share pillars shows their states — never a number, never a private note.
struct MemberCircleProfileView: View {
    let member: CircleMember

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SharedWin.createdAt, order: .reverse) private var wins: [SharedWin]

    private var theirWins: [SharedWin] {
        wins.filter { $0.authorName == member.name }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    header
                    visibilityContent
                    if !theirWins.isEmpty { winsSection }
                    privacyNote
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(PillarsColors.gold)
                }
            }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            MemberAvatar(name: member.name, colorIndex: member.colorIndex, isYou: member.isYou, size: 72)
            VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
                Text(member.isYou ? "\(member.name) (you)" : member.name)
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                Label(member.visibilityLevel.title, systemImage: visibilityIcon)
                    .font(PillarsTypography.caption.weight(.semibold))
                    .foregroundStyle(PillarsColors.secondaryText)
            }
        }
    }

    private var visibilityIcon: String {
        switch member.visibilityLevel {
        case .privateLevel:    return "lock.fill"
        case .statusOnly:      return "circle.lefthalf.filled"
        case .selectedPillars: return "circle.grid.2x2"
        case .fullShared:      return "circle.hexagongrid.fill"
        }
    }

    // MARK: Visibility-gated content

    @ViewBuilder private var visibilityContent: some View {
        switch member.visibilityLevel {
        case .privateLevel:
            privateCard
        case .statusOnly:
            statusCard
        case .selectedPillars:
            statesCard(pillars: member.sharedPillars, title: "Shared pillars")
        case .fullShared:
            statesCard(pillars: PillarType.allCases, title: "Pillar states")
        }
    }

    private var privateCard: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Label { Text("Keeps their pillars private") } icon: { Image(systemName: "lock.fill") }
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("\(member.name) hasn't opened any pillars to the Circle. You'll still see anything they choose to share as a win or a reset.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var statusCard: some View {
        let status = SoftStatus.of(member)
        return PillarGlassCard(highlight: true) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Soft status")
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                HStack(spacing: PillarsSpacing.s) {
                    Image(systemName: status.symbol)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(status.color)
                    Text(status.label)
                        .font(PillarsFont.serif(24, .semibold))
                        .foregroundStyle(PillarsColors.primaryText)
                }
                Text("A soft read \(member.name) chose to share — never a value, never a pillar.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func statesCard(pillars: [PillarType], title: String) -> some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text(title)
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                if pillars.isEmpty {
                    Text("\(member.name) chose this level but hasn't opened any pillars yet.")
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(pillars) { pillar in
                        let state = PillarState.from(score: member.score(for: pillar))
                        HStack(spacing: PillarsSpacing.s) {
                            PillarIconBadge(pillar: pillar, size: 34)
                            Text(pillar.displayName)
                                .font(PillarsTypography.callout.weight(.semibold))
                                .foregroundStyle(PillarsColors.primaryText)
                            Spacer(minLength: 0)
                            Text(state.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(state.color)
                        }
                    }
                }
                Text("States only — no numbers ever leave \(member.name)'s device.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
                    .padding(.top, PillarsSpacing.xxs)
            }
        }
    }

    // MARK: Wins

    private var winsSection: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(title: "Wins they've shared", subtitle: "Always voluntary.")
            ForEach(theirWins) { win in
                PillarGlassCard(padding: PillarsSpacing.m) {
                    HStack(alignment: .top, spacing: PillarsSpacing.m) {
                        PillarIconBadge(pillar: win.pillar, size: 40)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(win.title)
                                .font(PillarsTypography.callout.weight(.semibold))
                                .foregroundStyle(PillarsColors.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(win.createdAt.formatted(.relative(presentation: .named)))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(PillarsColors.tertiaryText)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private var privacyNote: some View {
        Label {
            Text("You only ever see what each person opens to the Circle. They can change it, or close it, anytime.")
        } icon: {
            Image(systemName: "hand.raised.fill")
        }
        .font(PillarsTypography.caption)
        .foregroundStyle(PillarsColors.secondaryText)
    }
}

/// A deliberately coarse, supportive status word for the `statusOnly` visibility level.
/// Carries no value and no pillar — just a felt sense the member consented to share.
enum SoftStatus {
    case lifting, steady, support

    static func of(_ member: CircleMember) -> SoftStatus {
        let avg = Double(PillarType.allCases.reduce(0) { $0 + member.score(for: $1) })
            / Double(PillarType.allCases.count)
        if avg < 2.5 { return .support }
        if avg < 3.7 { return .steady }
        return .lifting
    }

    var label: String {
        switch self {
        case .lifting: return "Doing well"
        case .steady:  return "Holding steady"
        case .support: return "Could use a little support"
        }
    }

    var symbol: String {
        switch self {
        case .lifting: return "sun.max.fill"
        case .steady:  return "circle.lefthalf.filled"
        case .support: return "moon.haze.fill"
        }
    }

    var color: Color {
        switch self {
        case .lifting: return PillarsColors.positive
        case .steady:  return PillarsColors.secondaryText
        case .support: return PillarsColors.gold
        }
    }
}

#if DEBUG
#Preview {
    MemberCircleProfileView(member: {
        let m = CircleMember.mock(name: "Maya", colorIndex: 0)
        m.visibilityLevel = .selectedPillars
        m.sharedPillars = [.body, .mind, .connect]
        return m
    }())
    .modelContainer(PreviewData.container)
    .preferredColorScheme(.dark)
}
#endif
