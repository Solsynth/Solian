//
//  GroupDefaultSync.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/3.
//

import Foundation

private let flutterKeyPrefix = "flutter."

private let flutterKeysToSync: [String] = [
    "dyn_user_tk",
    "app_server_url"
]

func sendCfgToAppGroup() {
    print("[iOS] sendCfgToAppGroup() called")
    
    let standard = UserDefaults.standard
    let shared = UserDefaults(suiteName: "group.solsynth.solian")
    
    guard let shared else {
        print("[iOS] App Group UserDefaults not available")
        return
    }
    
    for key in flutterKeysToSync {
        let prefixedKey = key.starts(with: flutterKeyPrefix) ? key : flutterKeyPrefix + key
        
        if let value = standard.object(forKey: prefixedKey) {
            print("[iOS] Syncing key to App Group: \(prefixedKey)")
            shared.set(value, forKey: prefixedKey)
        } else {
            print("[iOS] Key \(prefixedKey) was not found in the app data, skipping...")
        }
    }
    
    shared.synchronize()
    print("[iOS] Sync completed")
}
