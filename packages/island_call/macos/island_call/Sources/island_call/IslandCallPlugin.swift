import Cocoa
import FlutterMacOS

public class IslandCallPlugin: NSObject, FlutterPlugin {
    fileprivate let manager = CallManager()
    fileprivate var stateSink: FlutterEventSink?
    fileprivate var participantsSink: FlutterEventSink?
    fileprivate var windowController: CallWindowController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "island_call", binaryMessenger: registrar.messenger)
        let stateChannel = FlutterEventChannel(name: "island_call/state", binaryMessenger: registrar.messenger)
        let participantsChannel = FlutterEventChannel(name: "island_call/participants", binaryMessenger: registrar.messenger)

        let instance = IslandCallPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        stateChannel.setStreamHandler(StateStreamHandler(plugin: instance))
        participantsChannel.setStreamHandler(ParticipantsStreamHandler(plugin: instance))

        // Wire up callbacks
        instance.manager.onStateChanged = { dict in
            DispatchQueue.main.async { instance.stateSink?(dict) }
        }
        instance.manager.onParticipantsChanged = { arr in
            DispatchQueue.main.async { instance.participantsSink?(arr) }
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
                    self.showCallWindow()
                    result(nil)
                } catch {
                    result(FlutterError(code: "JOIN_FAILED", message: error.localizedDescription, details: nil))
                }
            }

        case "leaveRoom":
            Task { @MainActor in
                await manager.leaveRoom()
                self.windowController?.closeWindow()
                self.windowController = nil
                result(nil)
            }

        case "toggleMic":
            Task { @MainActor in await manager.toggleMic(); result(nil) }

        case "toggleCamera":
            Task { @MainActor in await manager.toggleCamera(); result(nil) }

        case "toggleSpeaker":
            Task { @MainActor in await manager.toggleSpeaker(); result(nil) }

        case "toggleViewMode":
            Task { @MainActor in manager.toggleViewMode(); result(nil) }

        case "showExpandedView":
            Task { @MainActor in self.showCallWindow(); result(nil) }

        case "dismissExpandedView":
            Task { @MainActor in
                self.windowController?.closeWindow()
                self.windowController = nil
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    fileprivate func showCallWindow() {
        if windowController == nil {
            windowController = CallWindowController(manager: manager)
        }
        windowController?.showWindow()
    }
}

// MARK: - Stream handlers

private final class StateStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: IslandCallPlugin?
    init(plugin: IslandCallPlugin) { self.plugin = plugin }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.stateSink = events
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
