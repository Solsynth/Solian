import ApplicationServices
import Cocoa
import CryptoKit
import Darwin
import FlutterMacOS


private let defaultNowPlayingCliPath = "/opt/homebrew/bin/nowplaying-cli"
private let rpcSocketBasePath = "/tmp/discord-ipc-"

private func normalizeNonEmptyString(_ value: String?) -> String? {
  guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) else {
    return nil
  }
  return trimmed.isEmpty ? nil : trimmed
}

private struct ExternalNowPlayingSnapshot: Equatable {
  enum Source: String {
    case music
    case other
  }

  enum State: String {
    case playing
    case paused
    case stopped
  }

  let source: Source
  let state: State
  let providerKey: String?
  let providerReferenceID: String?
  let sourceAppName: String?
  let sourceBundleIdentifier: String?
  let uniqueIdentifier: String?
  let title: String?
  let artist: String?
  let album: String?
  let playbackRate: Double?
  let durationSeconds: Double?
  let positionSeconds: Double?
  let titleURL: String?
  let subtitleURL: String?
  let artworkURL: String?
  let artworkURLLarge: String?
  let artworkHash: String?
  let artworkData: String?
  let catalogID: String?

  static func == (lhs: ExternalNowPlayingSnapshot, rhs: ExternalNowPlayingSnapshot) -> Bool {
      lhs.source == rhs.source &&
      lhs.state == rhs.state &&
      lhs.providerKey == rhs.providerKey &&
      lhs.providerReferenceID == rhs.providerReferenceID &&
      lhs.sourceAppName == rhs.sourceAppName &&
      lhs.sourceBundleIdentifier == rhs.sourceBundleIdentifier &&
      lhs.uniqueIdentifier == rhs.uniqueIdentifier &&
      lhs.title == rhs.title &&
      lhs.artist == rhs.artist &&
      lhs.album == rhs.album &&
      lhs.playbackRate == rhs.playbackRate &&
      lhs.durationSeconds == rhs.durationSeconds &&
      lhs.positionSeconds == rhs.positionSeconds &&
      lhs.titleURL == rhs.titleURL &&
      lhs.subtitleURL == rhs.subtitleURL &&
      lhs.artworkURL == rhs.artworkURL &&
      lhs.artworkURLLarge == rhs.artworkURLLarge &&
      lhs.catalogID == rhs.catalogID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(source)
    hasher.combine(state)
    hasher.combine(providerKey)
    hasher.combine(providerReferenceID)
    hasher.combine(sourceAppName)
    hasher.combine(sourceBundleIdentifier)
    hasher.combine(uniqueIdentifier)
    hasher.combine(title)
    hasher.combine(artist)
    hasher.combine(album)
    hasher.combine(playbackRate)
    hasher.combine(durationSeconds)
    hasher.combine(positionSeconds)
    hasher.combine(titleURL)
    hasher.combine(subtitleURL)
    hasher.combine(artworkURL)
    hasher.combine(artworkURLLarge)
    hasher.combine(catalogID)
  }

  var payload: [String: Any] {
    var result: [String: Any] = [
      "source": source.rawValue,
      "state": state.rawValue,
    ]
    if let providerKey {
      result["provider_key"] = providerKey
    }
    if let providerReferenceID {
      result["provider_reference_id"] = providerReferenceID
    }
    if let sourceAppName {
      result["source_app_name"] = sourceAppName
    }
    if let sourceBundleIdentifier {
      result["source_bundle_identifier"] = sourceBundleIdentifier
    }
    if let uniqueIdentifier {
      result["unique_identifier"] = uniqueIdentifier
    }
    if let title {
      result["title"] = title
    }
    if let artist {
      result["artist"] = artist
    }
    if let album {
      result["album"] = album
    }
    if let playbackRate {
      result["playback_rate"] = playbackRate
    }
    if let durationSeconds {
      result["duration_seconds"] = durationSeconds
    }
    if let positionSeconds {
      result["position_seconds"] = positionSeconds
    }
    if let titleURL {
      result["title_url"] = titleURL
    }
    if let subtitleURL {
      result["subtitle_url"] = subtitleURL
    }
    if let artworkURL {
      result["artwork_url"] = artworkURL
    }
    if let artworkURLLarge {
      result["artwork_url_large"] = artworkURLLarge
    }
    if let artworkHash {
      result["artwork_hash"] = artworkHash
    }
    if let catalogID {
      result["catalog_id"] = catalogID
    }
    return result
  }
}

private final class RpcConnection {
  init(connectionId: String, fileDescriptor: Int32) {
    self.connectionId = connectionId
    self.fileDescriptor = fileDescriptor
  }

  let connectionId: String
  let fileDescriptor: Int32
  var buffer = Data()
}

private final class PresenceStreamHandler: NSObject, FlutterStreamHandler {
  weak var plugin: IslandDesktopPresencePlugin?

