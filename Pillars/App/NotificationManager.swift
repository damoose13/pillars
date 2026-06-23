import Foundation
import UserNotifications
import Observation

/// A single, gentle daily reminder to check in — the retention lever for the core loop.
/// Local notifications only: no backend, no tracking, nothing leaves the device.
@Observable
@MainActor
final class NotificationManager {

    private(set) var reminderEnabled: Bool
    var reminderTime: Date { didSet { saveTime() } }
    /// True when the user has declined system permission (so we can guide them to Settings).
    private(set) var permissionDenied = false

    private let defaults = UserDefaults.standard
    private let requestID = "pillars.dailyCheckIn"

    init() {
        reminderEnabled = defaults.bool(forKey: Keys.enabled)
        let hour = defaults.object(forKey: Keys.hour) as? Int ?? 9
        let minute = defaults.object(forKey: Keys.minute) as? Int ?? 0
        reminderTime = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? .now
    }

    /// Re-sync on launch: clear stale schedules if permission was revoked, otherwise ensure
    /// the reminder is in place.
    func refresh() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        permissionDenied = settings.authorizationStatus == .denied
        if reminderEnabled, settings.authorizationStatus == .authorized {
            await schedule()
        }
    }

    /// Turn the daily reminder on (requesting permission) or off.
    func setEnabled(_ on: Bool) async {
        guard on else {
            reminderEnabled = false
            defaults.set(false, forKey: Keys.enabled)
            cancel()
            return
        }
        let granted = (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])) ?? false
        if granted {
            reminderEnabled = true
            permissionDenied = false
            defaults.set(true, forKey: Keys.enabled)
            await schedule()
        } else {
            reminderEnabled = false
            permissionDenied = true
            defaults.set(false, forKey: Keys.enabled)
        }
    }

    func updateTime(_ date: Date) async {
        reminderTime = date
        if reminderEnabled { await schedule() }
    }

    // MARK: Scheduling

    private func schedule() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestID])

        let content = UNMutableNotificationContent()
        content.title = "Pillars"
        content.body = "A quiet minute. How are your pillars today?"

        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        try? await center.add(request)
    }

    private func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestID])
    }

    private func saveTime() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        defaults.set(comps.hour, forKey: Keys.hour)
        defaults.set(comps.minute, forKey: Keys.minute)
    }

    private enum Keys {
        static let enabled = "pillars.reminderEnabled"
        static let hour = "pillars.reminderHour"
        static let minute = "pillars.reminderMinute"
    }
}
