//
//  SharedConstants.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/16.
//

import Foundation

enum SharedConstants {
    static let appGroupId = "group.solsynth.solian"
    static let urlScheme = "solian"
    static let serverUrlKey = "flutter.app_server_url"
    static let tokenKey = "flutter.dyn_user_tk"
    static let defaultServerUrl = "https://api.solian.app"

    enum API {
        static let notificationsCount = "/ring/notifications/count"
        static let notificationsMarkRead = "/ring/notifications/all/read"
        static let unreadChats = "/messager/chat/unread"
        static let messages = "/messager/chat/%@/messages"
        static let sendMessage = "/messager/chat/%@/messages"
    }
}

extension UserDefaults {
    static let shared: UserDefaults = {
        UserDefaults(suiteName: SharedConstants.appGroupId) ?? UserDefaults.standard
    }()

    func getServerUrl() -> String {
        string(forKey: SharedConstants.serverUrlKey) ?? SharedConstants.defaultServerUrl
    }

    func getAuthToken() -> String? {
        guard let jsonString = string(forKey: SharedConstants.tokenKey),
              let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let jsonDict = jsonObject as? [String: Any],
              let token = jsonDict["token"] as? String else {
            return nil
        }
        return token
    }
}
