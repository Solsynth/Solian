//
//  ShareViewController.swift
//  SolianShareExtension
//
//  Created by LittleSheep on 2025/6/25.
//

import receive_sharing_intent

class ShareViewController: RSIShareViewController {
    override func shouldAutoRedirect() -> Bool {
        return false
    }
}
