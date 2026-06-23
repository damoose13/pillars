import SwiftUI

/// Browse the repeatable rituals — the practices a person can return to. A retention
/// surface: not "today's tasks" but a library to build a life around.
struct RitualLibraryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                    Text("The library")
                        .pillarsOverline(PillarsColors.gold.opacity(0.9))
                    Text("Rituals worth\nreturning to.")
                        .font(PillarsTypography.display)
                        .foregroundStyle(PillarsColors.primaryText)
                        .lineSpacing(2)
                    Text("Small, repeatable practices — not tasks to finish. Keep the ones that fit your life.")
                        .font(PillarsTypography.body)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: PillarsSpacing.s) {
                    ForEach(RitualLibrary.all) { ritual in
                        NavigationLink {
                            RitualDetailView(ritual: ritual)
                        } label: {
                            RitualRow(ritual: ritual)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PillarsSpacing.screenH)
            .padding(.top, PillarsSpacing.m)
            .padding(.bottom, PillarsSpacing.xxl)
        }
        .scrollIndicators(.hidden)
        .pillarsBackground()
        .navigationTitle("Rituals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

private struct RitualRow: View {
    let ritual: Ritual

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.m) {
                PillarIconBadge(pillar: ritual.pillar, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(ritual.name)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Text(ritual.summary)
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Circle().fill(ritual.tone.color).frame(width: 6, height: 6)
                        Text(ritual.tone.label.lowercased())
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(ritual.tone.color)
                        if ritual.estimatedMinutes > 0 {
                            Text("· \(ritual.estimatedMinutes) min")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(PillarsColors.tertiaryText)
                        }
                        if ritual.shareable {
                            Image(systemName: "person.2")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(PillarsColors.tertiaryText)
                        }
                    }
                    .padding(.top, 1)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack { RitualLibraryView() }
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
