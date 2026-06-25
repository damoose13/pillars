import SwiftUI
import SwiftData

/// Body Mode — a focused training flow. Setup shows today's session matched to the band's
/// readiness; active logs sets without pressure (stop whenever); summary shows how the workout
/// moved the Pillar Web and offers the natural next restoration: refuel.
///
/// A workout is *an action that changes the Web*, not a separate product — so finishing nudges
/// today's check-in (Body/Mind up, Recover down) and logs the session as a Body restoration.
struct TrainModeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(BandManager.self) private var band
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query(sort: \PillarAction.createdAt, order: .reverse) private var actions: [PillarAction]

    /// The plan to train. Defaults to the engine's suggestion for today's readiness.
    var plan: WorkoutPlan?

    private enum Step { case setup, active, summary }
    @State private var step: Step = .setup
    @State private var session: WorkoutSession?
    @State private var completed: [String: Int] = [:]
    @State private var didApply = false

    private var resolvedPlan: WorkoutPlan { plan ?? TrainingEngine.suggestedPlan(readiness: band.readiness) }
    private let refuel = TrainingEngine.postWorkoutRestoration()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    if let session {
                        switch step {
                        case .setup:   setupStep(session)
                        case .active:  activeStep(session)
                        case .summary: summaryStep(session)
                        }
                    }
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("Body Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(step == .summary ? "Done" : "Close") { dismiss() }
                        .foregroundStyle(step == .summary ? PillarsColors.gold : PillarsColors.secondaryText)
                }
            }
        }
        .onAppear {
            if session == nil { session = TrainingEngine.session(for: resolvedPlan, readiness: band.readiness) }
        }
    }

    // MARK: Setup

    private func setupStep(_ session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
                Text(session.plan.focus.uppercased())
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                Text(session.plan.name)
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("\(session.plan.exercises.count) movements · about \(session.plan.estimatedMinutes) min")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
            }

            readinessBanner(session)

            VStack(spacing: PillarsSpacing.s) {
                ForEach(session.sets) { set in
                    setupRow(set)
                }
            }

            PrimaryButton(title: "Start workout", icon: "play.fill") {
                withAnimation(.smooth) { step = .active }
            }
            .padding(.top, PillarsSpacing.xs)
        }
    }

    @ViewBuilder private func readinessBanner(_ session: WorkoutSession) -> some View {
        if let reading = session.readiness {
            PillarGlassCard(padding: PillarsSpacing.m) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: PillarsSpacing.s) {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundStyle(PillarsColors.gold)
                        Text("Readiness \(reading.score) · \(reading.band.label)")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                    }
                    Text(session.adjustmentNote ?? reading.detail)
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } else {
            Text("Pair your Pillars Band in Devices for recovery-aware adjustments.")
                .font(PillarsTypography.caption)
                .foregroundStyle(PillarsColors.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func setupRow(_ set: PlannedSet) -> some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.m) {
                Text(set.exercise.name)
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                Spacer(minLength: 0)
                Text(prescription(set))
                    .font(PillarsTypography.callout.weight(.semibold))
                    .foregroundStyle(PillarsColors.secondaryText)
            }
        }
    }

    // MARK: Active

    private func activeStep(_ session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
                Text("In session")
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                Text(session.plan.name)
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("Tap each set as you finish it. Stop whenever you like — there's no failing here.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: PillarsSpacing.s) {
                ForEach(session.sets) { set in
                    activeRow(set)
                }
            }

            PrimaryButton(title: "Finish workout", icon: "checkmark") {
                applyEffects(session)
                withAnimation(.smooth) { step = .summary }
            }
            .padding(.top, PillarsSpacing.xs)
        }
    }

    private func activeRow(_ set: PlannedSet) -> some View {
        let done = completed[set.id] ?? 0
        return PillarGlassCard(padding: PillarsSpacing.m) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                HStack(spacing: PillarsSpacing.m) {
                    Text(set.exercise.name)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Spacer(minLength: 0)
                    Text(prescription(set))
                        .font(PillarsTypography.caption.weight(.semibold))
                        .foregroundStyle(PillarsColors.tertiaryText)
                }
                HStack(spacing: 8) {
                    ForEach(0..<set.sets, id: \.self) { idx in
                        Button {
                            completed[set.id] = (idx < done) ? idx : idx + 1
                        } label: {
                            Image(systemName: idx < done ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundStyle(idx < done ? PillarsColors.gold : PillarsColors.tertiaryText)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer(minLength: 0)
                    Text("\(done)/\(set.sets)")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                }
            }
        }
    }

    // MARK: Summary

    private func summaryStep(_ session: WorkoutSession) -> some View {
        let deltas = TrainingEngine.pillarDeltas(for: session)
        return VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                ZStack {
                    Circle().fill(PillarsColors.gold.opacity(0.14)).frame(width: 72, height: 72)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(PillarsColors.gold)
                }
                Text(session.plan.id == WorkoutLibrary.mobility.id ? "Nicely restored." : "Body received support.")
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("Here's how it moved your Pillar Web.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
            }

            PillarGlassCard {
                VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                    ForEach(orderedDeltas(deltas), id: \.pillar) { item in
                        HStack(spacing: PillarsSpacing.s) {
                            Image(systemName: item.delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(item.delta >= 0 ? PillarsColors.positive : PillarsColors.secondaryText)
                                .frame(width: 18)
                            Text(item.pillar.displayName)
                                .font(PillarsTypography.headline)
                                .foregroundStyle(PillarsColors.primaryText)
                            Spacer(minLength: 0)
                            Text(item.delta >= 0 ? "supported" : "spent")
                                .font(PillarsTypography.caption)
                                .foregroundStyle(PillarsColors.secondaryText)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Fuel is asking for support")
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                PillarMoveCard(
                    recommendation: refuel,
                    isCompleted: RestorationLog.isCompleted(refuel, in: actions),
                    onToggle: { RestorationLog.toggle(refuel, in: actions, context: context) }
                )
            }

            PrimaryButton(title: "Done", icon: "arrow.right") { dismiss() }
                .padding(.top, PillarsSpacing.xs)
        }
    }

    // MARK: Logic

    private func prescription(_ set: PlannedSet) -> String {
        let base = set.reps == 1 ? "\(set.sets) ×" : "\(set.sets) × \(set.reps)"
        if let load = set.load { return "\(base) · \(load) lb" }
        return base
    }

    private func orderedDeltas(_ deltas: [PillarType: Int]) -> [(pillar: PillarType, delta: Int)] {
        PillarType.allCases.compactMap { p in deltas[p].map { (pillar: p, delta: $0) } }
    }

    /// The workout happened: log it and nudge today's check-in within 1–5.
    private func applyEffects(_ session: WorkoutSession) {
        guard !didApply else { return }
        didApply = true

        let action = PillarAction(
            title: session.plan.name,
            subtitle: "\(session.plan.focus) · \(session.plan.estimatedMinutes) min",
            pillar: .body, isCompleted: true, createdAt: .now, completedAt: .now)
        context.insert(action)

        let target = todaysCheckIn ?? seededCheckIn()
        for (pillar, delta) in TrainingEngine.pillarDeltas(for: session) {
            target.setScore(min(5, max(1, target.score(for: pillar) + delta)), for: pillar)
        }
        try? context.save()
    }

    private var todaysCheckIn: DailyCheckIn? {
        guard let latest = checkIns.first, Calendar.current.isDateInToday(latest.date) else { return nil }
        return latest
    }

    private func seededCheckIn() -> DailyCheckIn {
        let new = DailyCheckIn(date: .now, notes: nil)
        for p in PillarType.allCases { new.setScore(checkIns.first?.score(for: p) ?? 3, for: p) }
        context.insert(new)
        return new
    }
}

#if DEBUG
#Preview {
    TrainModeView()
        .environment(BandManager.previewPaired())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
