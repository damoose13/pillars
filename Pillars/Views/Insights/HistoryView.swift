import SwiftUI
import SwiftData

/// A quiet ledger of past check-ins, newest first. Each row shows the day, its system
/// score, and a compact strip of all eight pillars.
struct HistoryView: View {
    @Environment(EntitlementManager.self) private var entitlements
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    @State private var showPaywall = false

    /// Free tier sees the most recent week; Plus sees everything.
    private let freeWindow = 7

    private var average: Int {
        guard !checkIns.isEmpty else { return 0 }
        return checkIns.reduce(0) { $0 + $1.systemScore } / checkIns.count
    }

    private var visibleCheckIns: [DailyCheckIn] {
        if entitlements.isEntitled(to: .fullHistory) { return checkIns }
        return Array(checkIns.prefix(freeWindow))
    }

    private var hiddenCount: Int {
        max(0, checkIns.count - visibleCheckIns.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                header

                if checkIns.isEmpty {
                    emptyState
                } else {
                    rhythmCard
                    statsCard
                    VStack(spacing: PillarsSpacing.s) {
                        ForEach(visibleCheckIns) { checkIn in
                            HistoryRow(checkIn: checkIn)
                        }
                    }
                    if hiddenCount > 0 {
                        LockedFeatureCard(feature: .fullHistory) { showPaywall = true }
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
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showPaywall) { PaywallView(highlightTier: .plus) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("Your record")
                .pillarsOverline(PillarsColors.gold.opacity(0.9))
            Text("Every check-in,\nkept private.")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
                .lineSpacing(2)
        }
    }

    /// Distinct start-of-day dates that have a check-in.
    private var checkInDays: Set<Date> {
        Set(checkIns.map { Calendar.current.startOfDay(for: $0.date) })
    }

    private var daysThisMonth: Int {
        let cal = Calendar.current
        guard let first = cal.date(from: cal.dateComponents([.year, .month], from: Date())) else { return 0 }
        return checkInDays.filter { $0 >= first }.count
    }

    /// New: a calm month grid of presence — continuity without streaks.
    private var rhythmCard: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                HStack(alignment: .firstTextBaseline) {
                    Text(Date().formatted(.dateTime.month(.wide).year()))
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Spacer()
                    Text("\(daysThisMonth) day\(daysThisMonth == 1 ? "" : "s") here")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.secondaryText)
                }
                RhythmCalendar(checkInDays: checkInDays)
                Text("A record of presence — not a streak to protect.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
        }
    }

    private var statsCard: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.l) {
                stat(value: "\(checkIns.count)", label: "Check-ins")
                Divider().frame(height: 36).overlay(PillarsColors.cardBorder)
                stat(value: "\(average)", label: "Average score")
                Spacer(minLength: 0)
            }
        }
    }

    private func stat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(PillarsFont.serif(28, .semibold))
                .foregroundStyle(PillarsColors.primaryText)
            Text(label)
                .font(PillarsTypography.caption)
                .foregroundStyle(PillarsColors.secondaryText)
        }
    }

    private var emptyState: some View {
        PillarGlassCard(padding: PillarsSpacing.xl) {
            VStack(spacing: PillarsSpacing.m) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(PillarsColors.gold)
                Text("No check-ins yet")
                    .font(PillarsTypography.title)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("Your history begins with your first check-in and stays only on this device.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Row

private struct HistoryRow: View {
    let checkIn: DailyCheckIn

    private var scores: [PillarWebScore] {
        PillarType.allCases.map { PillarWebScore(pillar: $0, score: checkIn.score(for: $0)) }
    }

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(spacing: PillarsSpacing.m) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(checkIn.date.formatted(.dateTime.weekday(.wide)))
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Text(checkIn.date.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(checkIn.systemScore)")
                            .font(PillarsFont.serif(24, .semibold))
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("/100")
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.tertiaryText)
                    }
                    .padding(.top, 4)
                }
                Spacer(minLength: 0)
                DynamicPillarWebView(scores: scores, mode: .mini)
                    .frame(width: 72, height: 72)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Pillar shape")
                    .accessibilityValue(PillarType.allCases.map { "\($0.displayName) \(checkIn.score(for: $0))" }.joined(separator: ", "))
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HistoryView()
    }
    .environment(AppState())
    .environment(EntitlementManager())
    .modelContainer(PreviewData.container)
    .preferredColorScheme(.dark)
}
#endif
