import Foundation
import ServiceManagement

@MainActor
final class LaunchAtStartupService {
    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                guard SMAppService.mainApp.status != .enabled else { return }
                try SMAppService.mainApp.register()
            } else {
                guard SMAppService.mainApp.status == .enabled || SMAppService.mainApp.status == .requiresApproval else { return }
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("MeetGuard failed to update launch at startup: \(error.localizedDescription)")
        }
    }
}
