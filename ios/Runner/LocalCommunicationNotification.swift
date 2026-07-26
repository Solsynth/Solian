import Flutter
import Foundation
import Intents
import UniformTypeIdentifiers
import UserNotifications

enum LocalCommunicationNotification {
    static let channelName = "dev.solsynth.solian/local_communication_notification"

    static func install(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
        channel.setMethodCallHandler { call, result in
            guard call.method == "show" else {
                result(FlutterMethodNotImplemented)
                return
            }

            guard let arguments = call.arguments as? [String: Any] else {
                result(FlutterError(
                    code: "invalid_arguments",
                    message: "Expected notification arguments.",
                    details: nil
                ))
                return
            }

            show(arguments: arguments, result: result)
        }
    }

    private static func show(arguments: [String: Any], result: @escaping FlutterResult) {
        guard let identifier = arguments["id"] as? String,
              let title = arguments["title"] as? String,
              let body = arguments["body"] as? String,
              let topic = arguments["topic"] as? String,
              let threadId = arguments["threadId"] as? String else {
            result(FlutterError(
                code: "invalid_arguments",
                message: "Missing required communication notification fields.",
                details: nil
            ))
            return
        }

        let meta = arguments["meta"] as? [String: Any] ?? [:]
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName("SfxMessage.caf"))
        content.threadIdentifier = threadId
        content.categoryIdentifier = "CHAT_MESSAGE"
        var userInfo: [AnyHashable: Any] = [
            "type": topic,
            "meta": meta,
        ]
        if let payload = arguments["payload"] as? String {
            userInfo["action_uri"] = payload
        }
        content.userInfo = userInfo

        let senderName = (meta["sender_name"] as? String) ?? title
        let sender = INPerson(
            personHandle: INPersonHandle(value: "@\(senderName)", type: .unknown),
            nameComponents: PersonNameComponents(nickname: senderName),
            displayName: senderName,
            image: senderImage(from: arguments["senderImagePath"] as? String),
            contactIdentifier: nil,
            customIdentifier: nil
        )
        let intent = INSendMessageIntent(
            recipients: nil,
            outgoingMessageType: .outgoingMessageText,
            content: body,
            speakableGroupName: (meta["room_name"] as? String).map(INSpeakableString.init(spokenPhrase:)),
            conversationIdentifier: String(describing: meta["room_id"] ?? ""),
            serviceName: nil,
            sender: sender,
            attachments: nil
        )

        let enrichedContent = (try? content.updating(from: intent))
            .flatMap { $0.mutableCopy() as? UNMutableNotificationContent } ?? content
        enrichedContent.sound = content.sound
        enrichedContent.threadIdentifier = threadId
        enrichedContent.categoryIdentifier = "CHAT_MESSAGE"
        enrichedContent.userInfo = content.userInfo
        enrichedContent.attachments = notificationAttachments(
            from: arguments["attachmentPaths"] as? [String] ?? []
        )

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        interaction.donate(completion: nil)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: enrichedContent,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                result(FlutterError(
                    code: "notification_error",
                    message: error.localizedDescription,
                    details: nil
                ))
            } else {
                result(true)
            }
        }
    }

    private static func senderImage(from path: String?) -> INImage? {
        guard let path, let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        return INImage(imageData: data)
    }

    private static func notificationAttachments(from paths: [String]) -> [UNNotificationAttachment] {
        paths.enumerated().compactMap { index, path in
            try? UNNotificationAttachment(
                identifier: "attachment-\(index)",
                url: URL(fileURLWithPath: path),
                options: [UNNotificationAttachmentOptionsTypeHintKey: UTType.image.identifier]
            )
        }
    }
}
