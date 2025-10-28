import Flutter
import UIKit
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate {
    let notifyDelegate = NotifyDelegate()
    private var watchConnectivityService: WatchConnectivityService?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
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
        
        GeneratedPluginRegistrant.register(with: self)
        
        if WCSession.isSupported() {
            watchConnectivityService = WatchConnectivityService()
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

class WatchConnectivityService: NSObject, WCSessionDelegate {
    private let session: WCSession

    override init() {
        self.session = .default
        super.init()
        print("[iOS] Activating WCSession")
        self.session.delegate = self
        self.session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("[iOS] WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("[iOS] WCSession activated with state: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("[iOS] Received message: \(message)")
        if let request = message["request"] as? String, request == "data" {
            let token = UserDefaults.standard.getFlutterToken()
            let serverUrl = UserDefaults.standard.getServerUrl()
            
            print("[iOS] Retrieved token: \(token ?? "nil")")
            print("[iOS] Retrieved serverUrl: \(serverUrl)")
            
            var data: [String: Any] = ["serverUrl": serverUrl]
            if let token = token {
                data["token"] = token
            }
            
            print("[iOS] Replying with data: \(data)")
            replyHandler(data)
        }
    }
}
