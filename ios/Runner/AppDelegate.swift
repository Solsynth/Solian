import Flutter
import WidgetKit
import UIKit
import WatchConnectivity
import AppIntents
import CoreBluetooth

@main
@objc class AppDelegate: FlutterAppDelegate {
    let notifyDelegate = NotifyDelegate()
    private static var sharedWatchConnectivityService: WatchConnectivityService?
    private let meetAdvertiser = MeetBluetoothAdvertiser()

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

        setupWidgetSyncChannel()
        setupMeetBluetoothChannel()

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

    private func setupMeetBluetoothChannel() {
        let controller = window?.rootViewController as? FlutterViewController
        let channel = FlutterMethodChannel(name: "dev.solsynth.solian/meet_bluetooth", binaryMessenger: controller!.binaryMessenger)

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

    override func applicationDidEnterBackground(_ application: UIApplication) {
        syncDefaultsToGroup()
        WidgetCenter.shared.reloadAllTimelines()
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        meetAdvertiser.stopAdvertising()
        syncDefaultsToGroup()
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
            pendingResult?(FlutterError(code: "bluetooth_unavailable", message: "BLE advertising is not supported on this device.", details: nil))
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
