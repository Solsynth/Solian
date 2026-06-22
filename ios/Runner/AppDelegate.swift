import Flutter
import AVFAudio
import CallKit
import WidgetKit
import UIKit
import WatchConnectivity
import AppIntents
import Intents
import flutter_sharing_intent
import Kingfisher
import PushKit
import flutter_callkit_incoming
import WebRTC

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, PKPushRegistryDelegate, CallkitIncomingAppDelegate {
    let notifyDelegate = NotifyDelegate()
    private static var sharedWatchConnectivityService: WatchConnectivityService?
    private let pendingAcceptedCallKey = "dev.solsynth.solian.pendingAcceptedCall"
    private let callKitChannelName = "dev.solsynth.solian/callkit"
    private let shareSuggestionsChannelName = "dev.solsynth.solian/share_suggestions"
    private let callBridgeEngineName = "dev.solsynth.solian.callkit_bridge"
    private let pendingAnswerTimeout: TimeInterval = 15
    private var voipRegistry: PKPushRegistry?
    private var bridgeFlutterEngine: FlutterEngine?
    private var implicitCallKitChannel: FlutterMethodChannel?
    private var bridgeCallKitChannel: FlutterMethodChannel?
    private var pendingAnswerAction: CXAnswerCallAction?
    private var pendingAnswerTimeoutWorkItem: DispatchWorkItem?
    
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

        ensureCallBridgeEngine()
        
        // Setup VoIP PushKit
        let voipRegistry = PKPushRegistry(queue: .main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
        self.voipRegistry = voipRegistry

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func configureAudioSessionForCallKit() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP, .mixWithOthers]
            )
        } catch {
            print("[CallKit] Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }

    private func prepareWebRTCAudioForCallKitActivation() {
        configureAudioSessionForCallKit()
        let rtcSession = RTCAudioSession.sharedInstance()
        rtcSession.useManualAudio = true
        rtcSession.isAudioEnabled = false
    }

    private func enableWebRTCAudioForActiveCallKitSession(_ audioSession: AVAudioSession) {
        configureAudioSessionForCallKit()
        let rtcSession = RTCAudioSession.sharedInstance()
        rtcSession.useManualAudio = true
        rtcSession.audioSessionDidActivate(audioSession)
        rtcSession.isAudioEnabled = true
    }

    private func disableWebRTCAudioForCallKitSession(_ audioSession: AVAudioSession) {
        let rtcSession = RTCAudioSession.sharedInstance()
        rtcSession.isAudioEnabled = false
        rtcSession.audioSessionDidDeactivate(audioSession)
        rtcSession.useManualAudio = false
    }

    private func ensureCallBridgeEngine() {
        if bridgeFlutterEngine == nil {
            let engine = FlutterEngine(
                name: callBridgeEngineName,
                project: nil,
                allowHeadlessExecution: true
            )
            bridgeFlutterEngine = engine
            engine.run(withEntrypoint: "callkitBackgroundMain")
            GeneratedPluginRegistrant.register(with: engine)
            bridgeCallKitChannel = makeCallKitChannel(binaryMessenger: engine.binaryMessenger)
            print("[CallKit] Bridge Flutter engine started")
        } else if bridgeCallKitChannel == nil, let messenger = bridgeFlutterEngine?.binaryMessenger {
            bridgeCallKitChannel = makeCallKitChannel(binaryMessenger: messenger)
        }
    }

    private func makeCallKitChannel(binaryMessenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
        let channel = FlutterMethodChannel(
            name: callKitChannelName,
            binaryMessenger: binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(FlutterError(code: "APP_DELEGATE_DEALLOCATED", message: nil, details: nil))
                return
            }
            switch call.method {
            case "fulfillPendingAnswer":
                self.fulfillPendingAnswer()
                result(nil)
            case "getPendingAcceptedCall":
                result(self.loadPendingAcceptedCall())
            case "clearPendingAcceptedCall":
                self.clearPendingAcceptedCall()
                result(nil)
            case "endCall":
                self.failPendingAnswerIfNeeded(endNativeCall: false)
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endAllCalls()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        return channel
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        setupWidgetSyncChannel(engineBridge: engineBridge)
        
        implicitCallKitChannel = makeCallKitChannel(
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
         let sharingIntent = SwiftFlutterSharingIntentPlugin.instance
         /// if the url is made from SwiftFlutterSharingIntentPlugin then handle it with plugin [SwiftFlutterSharingIntentPlugin]
         if sharingIntent.hasSameSchemePrefix(url: url) {
             return sharingIntent.application(app, open: url, options: options)
         }

         // Proceed url handling for other Flutter libraries like uni_links
         return super.application(app, open: url, options:options)
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

    override func applicationWillTerminate(_ application: UIApplication) {
        sendCfgToAppGroup()
        refreshAppIntents()
    }
    
    // MARK: - PKPushRegistryDelegate
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else { return }
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("[PushKit] VoIP token updated: \(deviceToken)")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("[PushKit] VoIP token invalidated")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        guard type == .voIP else { completion(); return }
        print("[PushKit] VoIP push received: \(payload.dictionaryPayload)")
        ensureCallBridgeEngine()
        
        // Convert [AnyHashable: Any] to [String: Any]
        let payloadDict = payload.dictionaryPayload.reduce(into: [String: Any]()) { result, pair in
            if let key = pair.key as? String {
                result[key] = pair.value
            }
        }
        // Extract from nested 'meta' object if present
        let meta = payloadDict["meta"] as? [String: Any] ?? payloadDict
        
        let id = meta["room_id"] as? String ?? UUID().uuidString
        let nameCaller = meta["caller_name"] as? String ?? "Unknown"
        let callerId = meta["caller_id"] as? String ?? ""
        let handle = callerId.isEmpty ? "" : "@\(callerId)"
        
        let data = flutter_callkit_incoming.Data(
            id: id,
            nameCaller: nameCaller,
            handle: handle,
            type: 0
        )
        data.handleType = "generic"
        data.extra = meta as NSDictionary
        data.configureAudioSession = false

        prepareWebRTCAudioForCallKitActivation()
        
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true) {
            completion()
        }
    }
    
    // MARK: - CallkitIncomingAppDelegate

    func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
        let roomId = call.data.uuid
        print("[CallKit] Call accepted: \(roomId)")

        prepareWebRTCAudioForCallKitActivation()
        pendingAnswerAction = action
        persistPendingAcceptedCall([
            "roomId": roomId,
            "callerName": call.data.nameCaller ?? "Unknown",
            "callerId": call.data.handle ?? ""
        ])
        schedulePendingAnswerTimeout(for: action)

        let payload = loadPendingAcceptedCall()
        implicitCallKitChannel?.invokeMethod("callAccepted", arguments: payload)
        bridgeCallKitChannel?.invokeMethod("callAccepted", arguments: payload)
    }
    
    /// Called by Flutter when the call is connected
    func fulfillPendingAnswer() {
        guard let action = pendingAnswerAction else { return }
        print("[CallKit] Fulfilling pending answer action")
        cancelPendingAnswerTimeout()
        action.fulfill()
        pendingAnswerAction = nil
        clearPendingAcceptedCall()
    }
    
    func onDecline(_ call: Call, _ action: CXEndCallAction) {
        failPendingAnswerIfNeeded(endNativeCall: false)
        print("[CallKit] Call declined: \(call.data.uuid)")
        action.fulfill()
    }
    
    func onEnd(_ call: Call, _ action: CXEndCallAction) {
        failPendingAnswerIfNeeded(endNativeCall: false)
        print("[CallKit] Call ended: \(call.data.uuid)")
        action.fulfill()
    }
    
    func onTimeOut(_ call: Call) {
        failPendingAnswerIfNeeded(endNativeCall: false)
        print("[CallKit] Call timed out: \(call.data.uuid)")
    }
    
    func didActivateAudioSession(_ audioSession: AVAudioSession) {
        print("[CallKit] Audio session activated")
        enableWebRTCAudioForActiveCallKitSession(audioSession)
    }
    
    func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
        print("[CallKit] Audio session deactivated")
        disableWebRTCAudioForCallKitSession(audioSession)
    }
    
    func providerDidReset() {
        failPendingAnswerIfNeeded(endNativeCall: false)
        print("[CallKit] Provider did reset")
    }

    private func schedulePendingAnswerTimeout(for action: CXAnswerCallAction) {
        cancelPendingAnswerTimeout()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, self.pendingAnswerAction?.callUUID == action.callUUID else {
                return
            }
            print("[CallKit] Pending answer timed out for call: \(action.callUUID.uuidString)")
            self.failPendingAnswerIfNeeded(endNativeCall: true)
        }
        pendingAnswerTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + pendingAnswerTimeout, execute: workItem)
    }

    private func cancelPendingAnswerTimeout() {
        pendingAnswerTimeoutWorkItem?.cancel()
        pendingAnswerTimeoutWorkItem = nil
    }

    private func failPendingAnswerIfNeeded(endNativeCall: Bool) {
        cancelPendingAnswerTimeout()
        if let action = pendingAnswerAction {
            action.fail()
            pendingAnswerAction = nil
        }
        clearPendingAcceptedCall()
        if endNativeCall {
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endAllCalls()
        }
    }

    private func persistPendingAcceptedCall(_ payload: [String: Any]) {
        UserDefaults.standard.set(payload, forKey: pendingAcceptedCallKey)
    }

    private func loadPendingAcceptedCall() -> [String: Any]? {
        UserDefaults.standard.dictionary(forKey: pendingAcceptedCallKey)
    }

    private func clearPendingAcceptedCall() {
        UserDefaults.standard.removeObject(forKey: pendingAcceptedCallKey)
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