  init(plugin: IslandDesktopPresencePlugin) {
    self.plugin = plugin
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    plugin?.presenceEventSink = events
    if let pending = plugin?.pendingPresenceEvent {
      events(pending)
      plugin?.pendingPresenceEvent = nil
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    plugin?.presenceEventSink = nil
    return nil
  }
}

private final class ExternalNowPlayingStreamHandler: NSObject, FlutterStreamHandler {
  weak var plugin: IslandDesktopPresencePlugin?

  init(plugin: IslandDesktopPresencePlugin) {
    self.plugin = plugin
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    plugin?.externalNowPlayingSink = events
    if let pending = plugin?.pendingExternalNowPlayingEvent {
      events(pending)
      plugin?.pendingExternalNowPlayingEvent = nil
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    plugin?.externalNowPlayingSink = nil
    return nil
  }
}

private final class RpcStreamHandler: NSObject, FlutterStreamHandler {
  weak var plugin: IslandDesktopPresencePlugin?

  init(plugin: IslandDesktopPresencePlugin) {
    self.plugin = plugin
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    plugin?.rpcEventSink = events
    let pendingEvents = plugin?.pendingRpcEvents ?? []
    for event in pendingEvents {
      events(event)
    }
    plugin?.pendingRpcEvents.removeAll()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    plugin?.rpcEventSink = nil
    return nil
  }
}

public class IslandDesktopPresencePlugin: NSObject, FlutterPlugin {
  private enum State: String {
    case active
    case idle
  }

  fileprivate var presenceEventSink: FlutterEventSink?
  private var presenceTimer: Timer?
  private var idleThresholdMilliseconds = 300_000
  private var lastEmittedState: State?
  fileprivate var pendingPresenceEvent: [String: Any]?

  fileprivate var externalNowPlayingSink: FlutterEventSink?
  private var externalNowPlayingTimer: Timer?
  private var externalNowPlayingPollInterval = 2.0
  private var externalNowPlayingExecutablePath = defaultNowPlayingCliPath
  
  private var externalNowPlayingPollInFlight = false
  private var externalNowPlayingPollStartTime: Date?
  private var didLogMissingNowPlayingCli = false
  private var lastExternalNowPlayingSnapshot: ExternalNowPlayingSnapshot?
  fileprivate var pendingExternalNowPlayingEvent: [String: Any]?
  private var authToken: String?
  private var serverURL: String?
  private var artworkHashCache: Set<String> = []

  fileprivate var rpcEventSink: FlutterEventSink?
  fileprivate var pendingRpcEvents: [[String: Any]] = []
  private let rpcLock = NSLock()
  private var rpcRunning = false
  private var rpcListenerFileDescriptor: Int32 = -1
  private var rpcSocketPath: String?
  private var nextRpcConnectionId: UInt64 = 1
  private var rpcConnections: [String: RpcConnection] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: "island_desktop_presence",
      binaryMessenger: registrar.messenger
    )
    let presenceEventChannel = FlutterEventChannel(
      name: "island_desktop_presence/events",
      binaryMessenger: registrar.messenger
    )
    let externalNowPlayingChannel = FlutterEventChannel(
      name: "island_desktop_presence/external_now_playing",
      binaryMessenger: registrar.messenger
    )
    let rpcEventChannel = FlutterEventChannel(
      name: "island_desktop_presence/rpc_events",
      binaryMessenger: registrar.messenger
    )

    let instance = IslandDesktopPresencePlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    presenceEventChannel.setStreamHandler(PresenceStreamHandler(plugin: instance))
    externalNowPlayingChannel.setStreamHandler(
      ExternalNowPlayingStreamHandler(plugin: instance)
    )
    rpcEventChannel.setStreamHandler(RpcStreamHandler(plugin: instance))
  }

