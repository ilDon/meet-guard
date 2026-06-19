import Combine
import Foundation

protocol KeyValueStore: AnyObject {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
    @discardableResult
    func synchronize() -> Bool
}

extension NSUbiquitousKeyValueStore: KeyValueStore {}
extension UserDefaults: KeyValueStore {}

final class SettingsStore: ObservableObject {
    private enum Keys {
        static let reminderLeadTime = "alertLeadTimeMinutes"
        static let refreshInterval = "refreshIntervalMinutes"
        static let postponeFactor = "postponeFactor"
        static let launchAtStartup = "launchAtStartup"
        static let dismissedEvents = "dismissedEvents"
    }

    private static let maxDismissedEvents = 20

    private let keyValueStore: KeyValueStore
    private var isReloadingFromStore = false
    private var cancellables = Set<AnyCancellable>()

    @Published var reminderLeadTime: ReminderLeadTime {
        didSet {
            guard !isReloadingFromStore, reminderLeadTime != oldValue else { return }
            keyValueStore.set(reminderLeadTime.rawValue, forKey: Keys.reminderLeadTime)
            keyValueStore.synchronize()
        }
    }

    @Published var refreshInterval: RefreshInterval {
        didSet {
            guard !isReloadingFromStore, refreshInterval != oldValue else { return }
            keyValueStore.set(refreshInterval.rawValue, forKey: Keys.refreshInterval)
            keyValueStore.synchronize()
        }
    }

    @Published var postponeFactor: PostponeFactor {
        didSet {
            guard !isReloadingFromStore, postponeFactor != oldValue else { return }
            keyValueStore.set(postponeFactor.rawValue, forKey: Keys.postponeFactor)
            keyValueStore.synchronize()
        }
    }

    @Published var launchAtStartup: Bool {
        didSet {
            guard !isReloadingFromStore, launchAtStartup != oldValue else { return }
            keyValueStore.set(launchAtStartup, forKey: Keys.launchAtStartup)
            keyValueStore.synchronize()
        }
    }

    @Published private(set) var dismissedEvents: [DismissedEvent] {
        didSet {
            guard !isReloadingFromStore, dismissedEvents != oldValue else { return }
            saveDismissedEvents(dismissedEvents)
        }
    }

    init(keyValueStore: KeyValueStore = NSUbiquitousKeyValueStore.default) {
        self.keyValueStore = keyValueStore
        keyValueStore.synchronize()

        let leadRaw = keyValueStore.object(forKey: Keys.reminderLeadTime) as? Int
        reminderLeadTime = leadRaw.flatMap(ReminderLeadTime.init(rawValue:)) ?? .one

        let refreshRaw = keyValueStore.object(forKey: Keys.refreshInterval) as? Int
        refreshInterval = refreshRaw.flatMap(RefreshInterval.init(rawValue:)) ?? .one

        let postponeRaw = keyValueStore.object(forKey: Keys.postponeFactor) as? Double
        postponeFactor = postponeRaw.flatMap(PostponeFactor.init(rawValue:)) ?? .half

        launchAtStartup = keyValueStore.object(forKey: Keys.launchAtStartup) as? Bool ?? true
        dismissedEvents = Self.loadDismissedEvents(from: keyValueStore)

        if keyValueStore is NSUbiquitousKeyValueStore {
            NotificationCenter.default
                .publisher(
                    for: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                    object: keyValueStore
                )
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.reloadFromStore()
                }
                .store(in: &cancellables)
        }
    }

    convenience init(userDefaults: UserDefaults) {
        self.init(keyValueStore: userDefaults)
    }

    func markDismissed(_ meeting: Meeting, now: Date = Date()) {
        var events = dismissedEvents
        events.removeAll { $0.syncId == meeting.id }
        events.append(DismissedEvent(syncId: meeting.id, timestamp: now.timeIntervalSince1970))
        events.sort { $0.timestamp > $1.timestamp }
        dismissedEvents = Array(events.prefix(Self.maxDismissedEvents))
    }

    func isDismissed(_ meeting: Meeting) -> Bool {
        dismissedEvents.contains { $0.syncId == meeting.id }
    }

    func reloadFromStore() {
        isReloadingFromStore = true

        let leadRaw = keyValueStore.object(forKey: Keys.reminderLeadTime) as? Int
        reminderLeadTime = leadRaw.flatMap(ReminderLeadTime.init(rawValue:)) ?? .one

        let refreshRaw = keyValueStore.object(forKey: Keys.refreshInterval) as? Int
        refreshInterval = refreshRaw.flatMap(RefreshInterval.init(rawValue:)) ?? .one

        let postponeRaw = keyValueStore.object(forKey: Keys.postponeFactor) as? Double
        postponeFactor = postponeRaw.flatMap(PostponeFactor.init(rawValue:)) ?? .half

        launchAtStartup = keyValueStore.object(forKey: Keys.launchAtStartup) as? Bool ?? true
        dismissedEvents = Self.loadDismissedEvents(from: keyValueStore)

        isReloadingFromStore = false
    }

    private func saveDismissedEvents(_ events: [DismissedEvent]) {
        guard let data = try? JSONEncoder().encode(events) else {
            return
        }

        keyValueStore.set(data, forKey: Keys.dismissedEvents)
        keyValueStore.synchronize()
    }

    private static func loadDismissedEvents(from keyValueStore: KeyValueStore) -> [DismissedEvent] {
        guard let data = keyValueStore.object(forKey: Keys.dismissedEvents) as? Data,
              let events = try? JSONDecoder().decode([DismissedEvent].self, from: data) else {
            return []
        }

        return Array(events.sorted { $0.timestamp > $1.timestamp }.prefix(maxDismissedEvents))
    }
}
