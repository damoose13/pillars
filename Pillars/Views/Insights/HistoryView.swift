import SwiftUI
import SwiftData

/// A quiet ledger of past check-ins, newest first. Each row shows the day, its system
/// score, and a compact strip of all eight pillars.
struct HistoryView: View {
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    private var average: Int {
        guard !checkIns.isEmpty else { return 0 }
        return checkIns.reduce(0) { $0 + $1.systemScore } / checkIns.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                header

                if checkIns.isEmpty {
                    emptyState
                } else {
                    statsCard
                    VStack(spacing: PillarsSpacing.s) {
                        ForEach(checkIns) { checkIn in
                            HistoryRow(checkIn: checkIn)
                        }
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

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(checkIn.date.formatted(.dateTime.weekday(.wide)))
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text(checkIn.date.formatted(.dateTime.month(.abbreviated).day().year()))
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.tertiaryText)
                    }
                    Spacer()
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(checkIn.systemScore)")
                            .font(PillarsFont.serif(24, .semibold))
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("/100")
                            .font(PillarsTypography.caption)
                            .foregroundStyle(PillarsColors.tertiaryText)
                    }
                }
                PillarMiniStrip(checkIn: checkIn)
            }
        }
    }
}

/// Eight slim bars — one per pillar, height by score, tinted by pillar color.
private struct PillarMiniStrip: View {
    let checkIn: DailyCheckIn

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(PillarType.allCases) { pillar in
                let score = checkIn.score(for: pillar)
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(pillar.color.opacity(0.85))
                        .frame(height: max(5, CGFloat(score) / 5 * 34))
                        .frame(maxWidth: .infinity)
                    Image(systemName: pillar.icon)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(PillarsColors.tertiaryText)
                }
            }
        }
        .frame(height: 52, alignment: .bottom)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pillar scores")
        .accessibilityValue(PillarType.allCases.map { "\($0.displayName) \(checkIn.score(for: $0))" }.joined(separator: ", "))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HistoryView()
    }
    .environment(AppState())
    .modelContainer(PreviewData.container)
    .preferredColorScheme(.dark)
}
#endif
