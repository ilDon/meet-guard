import SwiftUI

@main
struct MeetGuardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(
                settingsStore: AppContainer.shared.settingsStore,
                onPreview: {
                    AppContainer.shared.appController.showOverlayPreview()
                }
            )
        }
    }
}
