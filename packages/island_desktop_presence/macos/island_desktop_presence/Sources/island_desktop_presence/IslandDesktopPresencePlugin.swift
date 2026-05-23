import ApplicationServices
import Cocoa
import FlutterMacOS

public class IslandDesktopPresencePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private enum State: String {
    case active
    case idle
  }

  private var eventSink: FlutterEventSink?
  private var timer: Timer?
  private var idleThresholdMilliseconds = 300_000
  private var lastEmittedState: State?
  private var pendingEvent: [String: Any]?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: "island_desktop_presence",
      binaryMessenger: registrar.messenger
    )
    let eventChannel = FlutterEventChannel(
      name: "island_desktop_presence/events",
      binaryMessenger: registrar.messenger
    )

    let instance = IslandDesktopPresencePlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getIdleTime":
      result(currentIdleMilliseconds())
    case "startMonitoring":
      guard
        let arguments = call.arguments as? [String: Any],
        let thresholdMilliseconds = arguments["idleThresholdMilliseconds"] as? Int,
        thresholdMilliseconds >= 0
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "idleThresholdMilliseconds must be a non-negative integer.",
            details: nil
          )
        )
        return
      }

      idleThresholdMilliseconds = thresholdMilliseconds
      startTimer()
      emitCurrentState(force: true)
      result(nil)
    case "stopMonitoring":
      stopTimer()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    eventSink = events
    if let pendingEvent {
      events(pendingEvent)
      self.pendingEvent = nil
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  private func startTimer() {
    stopTimer(resetState: false)

    timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
      self?.emitCurrentState(force: false)
    }
    RunLoop.main.add(timer!, forMode: .common)
  }

  private func stopTimer(resetState: Bool = true) {
    timer?.invalidate()
    timer = nil
    if resetState {
      lastEmittedState = nil
      pendingEvent = nil
    }
  }

  private func emitCurrentState(force: Bool) {
    let idleMilliseconds = currentIdleMilliseconds()
    let state: State = idleMilliseconds >= idleThresholdMilliseconds ? .idle : .active

    if !force, lastEmittedState == state {
      return
    }

    lastEmittedState = state
    let event: [String: Any] = [
      "state": state.rawValue,
      "idle_seconds": idleMilliseconds / 1000,
    ]

    if let eventSink {
      eventSink(event)
    } else {
      pendingEvent = event
    }
  }

  private func currentIdleMilliseconds() -> Int {
    let seconds = CGEventSource.secondsSinceLastEventType(
      .combinedSessionState,
      eventType: .null
    )
    return max(0, Int((seconds * 1000.0).rounded()))
  }
}
