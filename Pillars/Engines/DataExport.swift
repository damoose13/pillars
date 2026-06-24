import Foundation

/// Local, privacy-respecting export of the user's check-in history to a JSON file. Nothing
/// leaves the device unless the user explicitly shares the file they get.
enum DataExport {
    struct CheckInRecord: Codable {
        let date: Date
        let notes: String?
        let scores: [String: Int]
    }

    /// Encode all check-ins to a pretty JSON file in the temp directory; returns its URL.
    static func makeFile(from checkIns: [DailyCheckIn]) -> URL? {
        let records = checkIns
            .sorted { $0.date < $1.date }
            .map { checkIn in
                CheckInRecord(
                    date: checkIn.date,
                    notes: checkIn.notes,
                    scores: Dictionary(uniqueKeysWithValues:
                        PillarType.allCases.map { ($0.rawValue, checkIn.score(for: $0)) })
                )
            }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records) else { return nil }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("pillars-export.json")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
