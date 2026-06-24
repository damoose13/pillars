import SwiftUI
import SwiftData

/// Where you decide how much of yourself the Circle sees. **The default is private** — you
/// open up only by choosing to, one level at a time, and you can close it again whenever you
/// want. Private notes are never shared at any level.
struct CircleSharingSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var members: [CircleMember]

    private var you: CircleMember? { members.first { $0.isYou } }

    @State private var level: VisibilityLevel = .privateLevel
    @State private var shared: Set<PillarType> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    intro
                    levelPicker
                    if level == .selectedPillars { pillarPicker }
                    summary
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("Your sharing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .font(PillarsTypography.callout.weight(.semibold))
                        .foregroundStyle(PillarsColors.gold)
                }
            }
            .onAppear {
                if let you {
                    level = you.visibilityLevel
                    shared = Set(you.sharedPillars)
                }
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("How the Circle sees you")
                .font(PillarsTypography.title)
                .foregroundStyle(PillarsColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            Text("You start private. Open up only as much as feels right — and the Circle still blurs everything to its size on top of this.")
                .font(PillarsTypography.callout)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var levelPicker: some View {
        VStack(spacing: PillarsSpacing.s) {
            ForEach(VisibilityLevel.allCases, id: \.self) { option in
                Button {
                    withAnimation(.smooth(duration: 0.25)) { level = option }
                } label: {
                    PillarGlassCard(padding: PillarsSpacing.m, highlight: level == option) {
                        HStack(alignment: .top, spacing: PillarsSpacing.m) {
                            Image(systemName: level == option ? "largecircle.fill.circle" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(level == option ? PillarsColors.gold : PillarsColors.tertiaryText)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(option.title)
                                    .font(PillarsTypography.headline)
                                    .foregroundStyle(PillarsColors.primaryText)
                                Text(option.detail)
                                    .font(PillarsTypography.caption)
                                    .foregroundStyle(PillarsColors.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private var pillarPicker: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(title: "Pillars to open", subtitle: "Only these become visible.")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: PillarsSpacing.s)], spacing: PillarsSpacing.s) {
                ForEach(PillarType.allCases) { pillar in
                    let on = shared.contains(pillar)
                    Button {
                        withAnimation(.smooth(duration: 0.2)) {
                            if on { shared.remove(pillar) } else { shared.insert(pillar) }
                        }
                    } label: {
                        HStack(spacing: PillarsSpacing.s) {
                            Image(systemName: pillar.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(on ? pillar.color : PillarsColors.tertiaryText)
                            Text(pillar.displayName)
                                .font(PillarsTypography.caption.weight(.semibold))
                                .foregroundStyle(on ? PillarsColors.primaryText : PillarsColors.secondaryText)
                            Spacer(minLength: 0)
                            Image(systemName: on ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 15))
                                .foregroundStyle(on ? PillarsColors.gold : PillarsColors.tertiaryText)
                        }
                        .padding(.horizontal, PillarsSpacing.m)
                        .padding(.vertical, PillarsSpacing.s)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(on ? 0.06 : 0.03)))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(on ? pillar.color.opacity(0.5) : PillarsColors.cardBorder, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    private var summary: some View {
        PillarGlassCard {
            HStack(alignment: .top, spacing: PillarsSpacing.s) {
                Image(systemName: "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(PillarsColors.gold)
                VStack(alignment: .leading, spacing: 3) {
                    Text("What the Circle sees")
                        .font(PillarsTypography.caption.weight(.semibold))
                        .foregroundStyle(PillarsColors.primaryText)
                    Text(summaryLine)
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var summaryLine: String {
        switch level {
        case .privateLevel:
            return "Only the wins and resets you choose to share. Nothing else."
        case .statusOnly:
            return "A single soft status word — never a value, never a pillar."
        case .selectedPillars:
            let n = shared.count
            return n == 0
                ? "No pillars opened yet. Pick the ones you're comfortable sharing."
                : "\(n) pillar\(n == 1 ? "" : "s") as states — never numbers."
        case .fullShared:
            return "All eight pillars as states. Private notes stay private."
        }
    }

    private func save() {
        guard let you else { dismiss(); return }
        you.visibilityLevel = level
        you.sharedPillars = level == .selectedPillars ? PillarType.allCases.filter { shared.contains($0) } : []
        try? context.save()
        dismiss()
    }
}

#if DEBUG
#Preview {
    CircleSharingSettingsView()
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
