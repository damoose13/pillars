import Foundation
import HealthKit
import Observation

/// Optional, on-device Apple Health integration. Reads a minimal, read-only set of signals and
/// turns them into *suggested* 1–5 pillar scores that prefill the daily check-in — the person
/// always confirms or overrides. Nothing is uploaded; data is read on the device only.
///
/// HealthKit needs the HealthKit capability (added in Xcode → Signing & Capabilities) and is
/// limited in the Simulator, so this is exercised on a real device. The app works fully without it.
@MainActor
@Observable
final class HealthKitManager {
    private let store = HKHealthStore()

    private(set) var isConnected: Bool

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    private enum Keys { static let connected = "pillars.healthConnected" }

    init() {
        isConnected = UserDefaults.standard.bool(forKey: Keys.connected)
    }

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        let quantities: [HKQuantityTypeIdentifier] = [
            .appleExerciseTime, .activeEnergyBurned, .stepCount,
            .dietaryEnergyConsumed, .dietaryWater, .heartRateVariabilitySDNN, .restingHeartRate
        ]
        for id in quantities {
            if let t = HKObjectType.quantityType(forIdentifier: id) { types.insert(t) }
        }
        let categories: [HKCategoryTypeIdentifier] = [.sleepAnalysis, .mindfulSession]
        for id in categories {
            if let t = HKObjectType.categoryType(forIdentifier: id) { types.insert(t) }
        }
        return types
    }

    /// Request read-only access. Returns once the system prompt is handled.
    func connect() async {
        guard isAvailable else { return }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isConnected = true
            UserDefaults.standard.set(true, forKey: Keys.connected)
        } catch {
            isConnected = false
        }
    }

    /// Stop using Health data. (Apple manages actual permission revocation in system Settings.)
    func disconnect() {
        isConnected = false
        UserDefaults.standard.set(false, forKey: Keys.connected)
    }

    /// Suggested 1–5 scores for the pillars we can confidently read today. Only pillars with
    /// real data are included; absence never pushes a score down.
    func todaySuggestions() async -> [PillarType: Int] {
        guard isAvailable, isConnected else { return [:] }
        var out: [PillarType: Int] = [:]

        if let minutes = await sumToday(.appleExerciseTime, unit: .minute()), minutes > 0 {
            out[.body] = banded(minutes, cutoffs: [45, 30, 15, 5])
        }
        if let hours = await asleepHoursLastNight() {
            out[.sleep] = banded(hours, cutoffs: [8, 7, 6, 5])
        }
        if let mindful = await mindfulMinutesToday(), mindful > 0 {
            out[.mind] = mindful >= 15 ? 4 : 3
        }
        if let water = await sumToday(.dietaryWater, unit: .liter()), water >= 1.5 {
            out[.fuel] = water >= 2.5 ? 4 : 3
        }
        return out
    }

    // MARK: Queries

    private var startOfToday: Date { Calendar.current.startOfDay(for: Date()) }

    /// 5/4/3/2 for each descending cutoff, else 1.
    private func banded(_ value: Double, cutoffs: [Double]) -> Int {
        for (i, cutoff) in cutoffs.enumerated() where value >= cutoff { return 5 - i }
        return 1
    }

    private func sumToday(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: startOfToday, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }

    private func mindfulMinutesToday() async -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: startOfToday, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate,
                                      limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let minutes = (samples ?? []).reduce(0.0) { acc, sample in
                    acc + sample.endDate.timeIntervalSince(sample.startDate) / 60
                }
                continuation.resume(returning: minutes)
            }
            store.execute(query)
        }
    }

    private func asleepHoursLastNight() async -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let end = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: end) ?? end
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate,
                                      limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let seconds = (samples ?? [])
                    .compactMap { $0 as? HKCategorySample }
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                let hours = seconds / 3600
                continuation.resume(returning: hours > 0 ? hours : nil)
            }
            store.execute(query)
        }
    }
}
