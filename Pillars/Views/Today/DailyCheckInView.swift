import SwiftUI
import SwiftData

/// The daily check-in. Rate the eight pillars (prefilled from your last check-in), add an
/// optional private note, and save. On completion it returns you to Today, refreshed.
struct DailyCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState

    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    @State private var scores: [PillarType: Int] = Dictionary(
        uniqueKeysWithValues: PillarType.allCases.map { ($0, 3) }
    )
    @State private var notes: String = ""
    @State private var didPrefill = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                        Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                            .pillarsOverline(PillarsColors.gold.opacity(0.9))
                        Text("How are you,\nreally?")
                            .font(PillarsTypography.display)
                            .foregroundStyle(PillarsColors.primaryText)
                            .lineSpacing(2)
                        Text("A quick, honest read across the eight pillars. No streaks, no scores to chase — just where you are today.")
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    PillarScoreForm(scores: $scores)

                    notesCard

                    PrimaryButton(title: "Complete check-in", icon: "checkmark") { save() }
                        .padding(.top, PillarsSpacing.xs)
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(PillarsColors.secondaryText)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear(perform: prefillIfNeeded)
    }

    private var notesCard: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("A note for today")
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("Optional, and private to this device.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.secondaryText)
                TextField("What's on your mind?", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.primaryText)
                    .tint(PillarsColors.gold)
                    .padding(PillarsSpacing.s)
                    .background(RoundedRectangle(cornerRadius: PillarsRadius.small).fill(Color.white.opacity(0.04)))
                    .overlay(RoundedRectangle(cornerRadius: PillarsRadius.small).strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
            }
        }
    }

    /// Seed the sliders from the most recent check-in so updating feels continuous.
    private func prefillIfNeeded() {
        guard !didPrefill, let latest = checkIns.first else { return }
        for pillar in PillarType.allCases {
            scores[pillar] = latest.score(for: pillar)
        }
        didPrefill = true
    }

    private func save() {
        let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let checkIn = DailyCheckIn(date: .now, notes: trimmed.isEmpty ? nil : trimmed)
        for pillar in PillarType.allCases {
            checkIn.setScore(scores[pillar] ?? 3, for: pillar)
        }
        context.insert(checkIn)
        try? context.save()
        appState.selectedTab = .today
        dismiss()
    }
}

#if DEBUG
#Preview {
    DailyCheckInView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
