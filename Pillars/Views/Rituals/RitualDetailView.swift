import SwiftUI
import SwiftData

/// A single ritual: what it is, how it feels, the simple steps, and one tap to log that
/// you did it (which records the effect into your weekly review).
struct RitualDetailView: View {
    let ritual: Ritual

    @Environment(\.modelContext) private var context
    @Query private var savedRituals: [SavedRitual]
    @State private var done = false

    private var isSaved: Bool { RitualSaveStore.isSaved(ritual, in: savedRituals) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                header
                metaCard
                stepsCard
                action
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
                Button {
                    RitualSaveStore.toggle(ritual, in: savedRituals, context: context)
                } label: {
                    Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(isSaved ? PillarsColors.gold : PillarsColors.secondaryText)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            PillarIconBadge(pillar: ritual.pillar, size: 64)
            VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
                Text(ritual.name)
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(ritual.summary)
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var metaCard: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: 6) {
                MetaChip(text: ritual.pillar.displayName, color: ritual.pillar.color)
                MetaChip(text: ritual.tone.label, color: ritual.tone.color)
                MetaChip(text: ritual.mode.label)
                if ritual.estimatedMinutes > 0 { MetaChip(text: "\(ritual.estimatedMinutes) min") }
            }
        }
    }

    private var stepsCard: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text("How it goes")
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                ForEach(ritual.steps.indices, id: \.self) { i in
                    let step = ritual.steps[i]
                    HStack(alignment: .top, spacing: PillarsSpacing.s) {
                        Text("\(i + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(PillarsColors.gold)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(PillarsColors.gold.opacity(0.14)))
                        Text(step)
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                if ritual.shareable {
                    Divider().overlay(PillarsColors.cardBorder)
                    Label("Can be started as a shared reset in your Circle.", systemImage: "person.2")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                }
            }
        }
    }

    private var action: some View {
        VStack(spacing: PillarsSpacing.s) {
            if done {
                PillarGlassCard(padding: PillarsSpacing.m, highlight: true) {
                    HStack(spacing: PillarsSpacing.s) {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(PillarsColors.gold)
                        Text("Logged. This will show up in your weekly review.")
                            .font(PillarsTypography.callout)
                            .foregroundStyle(PillarsColors.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                PrimaryButton(title: "I did this", icon: "checkmark") { log() }
                Text("Logging a ritual teaches Pillars what restores you.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func log() {
        let entry = PillarAction(
            title: ritual.name, subtitle: ritual.summary, pillar: ritual.pillar,
            isCompleted: true, createdAt: .now, completedAt: .now
        )
        context.insert(entry)
        try? context.save()
        withAnimation(.smooth) { done = true }
    }
}

#if DEBUG
#Preview {
    NavigationStack { RitualDetailView(ritual: RitualLibrary.all[3]) }
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
