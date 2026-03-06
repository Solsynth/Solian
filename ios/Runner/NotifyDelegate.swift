//
//  NotifyDelegate.swift
//  Runner
//
//  Created by LittleSheep on 2025/6/1.
//

import Foundation
import Alamofire

class NotifyDelegate: UIResponder, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let textResponse = response as? UNTextInputNotificationResponse else {
            completionHandler()
            return
        }

        let content = response.notification.request.content
        
        // Only handle replies for new messages
        guard let notificationType = content.userInfo["type"] as? String, notificationType == "messages.new" else {
            completionHandler()
            return
        }

        guard let metadata = content.userInfo["meta"] as? [AnyHashable: Any] else {
            completionHandler()
            return
        }
        
        guard let token = UserDefaults.standard.getFlutterToken() else {
            completionHandler()
            return
        }
        
        let serverUrl = UserDefaults.standard.getServerUrl()
        let url = "\(serverUrl)/messager/chat/\(metadata["room_id"] ?? "")/messages"
        
        let parameters: [String: Any?] = [
            "content": textResponse.userText,
            "replied_message_id": metadata["message_id"]
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(
            [HTTPHeader(name: "Authorization", value: "Bearer \(token)")]
        ))
            .validate()
            .responseString { response in
                switch response.result {
                case .success(_):
                    break
                case .failure(let error):
                    print("Failed to send chat reply message: \(error)")
                    break
                }
                // Call completion handler after network request is finished
                completionHandler()
            }
    }
}
