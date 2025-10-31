//
//  NotificationService.swift
//  NotificationService
//
//  Created by LittleSheep on 2025/5/31.
//

import UserNotifications
import Intents
import Kingfisher
import UniformTypeIdentifiers

enum ParseNotificationPayloadError: Error {
    case missingMetadata(String)
    case missingAvatarUrl(String)
}

class NotificationService: UNNotificationServiceExtension {
    
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        guard let bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }
        self.bestAttemptContent = bestAttemptContent
        
        do {
            try processNotification(request: request, content: bestAttemptContent)
        } catch {
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func processNotification(request: UNNotificationRequest, content: UNMutableNotificationContent) throws {
        switch content.userInfo["type"] as? String {
        case "messages.new":
            try handleMessagingNotification(request: request, content: content)
        default:
            try handleDefaultNotification(content: content)
        }
    }
    
    private func handleMessagingNotification(request: UNNotificationRequest, content: UNMutableNotificationContent) throws {
        guard let meta = content.userInfo["meta"] as? [AnyHashable: Any] else {
            throw ParseNotificationPayloadError.missingMetadata("The notification has no meta.")
        }

        let pfpIdentifier = meta["pfp"] as? String
        let metaCopy = meta as? [String: Any] ?? [:]
        let pfpUrl = pfpIdentifier != nil ? getAttachmentUrl(for: pfpIdentifier!) : nil

        let handle = INPersonHandle(value: "\(metaCopy["user_id"] ?? "")", type: .unknown)

        if let pfpUrl = pfpUrl, let url = URL(string: pfpUrl) {
            let targetSize = 512
            let scaleProcessor = ResizingImageProcessor(referenceSize: CGSize(width: targetSize, height: targetSize), mode: .aspectFit)

            KingfisherManager.shared.retrieveImage(with: url, options: [.processor(scaleProcessor)], completionHandler: { result in
                var image: Data?
                switch result {
                case .success(let value):
                    image = value.image.pngData()
                case .failure(let error):
                    print("Unable to get pfp url: \(error)")
                }

                let sender = INPerson(
                    personHandle: handle,
                    nameComponents: PersonNameComponents(nickname: "\(metaCopy["sender_name"] ?? "")"),
                    displayName: content.title,
                    image: image == nil ? nil : INImage(imageData: image!),
                    contactIdentifier: nil,
                    customIdentifier: nil
                )

                let intent = self.createMessageIntent(with: sender, meta: metaCopy, body: content.body)
                self.donateInteraction(for: intent)

                content.categoryIdentifier = "CHAT_MESSAGE"
                self.contentHandler?(content)
            })
        } else {
            let sender = INPerson(
                personHandle: handle,
                nameComponents: PersonNameComponents(nickname: "\(metaCopy["sender_name"] ?? "")"),
                displayName: content.title,
                image: nil,
                contactIdentifier: nil,
                customIdentifier: nil
            )

            let intent = self.createMessageIntent(with: sender, meta: metaCopy, body: content.body)
            self.donateInteraction(for: intent)

            content.categoryIdentifier = "CHAT_MESSAGE"
            self.contentHandler?(content)
        }
    }
    
    private func handleDefaultNotification(content: UNMutableNotificationContent) throws {
        guard let meta = content.userInfo["meta"] as? [AnyHashable: Any] else {
            throw ParseNotificationPayloadError.missingMetadata("The notification has no meta.")
        }
        
        if let imageIdentifier = meta["image"] as? String {
            attachMedia(to: content, withIdentifier: [imageIdentifier], fileType: UTType.webP, doScaleDown: true)
        } else if let pfpIdentifier = meta["pfp"] as? String {
            attachMedia(to: content, withIdentifier: [pfpIdentifier], fileType: UTType.webP, doScaleDown: true)
        } else if let imagesIdentifier = meta["images"] as? Array<String> {
            attachMedia(to: content, withIdentifier: imagesIdentifier, fileType: UTType.webP, doScaleDown: true)
        } else {
            contentHandler?(content)
        }
    }
    
    private func attachMedia(to content: UNMutableNotificationContent, withIdentifier identifier: Array<String>, fileType type: UTType?, doScaleDown scaleDown: Bool = false) {
        let attachmentUrls = identifier.compactMap { element in
            return getAttachmentUrl(for: element)
        }

        guard !attachmentUrls.isEmpty else {
            print("Invalid URLs for attachments: \(attachmentUrls)")
            return
        }

        let targetSize = 512
        let scaleProcessor = ResizingImageProcessor(referenceSize: CGSize(width: targetSize, height: targetSize), mode: .aspectFit)

        for attachmentUrl in attachmentUrls {
            guard let remoteUrl = URL(string: attachmentUrl) else {
                print("Invalid URL for attachment: \(attachmentUrl)")
                continue // Skip this URL and move to the next one
            }

            KingfisherManager.shared.retrieveImage(with: remoteUrl, options: scaleDown ? [
                .processor(scaleProcessor)
            ] : nil) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let retrievalResult):
                    // The image is either retrieved from cache or downloaded
                    let tempDirectory = FileManager.default.temporaryDirectory
                    let cachedFileUrl = tempDirectory.appendingPathComponent(UUID().uuidString) // Unique identifier for each file

                    do {
                        // Write the image data to a temporary file for UNNotificationAttachment
                        try retrievalResult.image.pngData()?.write(to: cachedFileUrl)
                        self.attachLocalMedia(to: content, fileType: type?.identifier, from: cachedFileUrl, withIdentifier: attachmentUrl)
                    } catch {
                        print("Failed to write media to temporary file: \(error.localizedDescription)")
                        self.contentHandler?(content)
                    }

                case .failure(let error):
                    print("Failed to retrieve image: \(error.localizedDescription)")
                    self.contentHandler?(content)
                }
            }
        }
    }
    
    private func attachLocalMedia(to content: UNMutableNotificationContent, fileType type: String?, from localUrl: URL, withIdentifier identifier: String) {
        do {
            let attachment = try UNNotificationAttachment(identifier: identifier, url: localUrl, options: [
                UNNotificationAttachmentOptionsTypeHintKey: type as Any,
                UNNotificationAttachmentOptionsThumbnailHiddenKey: 0,
            ])
            content.attachments = [attachment]
        } catch let error as NSError {
            // Log detailed error information
            print("Failed to create attachment from file at \(localUrl.path)")
            print("Error: \(error.localizedDescription)")
            
            // Check specific error codes if needed
            if error.domain == NSCocoaErrorDomain {
                switch error.code {
                case NSFileReadNoSuchFileError:
                    print("File does not exist at \(localUrl.path)")
                case NSFileReadNoPermissionError:
                    print("No permission to read file at \(localUrl.path)")
                default:
                    print("Unhandled file error: \(error.code)")
                }
            }
        }
        
        // Call content handler regardless of success or failure
        self.contentHandler?(content)
    }
    
    private func createMessageIntent(with sender: INPerson, meta: [AnyHashable: Any], body: String) -> INSendMessageIntent {
        INSendMessageIntent(
            recipients: nil,
            outgoingMessageType: .outgoingMessageText,
            content: body,
            speakableGroupName: meta["room_name"] != nil ? INSpeakableString(spokenPhrase: meta["room_name"] as! String) : nil,
            conversationIdentifier: "\(meta["room_id"] ?? "")",
            serviceName: nil,
            sender: sender,
            attachments: nil
        )
    }
    
    private func donateInteraction(for intent: INIntent) {
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        interaction.donate(completion: nil)
    }
}
