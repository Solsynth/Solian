//
//  AttachmentUtils.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import Foundation

// MARK: - Helper Functions

func getAttachmentUrl(for fileId: String, serverUrl: String) -> URL? {
    let urlString: String
    if fileId.starts(with: "http") {
        urlString = fileId
    } else {
        urlString = "\(serverUrl)/drive/files/\(fileId)"
    }
    return URL(string: urlString)
}
