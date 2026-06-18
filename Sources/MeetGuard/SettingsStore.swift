import Foundation
import Combine

final class SettingsStore: ObservableObject {
    private enum Keys {
        static let reminderLeadTime = "reminderLeadTime"
        static let refreshInterval = "refreshInterval"
        static let postponeFactor = "postponeFactor"
        static let launchAtStartup = "launchAtStartup"
    }

    private let userDefaults: UserDefaults

    @Published var reminderLeadTime: ReminderLeadTime {
        didSet { userDefaults.set(reminderLeadTime.rawValue, forKey: Keys.reminderLeadTime) }
    }

    @Published var refreshInterval: RefreshInterval {
        didSet { userDefaults.set(refreshInterval.rawValue, forKey: Keys.refreshInterval) }
    }

    @Published var postponeFactor: PostponeFactor {
        didSet { userDefaults.set(postponeFactor.rawValue, forKey: Keys.postponeFactor) }
    }

    @Published var launchAtStartup: Bool {
        didSet { userDefaults.set(launchAtStartup, forKey: Keys.launchAtStartup) }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        let leadRaw = userDefaults.object(forKey: Keys.reminderLeadTime) as? Int
        reminderLeadTime = leadRaw.flatMap(ReminderLeadTime.init(rawValue:)) ?? .one

        let refreshRaw = userDefaults.object(forKey: Keys.refreshInterval) as? Int
        refreshInterval = refreshRaw.flatMap(RefreshInterval.init(rawValue:)) ?? .one

        let postponeRaw = userDefaults.object(forKey: Keys.postponeFactor) as? Double
        postponeFactor = postponeRaw.flatMap(PostponeFactor.init(rawValue:)) ?? .half

        launchAtStartup = userDefaults.object(forKey: Keys.launchAtStartup) as? Bool ?? true
    }
}
