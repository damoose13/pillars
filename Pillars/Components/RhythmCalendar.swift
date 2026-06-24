import SwiftUI

/// A calm month grid of the days you checked in — continuity without streaks. Filled gold for
/// a day with a check-in, a quiet ring for today, faint for the rest. No counts to chase.
struct RhythmCalendar: View {
    /// Start-of-day dates that have a check-in.
    let checkInDays: Set<Date>

    private let cal = Calendar.current

    var body: some View {
        VStack(spacing: PillarsSpacing.s) {
            HStack(spacing: 0) {
                ForEach(weekdaySymbols.indices, id: \.self) { i in
                    Text(weekdaySymbols[i])
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(PillarsColors.tertiaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 7) {
                ForEach(monthDays.indices, id: \.self) { i in
                    cell(monthDays[i])
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Check-in calendar for this month")
        .accessibilityValue("The days you checked in are marked.")
    }

    @ViewBuilder private func cell(_ date: Date?) -> some View {
        if let date {
            let day = cal.startOfDay(for: date)
            let hasCheckIn = checkInDays.contains(day)
            let isToday = cal.isDateInToday(date)
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(hasCheckIn ? PillarsColors.gold.opacity(0.9) : Color.white.opacity(0.05))
                    .overlay {
                        if isToday {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(PillarsColors.gold, lineWidth: 1.5)
                        }
                    }
                Text("\(cal.component(.day, from: date))")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(hasCheckIn ? PillarsColors.background : PillarsColors.tertiaryText)
            }
            .frame(height: 30)
        } else {
            Color.clear.frame(height: 30)
        }
    }

    /// Current month's days, padded with leading nils so the 1st lands on its weekday.
    private var monthDays: [Date?] {
        let comps = cal.dateComponents([.year, .month], from: Date())
        guard let first = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: first) else { return [] }
        let weekdayOfFirst = cal.component(.weekday, from: first)
        let leading = (weekdayOfFirst - cal.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: leading)
        for d in range {
            days.append(cal.date(byAdding: .day, value: d - 1, to: first))
        }
        return days
    }

    /// Very-short weekday symbols rotated to the locale's first weekday.
    private var weekdaySymbols: [String] {
        let symbols = cal.veryShortWeekdaySymbols
        let shift = cal.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }
}