  deinit {
    stopRpcTransport()
    stopPresenceTimer()
    stopExternalNowPlayingTimer()
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
      startPresenceTimer()
      emitCurrentState(force: true)
      result(nil)
    case "stopMonitoring":
      stopPresenceTimer()
      result(nil)
    case "setAuthToken":
      if let arguments = call.arguments as? [String: Any],
        let token = arguments["token"] as? String
      {
        authToken = token
        serverURL = arguments["serverURL"] as? String
      } else {
        authToken = nil
        serverURL = nil
      }
      result(nil)
    case "startExternalNowPlayingMonitoring":
      guard
        let arguments = call.arguments as? [String: Any],
        let pollIntervalMilliseconds = arguments["pollIntervalMilliseconds"] as? Int,
        pollIntervalMilliseconds > 0
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "pollIntervalMilliseconds must be a positive integer.",
            details: nil
          )
        )
        return
      }

      externalNowPlayingPollInterval = Double(pollIntervalMilliseconds) / 1000.0
      let executablePath = normalizeExternalString(arguments["executablePath"] as? String)
      externalNowPlayingExecutablePath = executablePath ?? defaultNowPlayingCliPath
      didLogMissingNowPlayingCli = false
      NSLog(
        "[IslandDesktopPresence] Starting external now playing monitoring via nowplaying-cli path=%@ interval=%.3fs",
        externalNowPlayingExecutablePath,
        externalNowPlayingPollInterval
      )
      startExternalNowPlayingTimer()
      requestExternalNowPlayingSnapshot(force: true)
      result(nil)
    case "stopExternalNowPlayingMonitoring":
      NSLog("[IslandDesktopPresence] Stopping external now playing monitoring")
      stopExternalNowPlayingTimer()
      result(nil)
    case "startRpcTransport":
      if let errorMessage = startRpcTransport() {
        result(
          FlutterError(
            code: "rpc_transport_unavailable",
            message: errorMessage,
            details: nil
          )
        )
      } else {
        result(nil)
      }
    case "stopRpcTransport":
      stopRpcTransport()
      result(nil)
    case "sendRpcPacket":
      guard
        let arguments = call.arguments as? [String: Any],
        let connectionId = arguments["connectionId"] as? String,
        let packetType = arguments["packetType"] as? Int,
        let dataJson = arguments["dataJson"] as? String
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "sendRpcPacket requires connectionId, packetType and dataJson.",
            details: nil
          )
        )
        return
      }

      if let errorMessage = sendRpcPacket(
        connectionId: connectionId,
        packetType: Int32(packetType),
        dataJson: dataJson
      ) {
        result(FlutterError(code: "rpc_send_failed", message: errorMessage, details: nil))
      } else {
        result(nil)
      }
    case "closeRpcConnection":
      guard
        let arguments = call.arguments as? [String: Any],
        let connectionId = arguments["connectionId"] as? String
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "closeRpcConnection requires connectionId.",
            details: nil
          )
        )
        return
      }

      if let errorMessage = closeRpcConnection(connectionId: connectionId) {
        result(FlutterError(code: "rpc_close_failed", message: errorMessage, details: nil))
      } else {
        result(nil)
      }
    case "debugNowPlaying":
      let executablePath: String
      if let arguments = call.arguments as? [String: Any],
         let path = arguments["executablePath"] as? String,
         !path.isEmpty {
        executablePath = path
      } else {
        executablePath = defaultNowPlayingCliPath
      }
      NSLog("[IslandDesktopPresence] debugNowPlaying called with path=%@", executablePath)
      let snapshot = readExternalNowPlayingSnapshot(executablePath: executablePath)
      if let snapshot {
        NSLog("[IslandDesktopPresence] debugNowPlaying result: source=%@ state=%@ title=%@", snapshot.source.rawValue, snapshot.state.rawValue, snapshot.title ?? "nil")
        result(snapshot.payload)
      } else {
        NSLog("[IslandDesktopPresence] debugNowPlaying result: nil (no active source)")
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startPresenceTimer() {
    stopPresenceTimer(resetState: false)
    presenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
      self?.emitCurrentState(force: false)
    }
    RunLoop.main.add(presenceTimer!, forMode: .common)
  }

  private func stopPresenceTimer(resetState: Bool = true) {
    presenceTimer?.invalidate()
    presenceTimer = nil
    if resetState {
      lastEmittedState = nil
      pendingPresenceEvent = nil
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

    if let presenceEventSink {
      presenceEventSink(event)
    } else {
      pendingPresenceEvent = event
    }
  }

  private func currentIdleMilliseconds() -> Int {
    let seconds = CGEventSource.secondsSinceLastEventType(
      .combinedSessionState,
      eventType: .null
    )
    return max(0, Int((seconds * 1000.0).rounded()))
  }

  private func startExternalNowPlayingTimer() {
    stopExternalNowPlayingTimer(resetState: false)
    externalNowPlayingTimer = Timer.scheduledTimer(
      withTimeInterval: externalNowPlayingPollInterval,
      repeats: true
    ) { [weak self] _ in
      self?.requestExternalNowPlayingSnapshot(force: false)
    }
    RunLoop.main.add(externalNowPlayingTimer!, forMode: .common)
  }

  private func stopExternalNowPlayingTimer(resetState: Bool = true) {
    externalNowPlayingTimer?.invalidate()
    externalNowPlayingTimer = nil
    externalNowPlayingPollInFlight = false
    externalNowPlayingPollStartTime = nil
    if resetState {
      lastExternalNowPlayingSnapshot = nil
      pendingExternalNowPlayingEvent = nil
      didLogMissingNowPlayingCli = false
    }
  }

  private func requestExternalNowPlayingSnapshot(force: Bool) {
    if externalNowPlayingPollInFlight {
      // Safety check: if poll has been in flight for more than 30 seconds, reset it
      if let startTime = externalNowPlayingPollStartTime,
         Date().timeIntervalSince(startTime) > 30 {
        NSLog("[IslandDesktopPresence] Poll stuck for >30s, resetting flag")
        externalNowPlayingPollInFlight = false
        externalNowPlayingPollStartTime = nil
      } else {
        NSLog("[IslandDesktopPresence] Poll skipped - already in flight")
        return
      }
    }

    NSLog("[IslandDesktopPresence] Requesting snapshot (force=%@)", force ? "true" : "false")
    let executablePath = externalNowPlayingExecutablePath
    externalNowPlayingPollInFlight = true
    externalNowPlayingPollStartTime = Date()
    DispatchQueue.global(qos: .utility).async { [weak self] in
      guard let self else {
        NSLog("[IslandDesktopPresence] Self deallocated during poll")
        return
      }
      
      var snapshot: ExternalNowPlayingSnapshot?
      do {
        NSLog("[IslandDesktopPresence] Calling readExternalNowPlayingSnapshot")
        snapshot = self.readExternalNowPlayingSnapshot(executablePath: executablePath)
        NSLog("[IslandDesktopPresence] readExternalNowPlayingSnapshot returned: %@", snapshot != nil ? "snapshot" : "nil")
      } catch {
        NSLog("[IslandDesktopPresence] Error reading snapshot: %@", String(describing: error))
      }
      
      Task { @MainActor [weak self] in
        guard let self else {
          NSLog("[IslandDesktopPresence] Self deallocated before MainActor task")
          return
        }
        let uploadedSnapshot: ExternalNowPlayingSnapshot?
        if let snapshot {
          uploadedSnapshot = await self.ensureArtworkUploaded(snapshot)
        } else {
          uploadedSnapshot = nil
        }
        self.externalNowPlayingPollInFlight = false
        self.externalNowPlayingPollStartTime = nil
        self.handleExternalNowPlayingSnapshot(uploadedSnapshot, force: force)
      }
    }
  }

  private func ensureArtworkUploaded(
    _ snapshot: ExternalNowPlayingSnapshot
  ) async -> ExternalNowPlayingSnapshot {
    guard let artworkHash = snapshot.artworkHash,
      let token = authToken
    else {
      return snapshot
    }

    if artworkHashCache.contains(artworkHash) {
      return snapshot
    }

    let exists = await checkArtworkExists(hash: artworkHash, token: token)
    if exists {
      artworkHashCache.insert(artworkHash)
      return snapshot
    }

    let uploaded = await uploadArtworkIfNeeded(snapshot: snapshot, token: token)
    if uploaded {
      artworkHashCache.insert(artworkHash)
    }
    return snapshot
  }

  private func checkArtworkExists(hash: String, token: String) async -> Bool {
    guard let base = serverURL, let url = URL(string: "\(base)/passport/presence/artworks/\(hash)") else {
      return false
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 5

    do {
      let (_, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
      }
      return false
    } catch {
      return false
    }
  }

  private func uploadArtworkIfNeeded(
    snapshot: ExternalNowPlayingSnapshot,
    token: String
  ) async -> Bool {
    guard let artworkDataString = snapshot.artworkData,
      let imageData = Data(base64Encoded: artworkDataString)
    else {
      return false
    }

    guard let base = serverURL, let url = URL(string: "\(base)/passport/presence/artworks") else {
      return false
    }

    let boundary = UUID().uuidString
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue(
      "multipart/form-data; boundary=\(boundary)",
      forHTTPHeaderField: "Content-Type"
    )
    request.timeoutInterval = 10

    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append(
      "Content-Disposition: form-data; name=\"file\"; filename=\"now-playing.png\"\r\n".data(
        using: .utf8
      )!
    )
    body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    request.httpBody = body

    do {
      let (_, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
      }
      return false
    } catch {
      NSLog(
        "[IslandDesktopPresence] Failed to upload artwork: %@",
        String(describing: error)
      )
      return false
    }
  }

  private func handleExternalNowPlayingSnapshot(
    _ snapshot: ExternalNowPlayingSnapshot?,
    force: Bool
  ) {
    if let snapshot {
      NSLog(
        "[IslandDesktopPresence] Got snapshot: source=%@ state=%@ title=%@ artist=%@",
        snapshot.source.rawValue,
        snapshot.state.rawValue,
        snapshot.title ?? "nil",
        snapshot.artist ?? "nil"
      )
      emitExternalNowPlaying(snapshot, force: force)
      return
    }

    NSLog("[IslandDesktopPresence] Snapshot is nil")
    guard let lastSnapshot = lastExternalNowPlayingSnapshot else {
      NSLog("[IslandDesktopPresence] External now playing poll found no active source and no previous snapshot")
      return
    }

    NSLog(
      "[IslandDesktopPresence] Creating stopped snapshot from previous: source=%@ title=%@",
      lastSnapshot.source.rawValue,
      lastSnapshot.title ?? "nil"
    )
    let stoppedSnapshot = ExternalNowPlayingSnapshot(
      source: lastSnapshot.source,
      state: .stopped,
      providerKey: lastSnapshot.providerKey,
      providerReferenceID: lastSnapshot.providerReferenceID,
      sourceAppName: lastSnapshot.sourceAppName,
      sourceBundleIdentifier: lastSnapshot.sourceBundleIdentifier,
      uniqueIdentifier: lastSnapshot.uniqueIdentifier,
      title: nil,
      artist: nil,
      album: nil,
      playbackRate: lastSnapshot.playbackRate,
      durationSeconds: nil,
      positionSeconds: nil,
      titleURL: lastSnapshot.titleURL,
      subtitleURL: lastSnapshot.subtitleURL,
      artworkURL: lastSnapshot.artworkURL,
      artworkURLLarge: lastSnapshot.artworkURLLarge,
      artworkHash: lastSnapshot.artworkHash,
      artworkData: lastSnapshot.artworkData,
      catalogID: lastSnapshot.catalogID
    )
    emitExternalNowPlaying(stoppedSnapshot, force: force)
  }

  private func emitExternalNowPlaying(
    _ snapshot: ExternalNowPlayingSnapshot,
    force: Bool
  ) {
    if !force, lastExternalNowPlayingSnapshot == snapshot {
      NSLog("[IslandDesktopPresence] Skipping emit - snapshot unchanged and not forced")
      return
    }

    lastExternalNowPlayingSnapshot = snapshot
    let event = snapshot.payload
    NSLog(
      "[IslandDesktopPresence] Emitting external now playing: source=%@ state=%@ providerKey=%@ app=%@ bundle=%@ title=%@ artist=%@ album=%@ id=%@ playbackRate=%@ duration=%@ position=%@",
      snapshot.source.rawValue,
      snapshot.state.rawValue,
      snapshot.providerKey ?? "nil",
      snapshot.sourceAppName ?? "nil",
      snapshot.sourceBundleIdentifier ?? "nil",
      snapshot.title ?? "nil",
      snapshot.artist ?? "nil",
      snapshot.album ?? "nil",
      snapshot.uniqueIdentifier ?? "nil",
      snapshot.playbackRate?.description ?? "nil",
      snapshot.durationSeconds?.description ?? "nil",
      snapshot.positionSeconds?.description ?? "nil"
    )
    NSLog("[IslandDesktopPresence] Full payload: %@", event)
    if let externalNowPlayingSink {
      NSLog("[IslandDesktopPresence] Sending to event sink")
      externalNowPlayingSink(event)
    } else {
      NSLog("[IslandDesktopPresence] No event sink, queuing as pending")
      pendingExternalNowPlayingEvent = event
    }
  }

  private func readExternalNowPlayingSnapshot(
    executablePath: String
  ) -> ExternalNowPlayingSnapshot? {
    NSLog("[IslandDesktopPresence] readExternalNowPlayingSnapshot called with path=%@", executablePath)
    guard FileManager.default.isExecutableFile(atPath: executablePath) else {
      if !didLogMissingNowPlayingCli {
        NSLog("[IslandDesktopPresence] nowplaying-cli is unavailable at %@", executablePath)
        didLogMissingNowPlayingCli = true
      }
      return nil
    }

    NSLog("[IslandDesktopPresence] Executable exists, launching nowplaying-cli")
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executablePath)
    process.arguments = [
      "get",
      "--json",
      "title",
      "artist",
      "album",
      "duration",
      "elapsedTime",
      "playbackRate",
      "bundleIdentifier",
      "clientBundleIdentifier",
      "uniqueIdentifier",
      "artworkData",
    ]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
      NSLog("[IslandDesktopPresence] nowplaying-cli process started, waiting for exit")
      
      // Add timeout to prevent hanging
      let timeoutSeconds: TimeInterval = 10
      let startTime = Date()
      while process.isRunning {
        if Date().timeIntervalSince(startTime) > timeoutSeconds {
          NSLog("[IslandDesktopPresence] nowplaying-cli timed out after %.1fs, terminating", timeoutSeconds)
          process.terminate()
          break
        }
        Thread.sleep(forTimeInterval: 0.1)
      }
      
      if process.isRunning {
        process.waitUntilExit()
      }
      NSLog("[IslandDesktopPresence] nowplaying-cli process exited with status %d", process.terminationStatus)
    } catch {
      NSLog(
        "[IslandDesktopPresence] Failed to launch nowplaying-cli at %@: %@",
        executablePath,
        String(describing: error)
      )
      return nil
    }

    // If process was terminated due to timeout, return nil
    if process.terminationStatus == SIGKILL || process.terminationStatus == 15 {
      NSLog("[IslandDesktopPresence] nowplaying-cli was terminated (timeout or signal)")
      return nil
    }

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    NSLog("[IslandDesktopPresence] nowplaying-cli output: %d bytes, error: %d bytes", outputData.count, errorData.count)
    if process.terminationStatus != 0 {
      let stderr = String(data: errorData, encoding: .utf8) ?? ""
      NSLog(
        "[IslandDesktopPresence] nowplaying-cli exited with status %d: %@",
        process.terminationStatus,
        stderr
      )
      return nil
    }

    guard !outputData.isEmpty else {
      NSLog("[IslandDesktopPresence] nowplaying-cli returned empty output")
      return nil
    }

    let rawOutput = String(data: outputData, encoding: .utf8) ?? ""
    NSLog("[IslandDesktopPresence] nowplaying-cli raw output: %@", rawOutput)

    let decoded: Any
    do {
      decoded = try JSONSerialization.jsonObject(with: outputData)
    } catch {
      NSLog(
        "[IslandDesktopPresence] Failed to decode nowplaying-cli output: %@ raw=%@",
        String(describing: error),
        rawOutput
      )
      return nil
    }

    guard let payload = decoded as? [String: Any] else {
      NSLog("[IslandDesktopPresence] nowplaying-cli output is not a JSON object")
      return nil
    }

    NSLog("[IslandDesktopPresence] nowplaying-cli parsed payload keys: %@", payload.keys.sorted().joined(separator: ", "))

    let bundleIdentifier = normalizeExternalString(
      payload["clientBundleIdentifier"] as? String
    ) ?? normalizeExternalString(payload["bundleIdentifier"] as? String)
    let title = normalizeExternalString(payload["title"] as? String)
    let artist = normalizeExternalString(payload["artist"] as? String)
    let album = normalizeExternalString(payload["album"] as? String)
    let uniqueIdentifier = normalizeExternalString(
      payload["uniqueIdentifier"] as? String
    )
    let artworkData = normalizeExternalString(payload["artworkData"] as? String)
    let playbackRate = numericValue(payload["playbackRate"])
    let durationSeconds = numericValue(payload["duration"])
    let positionSeconds = numericValue(payload["elapsedTime"])

    NSLog(
      "[IslandDesktopPresence] Parsed values: bundleId=%@ title=%@ artist=%@ album=%@ playbackRate=%.2f duration=%.2f position=%.2f",
      bundleIdentifier ?? "nil",
      title ?? "nil",
      artist ?? "nil",
      album ?? "nil",
      playbackRate,
      durationSeconds,
      positionSeconds
    )

    if bundleIdentifier == nil, title == nil, artist == nil, album == nil {
      NSLog("[IslandDesktopPresence] All key fields are nil, returning nil snapshot")
      return nil
    }

    let source = mapExternalSource(bundleIdentifier: bundleIdentifier)
    let providerKey = mapExternalProviderKey(bundleIdentifier: bundleIdentifier)
    NSLog(
      "[IslandDesktopPresence] Mapped source=%@ providerKey=%@ for bundleId=%@",
      source.rawValue,
      providerKey ?? "nil",
      bundleIdentifier ?? "nil"
    )

    let artworkHash: String? = artworkData.flatMap { data in
      guard let imageData = Data(base64Encoded: data) else {
        return nil
      }
      let digest = SHA256.hash(data: imageData)
      let hashHex = digest.map { String(format: "%02x", $0) }.joined()
      return "sha256:\(hashHex)"
    }

    return ExternalNowPlayingSnapshot(
      source: mapExternalSource(bundleIdentifier: bundleIdentifier),
      state: playbackRate > 0 ? .playing : .paused,
      providerKey: mapExternalProviderKey(bundleIdentifier: bundleIdentifier),
      providerReferenceID: nil,
      sourceAppName: resolveApplicationName(bundleIdentifier: bundleIdentifier),
      sourceBundleIdentifier: bundleIdentifier,
      uniqueIdentifier: uniqueIdentifier,
      title: title,
      artist: artist,
      album: album,
      playbackRate: playbackRate >= 0 ? playbackRate : nil,
      durationSeconds: durationSeconds > 0 ? durationSeconds : nil,
      positionSeconds: positionSeconds >= 0 ? positionSeconds : nil,
      titleURL: nil,
      subtitleURL: nil,
      artworkURL: nil,
      artworkURLLarge: nil,
      artworkHash: artworkHash,
      artworkData: artworkData,
      catalogID: nil
    )
  }

  private func startRpcTransport() -> String? {
    rpcLock.lock()
    if rpcRunning {
      rpcLock.unlock()
      return nil
    }
    rpcLock.unlock()

    guard let socketPath = findAvailableRpcSocketPath() else {
      return "No available Discord IPC socket path found."
    }

    let listenerFd = Darwin.socket(AF_UNIX, SOCK_STREAM, 0)
    if listenerFd < 0 {
      return "Failed to create RPC socket."
    }

    Darwin.unlink(socketPath)
    let bindResult = withSockaddrUn(path: socketPath) { address, length in
      Darwin.bind(listenerFd, address, length)
    }
    if bindResult != 0 {
      Darwin.close(listenerFd)
      return "Failed to bind RPC socket."
    }

    if Darwin.listen(listenerFd, 8) != 0 {
      Darwin.close(listenerFd)
      Darwin.unlink(socketPath)
      return "Failed to listen on RPC socket."
    }

    rpcLock.lock()
    rpcRunning = true
    rpcListenerFileDescriptor = listenerFd
    rpcSocketPath = socketPath
    rpcLock.unlock()

    NSLog("[IslandDesktopPresence] RPC transport listening at %@", socketPath)
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.acceptRpcConnections()
    }
    return nil
  }

  private func stopRpcTransport() {
    let listenerFd: Int32
    let socketPath: String?
    let connections: [RpcConnection]

    rpcLock.lock()
    if !rpcRunning {
      rpcLock.unlock()
      return
    }
    rpcRunning = false
    listenerFd = rpcListenerFileDescriptor
    rpcListenerFileDescriptor = -1
    socketPath = rpcSocketPath
    rpcSocketPath = nil
    connections = Array(rpcConnections.values)
    rpcConnections.removeAll()
    rpcLock.unlock()

    if listenerFd >= 0 {
      Darwin.shutdown(listenerFd, SHUT_RDWR)
      Darwin.close(listenerFd)
    }

    for connection in connections {
      Darwin.shutdown(connection.fileDescriptor, SHUT_RDWR)
      Darwin.close(connection.fileDescriptor)
    }

    if let socketPath {
      Darwin.unlink(socketPath)
    }
  }

  private func acceptRpcConnections() {
    while isRpcRunning() {
      let listenerFd = currentRpcListenerFileDescriptor()
      if listenerFd < 0 {
        return
      }

      let clientFd = Darwin.accept(listenerFd, nil, nil)
      if clientFd < 0 {
        if !isRpcRunning() {
          return
        }
        if errno == EINTR {
          continue
        }
        emitRpcError("Failed to accept RPC socket connection.")
        continue
      }

      let connection = createRpcConnection(fileDescriptor: clientFd)
      emitRpcConnected(connection.connectionId)
      DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        self?.readRpcConnection(connection)
      }
    }
  }

  private func readRpcConnection(_ connection: RpcConnection) {
    var readBuffer = [UInt8](repeating: 0, count: 4096)
    while isRpcRunning() {
      let bytesRead = Darwin.recv(
        connection.fileDescriptor,
        &readBuffer,
        readBuffer.count,
        0
      )
      if bytesRead <= 0 {
        break
      }

      connection.buffer.append(readBuffer, count: bytesRead)
      processRpcPackets(for: connection)
    }

    removeRpcConnection(connectionId: connection.connectionId)
    Darwin.shutdown(connection.fileDescriptor, SHUT_RDWR)
    Darwin.close(connection.fileDescriptor)
    emitRpcClosed(connection.connectionId)
  }

  private func processRpcPackets(for connection: RpcConnection) {
    while connection.buffer.count >= 8 {
      let packetType = connection.buffer.withUnsafeBytes { rawBuffer -> Int32 in
        let value = rawBuffer.load(fromByteOffset: 0, as: Int32.self)
        return Int32(littleEndian: value)
      }
      let payloadLength = connection.buffer.withUnsafeBytes { rawBuffer -> Int32 in
        let value = rawBuffer.load(fromByteOffset: 4, as: Int32.self)
        return Int32(littleEndian: value)
      }

      let totalLength = 8 + Int(payloadLength)
      if payloadLength < 0 || connection.buffer.count < totalLength {
        return
      }

      let payloadData = connection.buffer.subdata(in: 8..<totalLength)
      connection.buffer.removeSubrange(0..<totalLength)

      guard let dataJson = String(data: payloadData, encoding: .utf8) else {
        emitRpcError("Received RPC packet with invalid UTF-8 payload.")
        continue
      }
      emitRpcPacket(connection.connectionId, packetType: packetType, dataJson: dataJson)
    }
  }

  private func sendRpcPacket(
    connectionId: String,
    packetType: Int32,
    dataJson: String
  ) -> String? {
    guard let connection = rpcConnection(connectionId: connectionId) else {
      return "Unknown RPC connection."
    }

    let packet = encodeRpcPacket(packetType: packetType, dataJson: dataJson)
    guard writeAll(packet, to: connection.fileDescriptor) else {
      return "Failed to write RPC packet."
    }

    if packetType == 2 {
      removeRpcConnection(connectionId: connectionId)
      Darwin.shutdown(connection.fileDescriptor, SHUT_RDWR)
      Darwin.close(connection.fileDescriptor)
    }

    return nil
  }

  private func closeRpcConnection(connectionId: String) -> String? {
    guard let connection = rpcConnection(connectionId: connectionId) else {
      return "Unknown RPC connection."
    }

    removeRpcConnection(connectionId: connectionId)
    Darwin.shutdown(connection.fileDescriptor, SHUT_RDWR)
    Darwin.close(connection.fileDescriptor)
    return nil
  }

  private func emitRpcConnected(_ connectionId: String) {
    queueRpcEvent([
      "event": "connected",
      "connection_id": connectionId,
    ])
  }

  private func emitRpcPacket(_ connectionId: String, packetType: Int32, dataJson: String) {
    queueRpcEvent([
      "event": "packet",
      "connection_id": connectionId,
      "packet_type": Int(packetType),
      "data_json": dataJson,
    ])
  }

  private func emitRpcClosed(_ connectionId: String) {
    queueRpcEvent([
      "event": "closed",
      "connection_id": connectionId,
    ])
  }

  private func emitRpcError(_ message: String) {
    NSLog("[IslandDesktopPresence] RPC transport error: %@", message)
    queueRpcEvent([
      "event": "error",
      "message": message,
    ])
  }

  private func queueRpcEvent(_ event: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      if let rpcEventSink {
        rpcEventSink(event)
      } else {
        pendingRpcEvents.append(event)
      }
    }
  }

  private func findAvailableRpcSocketPath() -> String? {
    for index in 0..<10 {
      let candidate = "\(rpcSocketBasePath)\(index)"
      let clientFd = Darwin.socket(AF_UNIX, SOCK_STREAM, 0)
      if clientFd >= 0 {
        let connectResult = withSockaddrUn(path: candidate) { address, length in
          Darwin.connect(clientFd, address, length)
        }
        Darwin.close(clientFd)
        if connectResult == 0 {
          continue
        }
      }
      Darwin.unlink(candidate)
      return candidate
    }
    return nil
  }

  private func withSockaddrUn(
    path: String,
    _ body: (UnsafePointer<sockaddr>, socklen_t) -> Int32
  ) -> Int32 {
    var address = sockaddr_un()
    address.sun_family = sa_family_t(AF_UNIX)
    let maxLength = MemoryLayout.size(ofValue: address.sun_path)
    let pathBytes = path.utf8CString
    if pathBytes.count > maxLength {
      return -1
    }

    withUnsafeMutableBytes(of: &address.sun_path) { buffer in
      guard let baseAddress = buffer.baseAddress else {
        return
      }
      let destination = baseAddress.assumingMemoryBound(to: CChar.self)
      destination.initialize(repeating: 0, count: maxLength)
      _ = pathBytes.withUnsafeBufferPointer { source in
        strncpy(destination, source.baseAddress, maxLength - 1)
      }
    }

    let length = socklen_t(MemoryLayout.size(ofValue: address))
    return withUnsafePointer(to: &address) { pointer in
      pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { addressPointer in
        body(addressPointer, length)
      }
    }
  }

  private func createRpcConnection(fileDescriptor: Int32) -> RpcConnection {
    var noSigPipe: Int32 = 1
    _ = withUnsafePointer(to: &noSigPipe) { valuePointer in
      Darwin.setsockopt(
        fileDescriptor,
        SOL_SOCKET,
        SO_NOSIGPIPE,
        valuePointer,
        socklen_t(MemoryLayout<Int32>.size)
      )
    }

    rpcLock.lock()
    let connectionId = String(nextRpcConnectionId)
    nextRpcConnectionId += 1
    let connection = RpcConnection(connectionId: connectionId, fileDescriptor: fileDescriptor)
    rpcConnections[connectionId] = connection
    rpcLock.unlock()
    return connection
  }

  private func removeRpcConnection(connectionId: String) {
    rpcLock.lock()
    rpcConnections.removeValue(forKey: connectionId)
    rpcLock.unlock()
  }

  private func rpcConnection(connectionId: String) -> RpcConnection? {
    rpcLock.lock()
    let connection = rpcConnections[connectionId]
    rpcLock.unlock()
    return connection
  }

  private func isRpcRunning() -> Bool {
    rpcLock.lock()
    let running = rpcRunning
    rpcLock.unlock()
    return running
  }

  private func currentRpcListenerFileDescriptor() -> Int32 {
    rpcLock.lock()
    let fileDescriptor = rpcListenerFileDescriptor
    rpcLock.unlock()
    return fileDescriptor
  }

  private func encodeRpcPacket(packetType: Int32, dataJson: String) -> Data {
    let payloadData = Data(dataJson.utf8)
    var encoded = Data(capacity: 8 + payloadData.count)
    var packetTypeLittleEndian = packetType.littleEndian
    var payloadLengthLittleEndian = Int32(payloadData.count).littleEndian
    withUnsafeBytes(of: &packetTypeLittleEndian) { encoded.append(contentsOf: $0) }
    withUnsafeBytes(of: &payloadLengthLittleEndian) { encoded.append(contentsOf: $0) }
    encoded.append(payloadData)
    return encoded
  }

  private func writeAll(_ packet: Data, to fileDescriptor: Int32) -> Bool {
    var offset = 0

    while offset < packet.count {
      let bytesWritten = packet.withUnsafeBytes { rawBuffer -> Int in
        guard let baseAddress = rawBuffer.baseAddress else {
          return -1
        }

        let bufferAddress = baseAddress.advanced(by: offset)
        return Darwin.send(fileDescriptor, bufferAddress, packet.count - offset, 0)
      }

      if bytesWritten < 0 {
        if errno == EINTR {
          continue
        }
        return false
      }

      if bytesWritten == 0 {
        return false
      }

      offset += bytesWritten
    }

    return true
  }

  private func resolveApplicationName(bundleIdentifier: String?) -> String? {
    guard let bundleIdentifier else {
      return nil
    }
    return NSRunningApplication.runningApplications(
      withBundleIdentifier: bundleIdentifier
    ).first?.localizedName
  }

  private func numericValue(_ value: Any?) -> Double {
    switch value {
    case let number as NSNumber:
      return number.doubleValue
    case let string as String:
      return Double(string) ?? 0
    default:
      return 0
    }
  }

  private func normalizeExternalString(_ value: String?) -> String? {
    return normalizeNonEmptyString(value)
  }

  private func mapExternalSource(bundleIdentifier: String?) -> ExternalNowPlayingSnapshot.Source {
    return .music
  }

  private func mapExternalProviderKey(bundleIdentifier: String?) -> String? {
    return normalizeExternalString(bundleIdentifier)
  }
}
