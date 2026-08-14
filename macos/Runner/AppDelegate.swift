import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let deepLinkChannelName = "dev.solsynth.solian/deeplink"
  private var deepLinkChannel: FlutterMethodChannel?
  private var pendingDeepLinkURL: String?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
  }

  func setupDeepLinkChannel(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: deepLinkChannelName,
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "consumePendingDeepLink":
        result(self?.consumePendingDeepLink())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    deepLinkChannel = channel
    emitPendingDeepLinkIfNeeded()
  }

  override func application(
    _ application: NSApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void
  ) -> Bool {
    guard let webpageURL = userActivity.webpageURL else {
      return super.application(
        application,
        continue: userActivity,
        restorationHandler: restorationHandler
      )
    }
    return handleIncomingDeepLink(webpageURL)
  }

  private func handleIncomingDeepLink(_ url: URL) -> Bool {
    let isSolianLink = url.scheme == "solian"
    let isSolianWebLink =
      (url.scheme == "http" || url.scheme == "https") &&
      url.host == "solian.app"
    guard isSolianLink || isSolianWebLink else {
      return false
    }
    pendingDeepLinkURL = url.absoluteString
    emitPendingDeepLinkIfNeeded()
    return true
  }

  private func emitPendingDeepLinkIfNeeded() {
    guard let urlString = pendingDeepLinkURL, let channel = deepLinkChannel else {
      return
    }
    channel.invokeMethod("onDeepLink", arguments: urlString)
  }

  private func consumePendingDeepLink() -> String? {
    defer { pendingDeepLinkURL = nil }
    return pendingDeepLinkURL
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool)
    -> Bool
  {
    if !flag {
      for window in NSApp.windows {
        if !window.isVisible {
          window.setIsVisible(true)
        }
        window.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
      }
    }
    return true
  }
}
