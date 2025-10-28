//
//  CloudFile.swift
//  Runner
//
//  Created by LittleSheep on 2025/5/31.
//

import Foundation

func getAttachmentUrl(for identifier: String) -> String {
    let serverBaseUrl = UserDefaults.standard.getServerUrl()
    
    return identifier.starts(with: "http") ? identifier : "\(serverBaseUrl)/drive/files/\(identifier)"
}
