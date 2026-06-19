import Flutter
import UIKit
import ActivityKit

// Live Activity attributes - must match widget extension definition
struct CallActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var roomName: String
        var participantCount: Int
        var isMuted: Bool
        var elapsedSeconds: Int
    }
    
    var roomId: String
    var callerName: String
}

public class IslandCallPlugin: NSObject, FlutterPlugin {
    fileprivate let manager = CallManager()
    fileprivate var stateSink: FlutterEventSink?
    fileprivate var participantsSink: FlutterEventSink?

    // UI
    fileprivate var callWindow: UIWindow?
    
    // Live Activity
    fileprivate var callActivity: Any? = nil

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "island_call", binaryMessenger: registrar.messenger())
        let stateChannel = FlutterEventChannel(name: "island_call/state", binaryMessenger: registrar.messenger())
        let participantsChannel = FlutterEventChannel(name: "island_call/participants", binaryMessenger: registrar.messenger())

        let instance = IslandCallPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        stateChannel.setStreamHandler(StateStreamHandler(plugin: instance))
        participantsChannel.setStreamHandler(ParticipantsStreamHandler(plugin: instance))

        // Wire up callbacks
        instance.manager.onStateChanged = { dict in
            DispatchQueue.main.async {
                instance.stateSink?(dict)
            }
        }
        instance.manager.onParticipantsChanged = { arr in
            DispatchQueue.main.async {
                instance.participantsSink?(arr)
            }
        }
        instance.manager.onCallKitCallConnected = { [weak instance] in
            instance?.showCallUI()
        }
        instance.manager.onCallKitCallEnded = { [weak instance] in
            instance?.dismissCallUI()
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let serverUrl = args["serverUrl"] as? String,
                  let authToken = args["authToken"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "serverUrl and authToken required", details: nil))
                return
            }
            manager.initialize(serverUrl: serverUrl, authToken: authToken)
            result(nil)

        case "joinRoom":
            guard let args = call.arguments as? [String: Any],
                  let roomId = args["roomId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "roomId required", details: nil))
                return
            }
            Task { @MainActor in
                do {
                    try await manager.joinRoom(roomId)
                    self.showCallUI()
                    result(nil)
                } catch {
                    result(FlutterError(code: "JOIN_FAILED", message: error.localizedDescription, details: nil))
                }
            }

        case "leaveRoom":
            Task { @MainActor in
                await manager.leaveRoom()
                self.dismissCallUI()
                result(nil)
            }

        case "toggleMic":
            Task { @MainActor in
                await manager.toggleMic()
                result(nil)
            }

        case "toggleCamera":
            Task { @MainActor in
                await manager.toggleCamera()
                result(nil)
            }

        case "toggleSpeaker":
            Task { @MainActor in
                await manager.toggleSpeaker()
                result(nil)
            }

        case "toggleViewMode":
            Task { @MainActor in
                manager.toggleViewMode()
                result(nil)
            }

        case "showExpandedView":
            Task { @MainActor in
                self.showExpandedView()
                result(nil)
            }

        case "dismissExpandedView":
            Task { @MainActor in
                self.dismissExpandedView()
                result(nil)
            }

        case "startCall":
            guard let args = call.arguments as? [String: Any],
                  let handle = args["handle"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "handle required", details: nil))
                return
            }
            Task { @MainActor in
                await manager.startCall(handle: handle)
                result(nil)
            }

        case "endCall":
            Task { @MainActor in
                await manager.endCall()
                result(nil)
            }

        case "reportIncomingCall":
            guard let args = call.arguments as? [String: Any],
                  let callerId = args["callerId"] as? String,
                  let callerName = args["callerName"] as? String,
                  let roomId = args["roomId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "callerId, callerName, and roomId required", details: nil))
                return
            }
            manager.reportIncomingCall(from: callerId, callerName: callerName, roomId: roomId)
            result(nil)

        case "simulateIncomingCall":
            let args = call.arguments as? [String: Any]
            let callerName = args?["callerName"] as? String ?? "Test User"
            let roomId = args?["roomId"] as? String ?? "test-room"
            manager.reportIncomingCall(from: "test", callerName: callerName, roomId: roomId)
            result(nil)

        case "getVoipToken":
            result(manager.voipToken)

        case "inviteToCall":
            guard let args = call.arguments as? [String: Any],
                  let roomId = args["roomId"] as? String,
                  let targetAccountId = args["targetAccountId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "roomId and targetAccountId required", details: nil))
                return
            }
            Task { @MainActor in
                do {
                    try await manager.inviteToCall(roomId: roomId, targetAccountId: targetAccountId)
                    result(nil)
                } catch {
                    result(FlutterError(code: "INVITE_FAILED", message: error.localizedDescription, details: nil))
                }
            }

        case "startCallActivity":
            guard let args = call.arguments as? [String: Any],
                  let roomId = args["roomId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "roomId required", details: nil))
                return
            }
            let roomName = args["roomName"] as? String ?? "Voice Call"
            let callerName = args["callerName"] as? String ?? "Solian"
            if #available(iOS 16.2, *) {
                Task { @MainActor in
                    self.startCallActivity(roomId: roomId, roomName: roomName, callerName: callerName)
                    result(nil)
                }
            } else {
                result(nil)
            }
            
        case "updateCallActivity":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "args required", details: nil))
                return
            }
            let isMuted = args["isMuted"] as? Bool ?? false
            let participantCount = args["participantCount"] as? Int ?? 1
            let elapsedSeconds = args["elapsedSeconds"] as? Int ?? 0
            if #available(iOS 16.2, *) {
                Task { @MainActor in
                    self.updateCallActivity(isMuted: isMuted, participantCount: participantCount, elapsedSeconds: elapsedSeconds)
                    result(nil)
                }
            } else {
                result(nil)
            }
            
        case "endCallActivity":
            if #available(iOS 16.2, *) {
                Task { @MainActor in
                    self.endCallActivity()
                    result(nil)
                }
            } else {
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - UI

    private func showCallUI() {
        // If expanded view not yet shown, show it
        if callWindow == nil {
            showExpandedView()
        }
    }

    func showExpandedView() {
        dismissCallUI()
        let vc = CallHostingController(manager: manager, onDismiss: { [weak self] in
            self?.dismissExpandedView()
            // Show floating widget instead
            self?.showFloatingWidget()
        })
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        if #available(iOS 16.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.detents = [.large()]
            }
        }

        // Present from topmost view controller
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else { return }

        // Find topmost presented VC
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        top.present(nav, animated: true)
    }

    private func showFloatingWidget() {
        guard callWindow == nil else { return }
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }

        let window = UIWindow(windowScene: scene)
        window.windowLevel = .statusBar + 1
        window.backgroundColor = .clear
        window.rootViewController = FloatingWidgetController(manager: manager, onTap: { [weak self] in
            self?.showExpandedView()
        })
        window.isHidden = false
        callWindow = window
    }

    func dismissExpandedView() {
        // Dismiss any presented sheet
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else { return }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        top.dismiss(animated: true)
    }

    private func dismissCallUI() {
        dismissExpandedView()
        callWindow?.isHidden = true
        callWindow = nil
    }
    
    // MARK: - Live Activity
    
    @available(iOS 16.2, *)
    private func startCallActivity(roomId: String, roomName: String, callerName: String) {
        endCallActivity()
        
        let attributes = CallActivityAttributes(roomId: roomId, callerName: callerName)
        let state = CallActivityAttributes.ContentState(
            roomName: roomName,
            participantCount: 1,
            isMuted: false,
            elapsedSeconds: 0
        )
        
        do {
            callActivity = try Activity<CallActivityAttributes>.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )
            print("[LiveActivity] Started for room: \(roomId)")
        } catch {
            print("[LiveActivity] Failed to start: \(error)")
        }
    }
    
    @available(iOS 16.2, *)
    private func updateCallActivity(isMuted: Bool, participantCount: Int, elapsedSeconds: Int) {
        guard let activity = callActivity as? Activity<CallActivityAttributes> else { return }
        
        let state = CallActivityAttributes.ContentState(
            roomName: activity.content.state.roomName,
            participantCount: participantCount,
            isMuted: isMuted,
            elapsedSeconds: elapsedSeconds
        )
        
        Task {
            await activity.update(using: state)
        }
    }
    
    @available(iOS 16.2, *)
    private func endCallActivity() {
        guard let activity = callActivity as? Activity<CallActivityAttributes> else { return }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            callActivity = nil
            print("[LiveActivity] Ended")
        }
    }
}

// MARK: - Stream handlers

private final class StateStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: IslandCallPlugin?
    init(plugin: IslandCallPlugin) { self.plugin = plugin }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.stateSink = events
        // Send current state immediately
        if let p = plugin { events(p.manager.state.asDict()) }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.stateSink = nil
        return nil
    }
}

private final class ParticipantsStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: IslandCallPlugin?
    init(plugin: IslandCallPlugin) { self.plugin = plugin }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.participantsSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.participantsSink = nil
        return nil
    }
}
