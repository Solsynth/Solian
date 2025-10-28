//
//  DataExchange.swift
//  Runner
//
//  Created by LittleSheep on 2025/6/2.
//

import Foundation

extension UserDefaults {
    func getFlutterValue<T>(forKey key: String) -> T? {
        let prefixedKey = "flutter.\(key)"
        return self.object(forKey: prefixedKey) as? T
    }

    func getFlutterToken(forKey key: String = "dyn_user_tk") -> String? {
        let prefixedKey = "flutter.\(key)"
        guard let jsonString = self.string(forKey: prefixedKey),
              let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let jsonDict = jsonObject as? [String: Any],
              let token = jsonDict["token"] as? String else {
            return nil
        }
        return token
    }
    
    func getServerUrl(forKey key: String = "app_server_url") -> String {
        return self.getFlutterValue(forKey: key) ?? "https://api.solian.app"
    }
}
