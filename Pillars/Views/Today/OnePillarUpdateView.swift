import SwiftUI
import SwiftData

/// A fast, single-pillar update — tap a pillar, nudge just that reading, done. No full check-in.
///
/// If you've already checked in today it updates that record in place; otherwise it starts a
/// fresh check-in and carries your other pillars forward from last time, so nothing is lost.
struct OnePillarUpdateView: View {
    let pillar: PillarType

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    @State private var score = 3
    @State private var didSeed = false

    /// Today's check-in, if one already exists — the thing we update in place.
    private var todaysCheckIn: DailyCheckIn? {
        guard let latest = checkIns.first, Calendar.current.isDateInToday(latest.date) else { return nil }
        return latest
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    header
                    card
                    PrimaryButton(title: "Update \(pillar.displayName)", icon: "checkmark") { save() }
                        .padding(.top, PillarsSpacing.xs)
                }
                .frame(maxWidth: 540)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.l)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("Quick update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }.foregroundStyle(PillarsColors.secondaryText)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear(perform: seed)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            PillarIconBadge(pillar: pillar, size: 52)
            Text("How's \(pillar.displayName)\nright now?")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
                .lineSpacing(2)
            Text(todaysCheckIn == nil
                 ? "This starts today's check-in with \(pillar.displayName). Your other pillars carry over from last time."
                 : "Updates just \(pillar.displayName) on today's check-in. Nothing else changes.")
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var card: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text(pillar.shortDescription)
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                ScoreSelector(score: $score)
                Text("Currently reading \(PillarState.from(score: score).displayName.lowercased()).")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
                    .contentTransition(.numericText())
            }
        }
    }

    private func seed() {
        guard !didSeed else { return }
        score = checkIns.first?.score(for: pillar) ?? 3
        didSeed = true
    }

    private func save() {
        if let today = todaysCheckIn {
            today.setScore(score, for: pillar)
        } else {
            let new = DailyCheckIn(date: .now, notes: nil)
            for p in PillarType.allCases {
                new.setScore(checkIns.first?.score(for: p) ?? 3, for: p)
            }
            new.setScore(score, for: pillar)
            context.insert(new)
        }
        try? context.save()
        dismiss()
    }
}

#if DEBUG
#Preview {
    OnePillarUpdateView(pillar: .connect)
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
