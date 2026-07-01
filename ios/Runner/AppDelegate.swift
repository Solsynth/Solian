import Flutter
import WidgetKit
import UIKit
import WatchConnectivity
import AppIntents
import Intents
import PushKit
import flutter_sharing_intent
import Kingfisher

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CallKeepPushDelegate {
    let notifyDelegate = NotifyDelegate()
    private static var sharedWatchConnectivityService: WatchConnectivityService?
    private let callKeepPushRegistry = PKPushRegistry(queue: .main)
    private let deepLinkChannelName = "dev.solsynth.solian/deeplink"
    private let shareSuggestionsChannelName = "dev.solsynth.solian/share_suggestions"
    private var implicitDeepLinkChannel: FlutterMethodChannel?
    
    private func refreshAppIntents() {
        guard #available(iOS 16.0, *) else {
            return
        }
        
        AppShortcuts.updateAppShortcutParameters()
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        sendCfgToAppGroup()
        refreshAppIntents()
        WidgetCenter.shared.reloadAllTimelines()

        if let launchUrl = launchOptions?[.url] as? URL {
            _ = handleIncomingDeepLink(launchUrl)
        }

        UNUserNotificationCenter.current().delegate = notifyDelegate

        let replyableMessageCategory = UNNotificationCategory(
            identifier: "CHAT_MESSAGE",
            actions: [
                UNTextInputNotificationAction(
                    identifier: "reply_action",
                    title: "Reply",
                    options: []
                ),
            ],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([replyableMessageCategory])

        if WCSession.isSupported() {
            AppDelegate.sharedWatchConnectivityService = WatchConnectivityService.shared
        } else {
            print("[iOS] WCSession not supported on this device.")
        }
        print("[CallKeep] Registering PushKit payload delegate")
        CallKeep.setDelegate(self)
        callKeepPushRegistry.delegate = CallKeep()
        callKeepPushRegistry.desiredPushTypes = [.voIP]
        print("[CallKeep] Retained PushKit registry active")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func mapPushPayload(_ payload: [AnyHashable : Any]) -> [AnyHashable : Any]? {
        print("[CallKeep] mapPushPayload incoming keys=\(Array(payload.keys))")

        guard payload["aps"] != nil else {
            print("[CallKeep] mapPushPayload passthrough: no aps block")
            return payload
        }

        guard let meta = payload["meta"] as? [String: Any] else {
            print("[CallKeep] mapPushPayload passthrough: aps present but meta missing")
            return payload
        }

        var mapped = meta
        mapped["meta"] = meta
        mapped["caller_id"] = stringValue(meta["caller_id"]) ?? stringValue(meta["callerId"])
        mapped["caller_name"] = stringValue(meta["caller_name"]) ?? stringValue(meta["callerName"]) ?? callerName(from: payload)
        mapped["room_id"] = stringValue(meta["room_id"]) ?? stringValue(meta["roomId"])
        mapped["uuid"] = stringValue(meta["uuid"]) ?? stringValue(meta["call_uuid"]) ?? stringValue(meta["callUuid"])
        mapped["has_video"] = boolValue(meta["has_video"] ?? meta["hasVideo"])
        mapped["caller_id_type"] = callerIdType(from: mapped["caller_id"])

        let caller = stringValue(mapped["caller_name"]) ?? "nil"
        let room = stringValue(mapped["room_id"]) ?? "nil"
        let uuid = stringValue(mapped["uuid"]) ?? "nil"
        let handle = stringValue(mapped["caller_id"]) ?? "nil"
        print("[CallKeep] mapped push caller=\(caller) room=\(room) uuid=\(uuid) handle=\(handle)")
        return mapped
    }

    func onCallEvent(_ event: String, withCallData callData: [AnyHashable : Any]) {
        print("[CallKeep] event=\(event) data=\(callData)")
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        setupWidgetSyncChannel(engineBridge: engineBridge)
        implicitDeepLinkChannel = makeDeepLinkChannel(
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )
        emitPendingDeepLinkIfNeeded()
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
         let sharingIntent = SwiftFlutterSharingIntentPlugin.instance
         /// if the url is made from SwiftFlutterSharingIntentPlugin then handle it with plugin [SwiftFlutterSharingIntentPlugin]
         if sharingIntent.hasSameSchemePrefix(url: url) {
             return sharingIntent.application(app, open: url, options: options)
         }

         if handleIncomingDeepLink(url) {
             return true
         }

         // Proceed url handling for other Flutter libraries like uni_links
         return super.application(app, open: url, options:options)
       }

    private func stringValue(_ value: Any?) -> String? {
        guard let value else { return nil }
        let text = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private func boolValue(_ value: Any?) -> Bool {
        switch value {
        case let value as Bool:
            return value
        case let value as NSNumber:
            return value.boolValue
        case let value as String:
            switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "true", "1", "yes":
                return true
            default:
                return false
            }
        default:
            return false
        }
    }

    private func callerName(from payload: [AnyHashable : Any]) -> String? {
        guard let aps = payload["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any] else {
            return nil
        }
        return stringValue(alert["title"]) ?? stringValue(alert["body"])
    }

    private func callerIdType(from callerId: Any?) -> String {
        guard let callerId = stringValue(callerId) else {
            return "generic"
        }
        let digits = CharacterSet.decimalDigits
        let phoneChars = digits.union(CharacterSet(charactersIn: "+-() "))
        return callerId.unicodeScalars.allSatisfy(phoneChars.contains) ? "number" : "generic"
    }

    private func makeDeepLinkChannel(binaryMessenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
        let channel = FlutterMethodChannel(
            name: deepLinkChannelName,
            binaryMessenger: binaryMessenger
        )
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "consumePendingDeepLink":
                result(self.consumePendingDeepLink())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        return channel
    }

    private func handleIncomingDeepLink(_ url: URL) -> Bool {
        guard url.scheme == SharedConstants.urlScheme else {
            return false
        }

        let urlString = url.absoluteString
        UserDefaults.shared.set(urlString, forKey: SharedConstants.pendingDeepLinkUrlKey)
        UserDefaults.shared.synchronize()
        emitPendingDeepLinkIfNeeded()
        return true
    }

    private func emitPendingDeepLinkIfNeeded() {
        guard let urlString = UserDefaults.shared.string(forKey: SharedConstants.pendingDeepLinkUrlKey),
              !urlString.isEmpty,
              let channel = implicitDeepLinkChannel else {
            return
        }

        channel.invokeMethod("onDeepLink", arguments: urlString)
    }

    private func consumePendingDeepLink() -> String? {
        let defaults = UserDefaults.shared
        defer {
            defaults.removeObject(forKey: SharedConstants.pendingDeepLinkUrlKey)
            defaults.synchronize()
        }

        return defaults.string(forKey: SharedConstants.pendingDeepLinkUrlKey)
    }

    private func setupWidgetSyncChannel(engineBridge: FlutterImplicitEngineBridge) {
        let channel = FlutterMethodChannel(
            name: "dev.solsynth.solian/widget",
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )

        channel.setMethodCallHandler { (call, result) in
            if call.method == "sendCfgToAppGroup" {
                sendCfgToAppGroup()
                self.refreshAppIntents()
                WidgetCenter.shared.reloadAllTimelines()
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        // Cache management channel
        let cacheChannel = FlutterMethodChannel(
            name: "dev.solsynth.solian/cache",
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )
        
        cacheChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "clearImageCache":
                self?.clearImageCache(result: result)
            case "getImageCacheSize":
                self?.getImageCacheSize(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        let shareSuggestionsChannel = FlutterMethodChannel(
            name: shareSuggestionsChannelName,
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )

        shareSuggestionsChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(FlutterError(code: "APP_DELEGATE_DEALLOCATED", message: nil, details: nil))
                return
            }

            switch call.method {
            case "donateChatConversation":
                guard let arguments = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected donation payload", details: nil))
                    return
                }
                self.donateChatConversation(arguments: arguments)
                result(nil)
            case "consumePendingShareTarget":
                result(self.consumePendingShareTarget())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func donateChatConversation(arguments: [String: Any]) {
        guard let roomId = arguments["roomId"] as? String,
              !roomId.isEmpty,
              let displayName = arguments["displayName"] as? String,
              !displayName.isEmpty else {
            return
        }

        let isDirect = arguments["isDirect"] as? Bool ?? false
        let recipientAccountName = arguments["recipientAccountName"] as? String
        let recipientNick = arguments["recipientNick"] as? String

        let recipients: [INPerson]?
        if isDirect, let recipientIdentifier = (recipientAccountName?.isEmpty == false ? recipientAccountName : recipientNick), !recipientIdentifier.isEmpty {
            let handle = INPersonHandle(value: recipientIdentifier, type: .unknown)
            var components = PersonNameComponents()
            components.nickname = recipientNick ?? recipientIdentifier
            recipients = [
                INPerson(
                    personHandle: handle,
                    nameComponents: components,
                    displayName: recipientNick ?? recipientIdentifier,
                    image: nil,
                    contactIdentifier: nil,
                    customIdentifier: recipientAccountName ?? recipientIdentifier
                )
            ]
        } else {
            recipients = nil
        }

        let intent = INSendMessageIntent(
            recipients: recipients,
            outgoingMessageType: .outgoingMessageText,
            content: nil,
            speakableGroupName: INSpeakableString(spokenPhrase: displayName),
            conversationIdentifier: roomId,
            serviceName: Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
            sender: nil,
            attachments: nil
        )

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .outgoing
        interaction.donate(completion: nil)
    }

    private func consumePendingShareTarget() -> [String: String]? {
        let defaults = UserDefaults.shared
        defer {
            defaults.removeObject(forKey: SharedConstants.pendingShareTargetRoomIdKey)
            defaults.synchronize()
        }

        guard let roomId = defaults.string(forKey: SharedConstants.pendingShareTargetRoomIdKey),
              !roomId.isEmpty else {
            return nil
        }

        return ["roomId": roomId]
    }
    
    private func clearImageCache(result: @escaping FlutterResult) {
        configureKingfisherCache()
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
        print("[AppDelegate] Image cache cleared")
        result(true)
    }
    
    private func getImageCacheSize(result: @escaping FlutterResult) {
        configureKingfisherCache()
        KingfisherManager.shared.cache.calculateDiskStorageSize { sizeResult in
            switch sizeResult {
            case .success(let size):
                let sizeInMB = Double(size) / 1024.0 / 1024.0
                result(["sizeInBytes": size, "sizeInMB": String(format: "%.2f", sizeInMB)])
            case .failure(let error):
                result(FlutterError(code: "CACHE_ERROR", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    private func configureKingfisherCache() {
        let appGroupId = "group.solsynth.solian"
        guard let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            print("[AppDelegate] Failed to get App Group container")
            return
        }
        
        let cachePath = containerUrl.appendingPathComponent("KingfisherCache").path
        
        let cache = ImageCache.default
        cache.diskStorage.config.cachePathBlock = { (_, _) -> URL in
            return URL(fileURLWithPath: cachePath)
        }
        
        cache.diskStorage.config.sizeLimit = 50 * 1024 * 1024 // 50MB limit
        cache.diskStorage.config.expiration = .days(7)
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        sendCfgToAppGroup()
        refreshAppIntents()
        WidgetCenter.shared.reloadAllTimelines()
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        emitPendingDeepLinkIfNeeded()
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        sendCfgToAppGroup()
        refreshAppIntents()
    }
}

final class WatchConnectivityService: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityService()
    private let session: WCSession = .default

    private override init() {
        super.init()
        print("[iOS] Activating WCSession...")
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("[iOS] WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("[iOS] WCSession activated with state: \(activationState.rawValue)")
            if activationState == .activated {
                sendDataToWatch()
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("[iOS] Received message: \(message)")
        if let request = message["request"] as? String, request == "data" {
            Task {
                let token = await UserDefaults.standard.getValidFlutterToken()
                let serverUrl = UserDefaults.standard.getServerUrl()

                var data: [String: Any] = ["serverUrl": serverUrl]
                if let token = token {
                    data["token"] = token
                }

                print("[iOS] Replying with data: \(data)")
                replyHandler(data)
            }
        }
    }

    func sendDataToWatch() {
        guard session.activationState == .activated else {
            return
        }

        Task {
            let token = await UserDefaults.standard.getValidFlutterToken()
            let serverUrl = UserDefaults.standard.getServerUrl()

            var data: [String: Any] = ["serverUrl": serverUrl]
            if let token = token {
                data["token"] = token
            }

            do {
                try session.updateApplicationContext(data)
                print("[iOS] Sent application context: \(data)")
            } catch {
                print("[iOS] Failed to send application context: \(error.localizedDescription)")
            }
        }
    }
}
