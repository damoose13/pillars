import SwiftUI
import SwiftData

/// The daily check-in. Choose a depth: a one-tap Quick read that sets all eight pillars at
/// once, or the Full per-pillar form (prefilled from your last check-in). Add an optional
/// private note and save. On completion it returns you to Today, refreshed.
struct DailyCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Environment(HealthKitManager.self) private var health

    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    enum Depth: String, CaseIterable, Hashable {
        case quick, full
        var title: String { self == .quick ? "Quick" : "Full" }
    }

    @State private var depth: Depth = .full
    @State private var overall: Int = 3
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
                        Text(depth == .quick
                             ? "A one-tap read of the whole system. We'll set all eight pillars together — tune any later."
                             : "An honest read across the eight pillars. No streaks, no scores to chase — just where you are today.")
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    depthPicker

                    if depth == .full && health.isConnected {
                        healthPrefillButton
                    }

                    if depth == .quick {
                        quickCard
                    } else {
                        PillarScoreForm(scores: $scores)
                    }

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

    /// A calm two-option segmented control: Quick (one read) vs Full (eight pillars).
    private var depthPicker: some View {
        HStack(spacing: 0) {
            ForEach(Depth.allCases, id: \.self) { option in
                Button { withAnimation(.snappy(duration: 0.2)) { depth = option } } label: {
                    Text(option.title)
                        .font(PillarsTypography.callout.weight(.semibold))
                        .foregroundStyle(depth == option ? PillarsColors.background : PillarsColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(depth == option ? PillarsColors.gold : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.white.opacity(0.05)))
        .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
    }

    /// Quick mode: one overall read that fills every pillar to the same level.
    private var quickCard: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text("Overall, how's the whole system today?")
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                ScoreSelector(score: $overall)
                Text("Sets all eight pillars to \(PillarState.from(score: overall).displayName.lowercased()). Switch to Full to shape each one.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
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

    /// Pull today's activity, sleep, and mindful minutes from Apple Health into the sliders.
    @State private var isFillingFromHealth = false
    private var healthPrefillButton: some View {
        Button {
            isFillingFromHealth = true
            Task {
                let suggestions = await health.todaySuggestions()
                for (pillar, value) in suggestions { scores[pillar] = value }
                isFillingFromHealth = false
            }
        } label: {
            HStack(spacing: PillarsSpacing.s) {
                Image(systemName: "heart.text.square")
                    .foregroundStyle(PillarsColors.gold)
                Text(isFillingFromHealth ? "Reading Apple Health…" : "Fill from Apple Health")
                    .font(PillarsTypography.callout.weight(.semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                Spacer(minLength: 0)
                Image(systemName: "arrow.down.circle")
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
            .padding(.horizontal, PillarsSpacing.m)
            .padding(.vertical, 12)
            .background(Capsule().fill(Color.white.opacity(0.06)))
            .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isFillingFromHealth)
    }

    /// Seed the sliders from the most recent check-in so updating feels continuous.
    private func prefillIfNeeded() {
        guard !didPrefill, let latest = checkIns.first else { return }
        for pillar in PillarType.allCases {
            scores[pillar] = latest.score(for: pillar)
        }
        overall = latest.systemScore >= 80 ? 5 : latest.systemScore >= 60 ? 4
            : latest.systemScore >= 40 ? 3 : latest.systemScore >= 20 ? 2 : 1
        didPrefill = true
    }

    private func save() {
        let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let checkIn = DailyCheckIn(date: .now, notes: trimmed.isEmpty ? nil : trimmed)
        for pillar in PillarType.allCases {
            checkIn.setScore(depth == .quick ? overall : (scores[pillar] ?? 3), for: pillar)
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
        .environment(HealthKitManager())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
