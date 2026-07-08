import Flutter
import WidgetKit
import UIKit
import WatchConnectivity
import AppIntents
import Intents
import PushKit
import AVFAudio
import CallKit
import flutter_sharing_intent
import Kingfisher
import flutter_webrtc
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, PKPushRegistryDelegate, CallkitIncomingAppDelegate {
    let notifyDelegate = NotifyDelegate()
    private static var sharedWatchConnectivityService: WatchConnectivityService?
    private let deepLinkChannelName = "dev.solsynth.solian/deeplink"
    private let nativeCallChannelName = "dev.solsynth.solian/native_call"
    private let pendingAcceptedCallKey = "dev.solsynth.solian.callkit.pendingAcceptedCall"
    private let pendingCallbackCallKey = "dev.solsynth.solian.callkit.pendingCallbackCall"
    private let shareSuggestionsChannelName = "dev.solsynth.solian/share_suggestions"
    private var implicitDeepLinkChannel: FlutterMethodChannel?
    private var nativeCallChannel: FlutterMethodChannel?
    private var callKitAudioSessionActive = false
    
    static var shared: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
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
        
        if let controller = window?.rootViewController as? FlutterViewController {
            setupNativeCallChannel(binaryMessenger: controller.binaryMessenger)
        }

        UNUserNotificationCenter.current().delegate = self
        
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
        
        // Setup VoIP
        let mainQueue = DispatchQueue.main
        let voipRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        print("[CallKit] AppDelegate PushKit registry active desired=\(String(describing: voipRegistry.desiredPushTypes))")
        // VoIP + WebRTC
        RTCAudioSession.sharedInstance().useManualAudio = true
        RTCAudioSession.sharedInstance().isAudioEnabled = false
        // Missed call notification
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
//        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - PushKit
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let token = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("[CallKit] didUpdatePushCredentials type=\(type.rawValue) tokenPrefix=\(String(token.prefix(8)))… appState=\(UIApplication.shared.applicationState.rawValue) isProtectedDataAvailable=\(UIApplication.shared.isProtectedDataAvailable)")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("[CallKit] didInvalidatePushTokenFor type=\(type.rawValue) appState=\(UIApplication.shared.applicationState.rawValue)")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    
    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion: @escaping () -> Void
    ) {
        print("[CallKit] didReceiveIncomingPushWith type=\(type.rawValue) appState=\(UIApplication.shared.applicationState.rawValue) isProtectedDataAvailable=\(UIApplication.shared.isProtectedDataAvailable) registryDelegateSet=\(registry.delegate != nil) registryDesiredTypes=\(registry.desiredPushTypes?.description ?? "nil") pluginInstance=\(SwiftFlutterCallkitIncomingPlugin.sharedInstance != nil ? "alive" : "nil")")
        print("[CallKit] payload.allKeys=\(Array(payload.dictionaryPayload.keys).map { String(describing: $0) }.sorted()) payload=\(payload.dictionaryPayload)")
        
        guard type == .voIP else {
            print("[CallKit] not a VoIP push — calling completion() without reporting")
            completion()
            return
        }
        let voipDict = payload.dictionaryPayload.reduce(into: [String: Any]()) { r, e in
            r[String(describing: e.key)] = e.value
        }
        reportIncomingPush(dict: voipDict, completion: completion)
    }
    
    private func reportIncomingPush(dict: [String: Any], completion: @escaping () -> Void) {
        let id = (dict["uuid"] as? String) ?? UUID().uuidString.lowercased()
        let nameCaller = (dict["caller_name"] as? String) ?? ""
        let handle = (dict["caller_id"] as? String) ?? ""
        let isVideo = (dict["has_video"] as? Bool) ?? false
        
        var extra: [String: Any] = [:]
        if let roomId = dict["room_id"] as? String { extra["room_id"] = roomId }
        if let callerId = dict["caller_id"] as? String { extra["caller_id"] = callerId }
        if let pfp = dict["pfp"] as? String { extra["pfp"] = pfp }
        
        let reportData = Data(
            id: id,
            nameCaller: nameCaller,
            handle: handle,
            type: isVideo ? 1 : 0
        )
        reportData.ringtonePath = "SfxCall.wav"
        // explicit asset name; prevents plugin from falling back to "CallKitLogo" and logging Unable to load icon
        reportData.iconName = "CallKitLogo"
        reportData.extra = extra as NSDictionary
        // Critical: don't let this plugin configure AVAudioSession — LiveKit owns it.
        // Setting false prevents flutter_callkit_incoming from calling setCategory/setMode/setActive,
        // which would otherwise fight with audio_session → RTCAudioSession.
        reportData.configureAudioSession = false
        configureCallAudioSession("incoming push before report")
        
        print("[CallKit] reporting to showCallkitIncoming id=\(id) caller=\(nameCaller) handle=\(handle) isVideo=\(isVideo) fromPushKit=true")
        guard let plugin = SwiftFlutterCallkitIncomingPlugin.sharedInstance else {
            print("[CallKit] WARNING: plugin instance nil — cannot report")
            completion()
            return
        }
        plugin.showCallkitIncoming(reportData, fromPushKit: true) {
            print("[CallKit] showCallkitIncoming completion fired")
            completion()
        }
    }
    
    
    // MARK: - Notifications

    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        CallkitNotificationManager.shared.userNotificationCenter(
            center,
            willPresent: notification,
            withCompletionHandler: completionHandler
        )
    }

    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == CallkitNotificationManager.CALLBACK_ACTION {
            let data = response.notification.request.content.userInfo as? [String: Any]
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.sendCallbackEvent(data)
            storeCallbackCall(data)
            completionHandler()
            return
        }

        notifyDelegate.userNotificationCenter(
            center,
            didReceive: response,
            withCompletionHandler: completionHandler
        )
    }

    // MARK: - CallkitIncomingAppDelegate
    
    func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
        print("[CallKit] onAccept: \(call.uuid)")
        storeAcceptedCall(call)
        action.fulfill()
    }
    
    func onDecline(_ call: Call, _ action: CXEndCallAction) {
        print("[CallKit] onDecline: \(call.uuid)")
        callKitAudioSessionActive = false
        nativeCallChannel?.invokeMethod("onEndedCall", arguments: call.uuid.uuidString.lowercased())
        action.fulfill()
    }
    
    func onEnd(_ call: Call, _ action: CXEndCallAction) {
        print("[CallKit] onEnd: \(call.uuid)")
        callKitAudioSessionActive = false
        nativeCallChannel?.invokeMethod("onEndedCall", arguments: call.uuid.uuidString.lowercased())
        action.fulfill()
    }
    
    func onTimeOut(_ call: Call) {
        print("[CallKit] onTimeOut: \(call.uuid)")
        // no-op: plugin already emits timeout event to Dart
    }
    
    private func configureCallAudioSession(_ reason: String) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .defaultToSpeaker]
            )
            print("[CallKit] configured AVAudioSession reason=\(reason)")
        } catch {
            print("[CallKit] failed to configure AVAudioSession reason=\(reason) error=\(error.localizedDescription)")
        }
    }

    private func prepareOutgoingCallAudioSession() {
        // CallKit activates the session after the CXStartCallAction is fulfilled.
        // The category must already support recording at that point; otherwise an
        // in-app call starts from the app's ambient session and WebRTC's manual
        // audio unit remains silent even after CallKit becomes active.
        configureCallAudioSession("outgoing call before report")
        let rtcSession = RTCAudioSession.sharedInstance()
        rtcSession.useManualAudio = true
        rtcSession.isAudioEnabled = false
    }

    private func prepareInAppLiveKitAudioSession() {
        // In-app joins do not need a CallKit transaction. Release WebRTC from
        // CallKit/manual-audio mode and let LiveKit/flutter_webrtc configure the
        // AVAudioSession as part of the room connection.
        callKitAudioSessionActive = false
        let rtcSession = RTCAudioSession.sharedInstance()
        rtcSession.useManualAudio = false
        rtcSession.isAudioEnabled = true
        print("[CallKit] prepared in-app LiveKit audio session ownership")
    }

    func didActivateAudioSession(_ audioSession: AVAudioSession) {
        print("[CallKit] didActivateAudioSession")
        configureCallAudioSession("didActivate")
        callKitAudioSessionActive = true
        let rtcSession = RTCAudioSession.sharedInstance()
        rtcSession.useManualAudio = true
        rtcSession.audioSessionDidActivate(audioSession)
        rtcSession.isAudioEnabled = true
        nativeCallChannel?.invokeMethod("onAudioSessionActive", arguments: true)
    }
    
    func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
        print("[CallKit] didDeactivateAudioSession")
        callKitAudioSessionActive = false
        RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
        RTCAudioSession.sharedInstance().isAudioEnabled = false
        nativeCallChannel?.invokeMethod("onAudioSessionActive", arguments: false)
    }
    
    func providerDidReset() {
        print("[CallKit] providerDidReset")
        callKitAudioSessionActive = false
    }

    private func setupNativeCallChannel(binaryMessenger: FlutterBinaryMessenger) {
        nativeCallChannel = FlutterMethodChannel(
            name: nativeCallChannelName,
            binaryMessenger: binaryMessenger
        )
        nativeCallChannel?.setMethodCallHandler { call, result in
            switch call.method {
            case "consumePendingAcceptedCall":
                result(self.consumePendingAcceptedCall())
            case "consumePendingCallbackCall":
                result(self.consumePendingCallbackCall())
            case "isCallKitAudioSessionActive":
                result(self.callKitAudioSessionActive)
            case "prepareOutgoingCallAudioSession":
                self.prepareOutgoingCallAudioSession()
                result(nil)
            case "prepareInAppLiveKitAudioSession":
                self.prepareInAppLiveKitAudioSession()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func storeAcceptedCall(_ call: Call) {
        let extra = call.data.extra as? [String: Any] ?? [:]
        var payload: [String: Any] = [
            "id": call.uuid.uuidString.lowercased(),
            "nameCaller": call.data.nameCaller,
            "handle": call.data.handle,
            "type": call.data.type,
            "extra": extra,
        ]
        if let roomId = extra["room_id"] {
            payload["room_id"] = roomId
        }
        UserDefaults.shared.set(payload, forKey: pendingAcceptedCallKey)
        UserDefaults.shared.synchronize()
        nativeCallChannel?.invokeMethod("onAcceptedCall", arguments: payload)
    }

    private func consumePendingAcceptedCall() -> [String: Any]? {
        let defaults = UserDefaults.shared
        defer {
            defaults.removeObject(forKey: pendingAcceptedCallKey)
            defaults.synchronize()
        }
        return defaults.dictionary(forKey: pendingAcceptedCallKey)
    }

    private func storeCallbackCall(_ rawPayload: [String: Any]?) {
        guard let rawPayload else { return }
        var payload = rawPayload
        if payload["room_id"] == nil,
           let extra = payload["extra"] as? [String: Any],
           let roomId = extra["room_id"] {
            payload["room_id"] = roomId
        }
        if payload["id"] == nil {
            payload["id"] = UUID().uuidString.lowercased()
        }
        UserDefaults.shared.set(payload, forKey: pendingCallbackCallKey)
        UserDefaults.shared.synchronize()
        nativeCallChannel?.invokeMethod("onCallbackCall", arguments: payload)
    }

    private func consumePendingCallbackCall() -> [String: Any]? {
        let defaults = UserDefaults.shared
        defer {
            defaults.removeObject(forKey: pendingCallbackCallKey)
            defaults.synchronize()
        }
        return defaults.dictionary(forKey: pendingCallbackCallKey)
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        setupWidgetSyncChannel(engineBridge: engineBridge)
        implicitDeepLinkChannel = makeDeepLinkChannel(
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )
        emitPendingDeepLinkIfNeeded()
    }
    
    // MARK: Deep linking & Sharing
    
    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let handleObj = userActivity.handle,
           let isVideo = userActivity.isVideo {
            let objData = handleObj.getDecryptHandle()
            let nameCaller = objData["nameCaller"] as? String ?? ""
            let handle = objData["handle"] as? String ?? ""
            let roomId = handle
            let data = flutter_callkit_incoming.Data(
                id: UUID().uuidString.lowercased(),
                nameCaller: nameCaller,
                handle: handle,
                type: isVideo ? 1 : 0
            )
            data.extra = ["room_id": roomId]
            data.configureAudioSession = false
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.startCall(data, fromPushKit: true)
            storeCallbackCall([
                "id": data.uuid,
                "nameCaller": nameCaller,
                "handle": handle,
                "room_id": roomId,
                "extra": ["room_id": roomId],
                "type": isVideo ? 1 : 0,
            ])
        }

        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
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
    
    // MARK: Widgets
    
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
    
    // MARK: Share extension related code
    
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
    
    // MARK: Kingfisher the image library config
    
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

// MARK: WatchOS app related logic

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
