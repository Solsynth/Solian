import Cocoa
import CoreBluetooth
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let meetAdvertiser = MeetBluetoothAdvertiser()

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "dev.solsynth.solian/meet_bluetooth",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "App delegate is unavailable.", details: nil))
        return
      }

      switch call.method {
      case "startAdvertising":
        guard
          let args = call.arguments as? [String: Any],
          let meetId = args["meetId"] as? String
        else {
          result(FlutterError(code: "invalid_meet_id", message: "Meet id is required.", details: nil))
          return
        }
        self.meetAdvertiser.startAdvertising(meetId: meetId, result: result)
      case "stopAdvertising":
        self.meetAdvertiser.stopAdvertising()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool)
    -> Bool
  {
    if !flag {
      for window in NSApp.windows {
        if !window.isVisible {
          window.setIsVisible(true)
        }
        window.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
      }
    }
    return true
  }

  override func applicationWillTerminate(_ notification: Notification) {
    meetAdvertiser.stopAdvertising()
    super.applicationWillTerminate(notification)
  }
}

final class MeetBluetoothAdvertiser: NSObject, CBPeripheralManagerDelegate {
  private let serviceUUID = CBUUID(string: "FFF0")
  private var peripheralManager: CBPeripheralManager?
  private var pendingMeetData: Data?
  private var pendingResult: FlutterResult?

  func startAdvertising(meetId: String, result: @escaping FlutterResult) {
    guard let meetData = uuidData(from: meetId) else {
      result(FlutterError(code: "invalid_meet_id", message: "Meet id must be a UUID.", details: nil))
      return
    }

    stopAdvertising()
    pendingMeetData = meetData
    pendingResult = result

    if peripheralManager == nil {
      peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    } else {
      startAdvertisingIfReady()
    }
  }

  func stopAdvertising() {
    peripheralManager?.stopAdvertising()
    pendingMeetData = nil
    pendingResult = nil
  }

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    startAdvertisingIfReady()
  }

  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    if let error {
      pendingResult?(FlutterError(code: "advertise_failed", message: error.localizedDescription, details: nil))
    } else {
      pendingResult?(true)
    }
    pendingResult = nil
  }

  private func startAdvertisingIfReady() {
    guard let peripheralManager, let payload = pendingMeetData else { return }

    switch peripheralManager.state {
    case .poweredOn:
      let advertisement: [String: Any] = [
        CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
        CBAdvertisementDataServiceDataKey: [serviceUUID: payload],
      ]
      peripheralManager.startAdvertising(advertisement)
    case .unsupported:
      pendingResult?(FlutterError(code: "bluetooth_unavailable", message: "BLE advertising is not supported on this Mac.", details: nil))
      pendingResult = nil
      pendingMeetData = nil
    case .unauthorized:
      pendingResult?(FlutterError(code: "bluetooth_unauthorized", message: "Bluetooth permission is required to advertise a meet.", details: nil))
      pendingResult = nil
      pendingMeetData = nil
    case .poweredOff:
      pendingResult?(FlutterError(code: "bluetooth_unavailable", message: "Bluetooth must be turned on.", details: nil))
      pendingResult = nil
      pendingMeetData = nil
    case .resetting, .unknown:
      break
    @unknown default:
      pendingResult?(FlutterError(code: "bluetooth_unknown", message: "Bluetooth is not ready.", details: nil))
      pendingResult = nil
      pendingMeetData = nil
    }
  }

  private func uuidData(from value: String) -> Data? {
    let hex = value.replacingOccurrences(of: "-", with: "")
    guard hex.count == 32 else { return nil }

    var bytes = [UInt8]()
    bytes.reserveCapacity(16)

    var index = hex.startIndex
    while index < hex.endIndex {
      let nextIndex = hex.index(index, offsetBy: 2)
      guard
        nextIndex <= hex.endIndex,
        let byte = UInt8(hex[index..<nextIndex], radix: 16)
      else {
        return nil
      }
      bytes.append(byte)
      index = nextIndex
    }

    return Data(bytes)
  }
}
