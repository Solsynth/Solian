import Cocoa
import FlutterMacOS

/// Bridges runtime app icon switching on macOS over the
/// `dev.solsynth.solian/app_icon` channel.
///
/// macOS has no public alternate-icon API (`UIApplication.setAlternateIconName`
/// is iOS-only), so this swaps the Dock icon for the running session via
/// `NSApp.applicationIconImage` and persists the choice in `UserDefaults` to
/// re-apply on the next launch. Finder/Launchpad icons are unaffected.
final class AppIconChannel {
  static let channelName = "dev.solsynth.solian/app_icon"
  static let storedIconNameKey = "app_icon_name"

  private init() {}

  static func install(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getIconState":
        result([
          "supported": true,
          "current": UserDefaults.standard.string(
            forKey: storedIconNameKey
          ) as Any,
        ])
      case "setAlternateIcon":
        guard let arguments = call.arguments as? [String: Any] else {
          result(FlutterError(
            code: "INVALID_ARGUMENTS",
            message: "Expected a payload with an optional `name` string.",
            details: nil
          ))
          return
        }
        let name = arguments["name"] as? String
        applyIcon(name: name)
        if let name {
          UserDefaults.standard.set(name, forKey: storedIconNameKey)
        } else {
          UserDefaults.standard.removeObject(forKey: storedIconNameKey)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Re-applies the persisted icon choice on launch. No-op when the user
  /// never switched away from the default.
  static func applyPersistedIconIfNeeded() {
    guard let name = UserDefaults.standard.string(forKey: storedIconNameKey) else {
      return
    }
    applyIcon(name: name)
  }

  private static func applyIcon(name: String?) {
    if let name, let image = NSImage(named: name) {
      NSApp.applicationIconImage = image
      NSLog("[AppIcon] applied alternate icon: %@", name)
    } else {
      // `applicationIconImage` is null-resettable: nil restores the app's
      // default icon for the running session.
      NSApp.applicationIconImage = nil
      if name != nil {
        NSLog("[AppIcon] icon not found in bundle: %@", name!)
      }
    }
  }
}
