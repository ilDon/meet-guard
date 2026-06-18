import AppKit
import SwiftUI

@MainActor
final class OverlayManager {
    private var windows: [NSWindow] = []
    private var retiredWindows: [NSWindow] = []

    func show(
        meeting: Meeting,
        onJoin: @escaping (Meeting) -> Void,
        onPostpone: @escaping (Meeting) -> Void,
        onDismiss: @escaping (Meeting) -> Void
    ) {
        dismiss()

        let content = MeetingOverlayView(
            meeting: meeting,
            onJoin: { onJoin(meeting) },
            onPostpone: { onPostpone(meeting) },
            onDismiss: { onDismiss(meeting) }
        )

        showOnAllScreens(content: content, onDefaultAction: { onJoin(meeting) })
    }

    func showPermissionDenied(onOpenSettings: @escaping () -> Void) {
        dismiss()
        showOnAllScreens(content: PermissionDeniedOverlayView(onOpenSettings: onOpenSettings))
    }

    func dismiss() {
        let windowsToRetire = windows
        windows.removeAll()

        for window in windowsToRetire {
            window.orderOut(nil)
            window.contentView = nil
        }

        retiredWindows.append(contentsOf: windowsToRetire)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.retiredWindows.removeAll()
        }
    }

    private func showOnAllScreens<Content: View>(
        content: Content,
        onDefaultAction: (() -> Void)? = nil
    ) {
        let screens = NSScreen.screens.isEmpty ? [NSScreen.main].compactMap { $0 } : NSScreen.screens

        windows = screens.map { screen in
            let window = ShieldedWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )

            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.level = .screenSaver
            window.animationBehavior = .none
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.isReleasedWhenClosed = false
            window.ignoresMouseEvents = false
            window.onDefaultAction = onDefaultAction
            window.contentView = NSHostingView(rootView: content.frame(maxWidth: .infinity, maxHeight: .infinity))
            window.makeKeyAndOrderFront(nil)

            return window
        }

        NSApp.activate(ignoringOtherApps: true)
    }
}

private final class ShieldedWindow: NSWindow {
    var onDefaultAction: (() -> Void)?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 || event.keyCode == 76 {
            onDefaultAction?()
            return
        }

        super.keyDown(with: event)
    }

    override func cancelOperation(_ sender: Any?) {
        // ESC is intentionally ignored. The overlay requires an explicit action.
    }

    override func performClose(_ sender: Any?) {
        // Command-W is intentionally ignored. The overlay requires an explicit action.
    }
}
