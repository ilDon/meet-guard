import AppKit

extension NSImage {
    static func meetGuardAppIcon() -> NSImage {
        NSImage(named: "MeetGuardIcon") ?? .meetGuardMenuBarIcon()
    }

    static func meetGuardStatusBarIcon() -> NSImage {
        let source = NSImage(named: "MeetGuardMenuBarIcon") ?? meetGuardAppIcon()
        let targetSize = NSSize(width: 18, height: 18)
        let image = NSImage(size: targetSize)

        image.lockFocus()
        source.draw(
            in: NSRect(origin: .zero, size: targetSize),
            from: NSRect(origin: .zero, size: source.size),
            operation: .sourceOver,
            fraction: 1
        )
        image.unlockFocus()

        image.isTemplate = false
        return image
    }

    static func meetGuardMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)

        image.lockFocus()

        NSColor.black.setFill()

        let shield = NSBezierPath()
        shield.move(to: NSPoint(x: 9, y: 17))
        shield.curve(
            to: NSPoint(x: 15, y: 13.8),
            controlPoint1: NSPoint(x: 10.8, y: 16.4),
            controlPoint2: NSPoint(x: 13.1, y: 15.5)
        )
        shield.line(to: NSPoint(x: 15, y: 8.8))
        shield.curve(
            to: NSPoint(x: 9, y: 1.2),
            controlPoint1: NSPoint(x: 15, y: 5.1),
            controlPoint2: NSPoint(x: 12.4, y: 2.5)
        )
        shield.curve(
            to: NSPoint(x: 3, y: 8.8),
            controlPoint1: NSPoint(x: 5.6, y: 2.5),
            controlPoint2: NSPoint(x: 3, y: 5.1)
        )
        shield.line(to: NSPoint(x: 3, y: 13.8))
        shield.curve(
            to: NSPoint(x: 9, y: 17),
            controlPoint1: NSPoint(x: 4.9, y: 15.5),
            controlPoint2: NSPoint(x: 7.2, y: 16.4)
        )
        shield.close()
        shield.fill()

        NSColor.clear.setFill()
        let cameraBody = NSBezierPath(roundedRect: NSRect(x: 5, y: 7, width: 6.7, height: 4.6), xRadius: 1.1, yRadius: 1.1)
        cameraBody.fill()

        let lens = NSBezierPath()
        lens.move(to: NSPoint(x: 11.2, y: 10.2))
        lens.line(to: NSPoint(x: 14, y: 12))
        lens.line(to: NSPoint(x: 14, y: 6.6))
        lens.line(to: NSPoint(x: 11.2, y: 8.2))
        lens.close()
        lens.fill()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
