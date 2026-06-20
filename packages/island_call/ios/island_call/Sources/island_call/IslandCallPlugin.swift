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
    // Live Activity
    private var callActivity: Any? = nil

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "island_call", binaryMessenger: registrar.messenger())
        let instance = IslandCallPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
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
