import AppKit
import SwiftUI

final class CallWindowController {
    private var window: NSWindow?
    private let manager: CallManager

    init(manager: CallManager) {
        self.manager = manager
    }

    func showWindow() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let callView = CallExpandedView(
            state: manager.state,
            onToggleMic: { Task { @MainActor in await self.manager.toggleMic() } },
            onToggleCamera: { Task { @MainActor in await self.manager.toggleCamera() } },
            onToggleSpeaker: { Task { @MainActor in await self.manager.toggleSpeaker() } },
            onToggleViewMode: { Task { @MainActor in self.manager.toggleViewMode() } },
            onLeave: {
                Task { @MainActor in
                    await self.manager.leaveRoom()
                    self.closeWindow()
                }
            }
        )

        let hostingView = NSHostingView(rootView: callView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 800, height: 600)

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        w.title = manager.state.roomName ?? "Call"
        w.contentView = hostingView
        w.isReleasedWhenClosed = false
        w.center()
        w.makeKeyAndOrderFront(nil)

        // Close button = leave call
        w.delegate = WindowDelegate { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                await self.manager.leaveRoom()
                self.closeWindow()
            }
        }

        window = w
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeWindow() {
        window?.close()
        window = nil
    }

    func updateTitle() {
        window?.title = manager.state.roomName ?? "Call"
    }
}

// ponytail: minimal delegate to intercept close
private final class WindowDelegate: NSObject, NSWindowDelegate {
    let onClose: () -> Void
    init(onClose: @escaping () -> Void) { self.onClose = onClose }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
