//
//  ShareViewController.swift
//  SolianShareExtension
//
//  Created by LittleSheep on 2025/6/25.
//

import flutter_sharing_intent
import Intents

class ShareViewController: FSIShareViewController {
    override func viewDidAppear(_ animated: Bool) {
        persistSuggestedConversationTarget()
        super.viewDidAppear(animated)
    }

    private func persistSuggestedConversationTarget() {
        guard let sendMessageIntent = extensionContext?.intent as? INSendMessageIntent,
              let roomId = sendMessageIntent.conversationIdentifier,
              !roomId.isEmpty else {
            return
        }

        let shareExtensionId = Bundle.main.bundleIdentifier ?? ""
        let hostBundleIdentifier = shareExtensionId.split(separator: ".").dropLast().joined(separator: ".")
        let appGroupId =
            (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ??
            "group.\(hostBundleIdentifier)"

        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            return
        }

        defaults.set(roomId, forKey: "dev.solsynth.solian.shareSuggestions.pendingRoomId")
        defaults.synchronize()
    }
}
