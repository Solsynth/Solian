//
//  GroupDefaultSync.swift
//  Runner
//
//  Created by LittleSheep on 2026/1/3.
//

import Foundation

private let flutterKeyPrefix = "flutter."

private let flutterKeysToSync: [String] = [
    "dyn_user_tk"
]

func syncDefaultsToGroup() {
    let standard = UserDefaults.standard
    let shared = UserDefaults(suiteName: "dev.solsynth.solian")

    guard let shared else {
        print("[iOS] App Group UserDefaults not available")
        return
    }

    for key in flutterKeysToSync {
        guard key.hasPrefix(flutterKeyPrefix) else { continue }

        if let value = standard.object(forKey: key) {
            print("[iOS] Syncing key to App Group: \(key)")
            shared.set(value, forKey: key)
        }
    }

    shared.synchronize()
}
