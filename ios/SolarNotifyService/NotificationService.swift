//
//  NotificationService.swift
//  SolarNotifyService
//
//  Created by LittleSheep on 2024/12/8.
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
        switch content.categoryIdentifier {
        case "messaging.message", "messaging.callStart":
            try handleMessagingNotification(request: request, content: content)
        default:
            try handleDefaultNotification(content: content)
        }
    }
    
    private func handleMessagingNotification(request: UNNotificationRequest, content: UNMutableNotificationContent) throws {
        guard let metadata = content.userInfo["metadata"] as? [AnyHashable: Any] else {
            throw ParseNotificationPayloadError.missingMetadata("The notification has no metadata.")
        }
        
        guard let avatarIdentifier = metadata["avatar"] as? String else {
            throw ParseNotificationPayloadError.missingAvatarUrl("The notification has no avatar.")
        }
        
        let replyableMessageCategory = UNNotificationCategory(
            identifier: content.categoryIdentifier,
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
        content.categoryIdentifier = replyableMessageCategory.identifier
        
        let metadataCopy = metadata as? [String: String] ?? [:]
        let avatarUrl = getAttachmentUrl(for: avatarIdentifier)
        
        let targetSize = 640
        let scaleProcessor = ResizingImageProcessor(referenceSize: CGSize(width: targetSize, height: targetSize), mode: .aspectFit)
        
        KingfisherManager.shared.retrieveImage(with: URL(string: avatarUrl)!, options: [.processor(scaleProcessor)], completionHandler: { result in
            var image: Data?
            switch result {
            case .success(let value):
                image = value.image.pngData()
            case .failure(let error):
                print("Unable to get avatar url: \(error)")
            }
            
            let handle = INPersonHandle(value: "\(metadataCopy["user_id"] ?? "")", type: .unknown)
            let sender = INPerson(
                personHandle: handle,
                nameComponents: nil,
                displayName: content.title,
                image: image == nil ? nil : INImage(imageData: image!),
                contactIdentifier: nil,
                customIdentifier: nil
            )
            
            if content.categoryIdentifier == "messaging.callStart" {
                let intent = self.createCallIntent(with: sender)
                self.donateInteraction(for: intent)
                let updatedContent = try? request.content.updating(from: intent)
                self.contentHandler?(updatedContent ?? content)
            } else {
                let intent = self.createMessageIntent(with: sender, metadata: metadataCopy, body: content.body)
                self.donateInteraction(for: intent)
                let updatedContent = try? request.content.updating(from: intent)
                self.contentHandler?(updatedContent ?? content)
            }
        })
    }
    
    private func handleDefaultNotification(content: UNMutableNotificationContent) throws {
        guard let metadata = content.userInfo["metadata"] as? [AnyHashable: Any] else {
            throw ParseNotificationPayloadError.missingMetadata("The notification has no metadata.")
        }
        
        if let imageIdentifier = metadata["image"] as? String {
            attachMedia(to: content, withIdentifier: [imageIdentifier], fileType: UTType.jpeg, doScaleDown: true)
        } else if let avatarIdentifier = metadata["avatar"] as? String {
            attachMedia(to: content, withIdentifier: [avatarIdentifier], fileType: UTType.jpeg, doScaleDown: true)
        } else if let imagesIdentifier = metadata["images"] as? Array<String> {
            attachMedia(to: content, withIdentifier: imagesIdentifier, fileType: UTType.jpeg, doScaleDown: true)
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

        let targetSize = 800
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
    
    private func createCallIntent(with sender: INPerson) -> INStartCallIntent {
        INStartCallIntent(
            callRecordFilter: nil,
            callRecordToCallBack: nil,
            audioRoute: .unknown,
            destinationType: .normal,
            contacts: [sender],
            callCapability: .unknown
        )
    }
    
    private func createMessageIntent(with sender: INPerson, metadata: [AnyHashable: Any], body: String) -> INSendMessageIntent {
        INSendMessageIntent(
            recipients: nil,
            outgoingMessageType: .outgoingMessageText,
            content: body,
            speakableGroupName: nil,
            conversationIdentifier: "\(metadata["channel_id"] ?? "")",
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
