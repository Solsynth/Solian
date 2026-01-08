import Flutter
import WidgetKit
import UIKit
import WatchConnectivity
import AppIntents
import flutter_app_intents

@main
@objc class AppDelegate: FlutterAppDelegate {
    let notifyDelegate = NotifyDelegate()
    private static var sharedWatchConnectivityService: WatchConnectivityService?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        syncDefaultsToGroup()
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
        
        GeneratedPluginRegistrant.register(with: self)
        
        // Setup widget sync method channel
        setupWidgetSyncChannel()
        
        // Always initialize and retain a strong reference
        if WCSession.isSupported() {
            AppDelegate.sharedWatchConnectivityService = WatchConnectivityService.shared
        } else {
            print("[iOS] WCSession not supported on this device.")
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupWidgetSyncChannel() {
        let controller = window?.rootViewController as? FlutterViewController
        let channel = FlutterMethodChannel(name: "dev.solsynth.solian/widget", binaryMessenger: controller!.binaryMessenger)
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "syncToWidget" {
                syncDefaultsToGroup()
                WidgetCenter.shared.reloadAllTimelines()
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        syncDefaultsToGroup()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        syncDefaultsToGroup()
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

    // MARK: - WCSessionDelegate

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
            let token = UserDefaults.standard.getFlutterToken()
            let serverUrl = UserDefaults.standard.getServerUrl()
            
            var data: [String: Any] = ["serverUrl": serverUrl]
            if let token = token {
                data["token"] = token
            }
            
            print("[iOS] Replying with data: \(data)")
            replyHandler(data)
        }
    }

    func sendDataToWatch() {
        guard session.activationState == .activated else {
            return
        }
        
        let token = UserDefaults.standard.getFlutterToken()
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

// MARK: - App Intents

@available(iOS 16.0, *)
struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Chat"
    static var description = IntentDescription("Open a specific chat room")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "Channel ID")
    var channelId: String?

    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_chat",
            parameters: ["channelId": channelId ?? ""]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Chat opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to open chat"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

@available(iOS 16.0, *)
struct OpenPostIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Post"
    static var description = IntentDescription("Open a specific post")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "Post ID")
    var postId: String?

    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_post",
            parameters: ["postId": postId ?? ""]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Post opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to open post"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

@available(iOS 16.0, *)
struct OpenComposeIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Compose"
    static var description = IntentDescription("Open compose post screen")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_compose",
            parameters: [:]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Compose screen opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to open compose"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

@available(iOS 16.0, *)
struct ComposePostIntent: AppIntent {
    static var title: LocalizedStringResource = "Compose Post"
    static var description = IntentDescription("Create a new post")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "compose_post",
            parameters: [:]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Compose screen opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to compose post"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

@available(iOS 16.0, *)
struct SearchContentIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Content"
    static var description = IntentDescription("Search for content")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    @Parameter(title: "Search Query")
    var query: String?

    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "search_content",
            parameters: ["query": query ?? ""]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Search opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to search"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

@available(iOS 16.0, *)
struct ViewNotificationsIntent: AppIntent {
    static var title: LocalizedStringResource = "View Notifications"
    static var description = IntentDescription("View notifications")
    static var isDiscoverable = true
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "view_notifications",
            parameters: [:]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Notifications opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to view notifications"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

@available(iOS 16.0, *)
struct CheckNotificationsIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Notifications"
    static var description = IntentDescription("Check notification count")
    static var isDiscoverable = true
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "check_notifications",
            parameters: [:]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "You have new notifications"
            return .result(
                value: value,
                dialog: "Dialog: \(value)"
            )
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to check notifications"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

enum AppIntentError: Error {
    case executionFailed(String)
}

@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            // Open chat
            AppShortcut(
                intent: OpenChatIntent(),
                phrases: [
                    "Open chat with \(.applicationName)",
                    "Go to chat using \(.applicationName)",
                    "Show chat in \(.applicationName)"
                ]
            ),
            // Open post
            AppShortcut(
                intent: OpenPostIntent(),
                phrases: [
                    "Open post with \(.applicationName)",
                    "Show post using \(.applicationName)"
                ]
            ),
            // Compose
            AppShortcut(
                intent: OpenComposeIntent(),
                phrases: [
                    "Open compose with \(.applicationName)",
                    "New post using \(.applicationName)",
                    "Write post in \(.applicationName)"
                ]
            ),
            // Search
            AppShortcut(
                intent: SearchContentIntent(),
                phrases: [
                    "Search in \(.applicationName)",
                    "Find content using \(.applicationName)"
                ]
            ),
            // Check notifications
            AppShortcut(
                intent: CheckNotificationsIntent(),
                phrases: [
                    "Check notifications with \(.applicationName)",
                    "Get notifications using \(.applicationName)",
                    "Do I have notifications in \(.applicationName)"
                ]
            )
        ]
    }
}
