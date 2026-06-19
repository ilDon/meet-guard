import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
    private let settingsStore: SettingsStore
    private let onPreview: () -> Void

    init(settingsStore: SettingsStore, onPreview: @escaping () -> Void) {
        self.settingsStore = settingsStore
        self.onPreview = onPreview

        let hostingView = NSHostingView(rootView: SettingsView(settingsStore: settingsStore, onPreview: onPreview))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 590, height: 390),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "MeetGuard"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.backgroundColor = .windowBackgroundColor
        window.minSize = NSSize(width: 590, height: 390)
        window.maxSize = NSSize(width: 590, height: 390)
        window.contentView = hostingView
        window.isReleasedWhenClosed = false
        window.center()

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        window?.center()
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
