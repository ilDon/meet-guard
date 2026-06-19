import Foundation
import Testing
@testable import MeetGuard

@Suite("SettingsStore")
struct SettingsStoreTests {
    @Test("defaults reminder lead time to one minute")
    func defaultsReminderLeadTimeToOneMinute() throws {
        let suiteName = "MeetGuardTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(userDefaults: defaults)

        #expect(store.reminderLeadTime == .one)
    }

    @Test("defaults launch at startup to true")
    func defaultsLaunchAtStartupToTrue() throws {
        let suiteName = "MeetGuardTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(userDefaults: defaults)

        #expect(store.launchAtStartup)
    }

    @Test("stores only twenty most recent dismissed events")
    func storesOnlyTwentyMostRecentDismissedEvents() throws {
        let suiteName = "MeetGuardTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(userDefaults: defaults)

        for index in 0..<25 {
            store.markDismissed(
                makeMeeting(id: "event-\(index)"),
                now: Date(timeIntervalSince1970: TimeInterval(index))
            )
        }

        #expect(store.dismissedEvents.count == 20)
        #expect(store.dismissedEvents.first?.syncId == "event-24")
        #expect(store.dismissedEvents.last?.syncId == "event-5")
    }

    @Test("deduplicates dismissed event by sync id")
    func deduplicatesDismissedEventBySyncId() throws {
        let suiteName = "MeetGuardTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(userDefaults: defaults)
        let meeting = makeMeeting(id: "event-1")

        store.markDismissed(meeting, now: Date(timeIntervalSince1970: 1))
        store.markDismissed(meeting, now: Date(timeIntervalSince1970: 2))

        #expect(store.dismissedEvents == [DismissedEvent(syncId: "event-1", timestamp: 2)])
    }

    private func makeMeeting(id: String) -> Meeting {
        let start = Date(timeIntervalSince1970: 1_000)

        return Meeting(
            id: id,
            title: "Weekly Product Review",
            startDate: start,
            endDate: start.addingTimeInterval(30 * 60),
            calendarTitle: "Work",
            url: URL(string: "https://meet.google.com/abc-defg-hij")!
        )
    }
}
