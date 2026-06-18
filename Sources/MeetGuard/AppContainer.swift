import Foundation

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    let settingsStore: SettingsStore
    let appController: AppController

    private init() {
        let settingsStore = SettingsStore()
        self.settingsStore = settingsStore
        appController = AppController(settingsStore: settingsStore)
    }
}
