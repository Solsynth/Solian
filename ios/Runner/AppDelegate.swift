import Flutter
import WidgetKit
import UIKit
import WatchConnectivity
import AppIntents
import flutter_sharing_intent

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    let notifyDelegate = NotifyDelegate()
    private static var sharedWatchConnectivityService: WatchConnectivityService?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        sendCfgToAppGroup()
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

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        setupWidgetSyncChannel(engineBridge: engineBridge)
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

        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "sendCfgToAppGroup" {
                sendCfgToAppGroup()
                WidgetCenter.shared.reloadAllTimelines()
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        sendCfgToAppGroup()
        WidgetCenter.shared.reloadAllTimelines()
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        sendCfgToAppGroup()
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
