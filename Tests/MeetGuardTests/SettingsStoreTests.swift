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
}
