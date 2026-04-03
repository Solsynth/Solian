//
//  ReactionTemplates.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import Foundation

struct ReactionInfo {
    let icon: String
    let attitude: Int
}

enum ReactionAttitude: Int {
    case positive = 0
    case neutral = 1
    case negative = 2
}

let kReactionTemplates: [String: ReactionInfo] = [
    "thumb_up": ReactionInfo(icon: "👍", attitude: 0),
    "thumb_down": ReactionInfo(icon: "👎", attitude: 2),
    "just_okay": ReactionInfo(icon: "😅", attitude: 1),
    "cry": ReactionInfo(icon: "😭", attitude: 1),
    "confuse": ReactionInfo(icon: "🧐", attitude: 1),
    "clap": ReactionInfo(icon: "👏", attitude: 0),
    "laugh": ReactionInfo(icon: "😂", attitude: 0),
    "angry": ReactionInfo(icon: "😡", attitude: 2),
    "party": ReactionInfo(icon: "🎉", attitude: 0),
    "pray": ReactionInfo(icon: "🙏", attitude: 0),
    "heart": ReactionInfo(icon: "❤️", attitude: 0),
]

let kPositiveReactions = ["thumb_up", "clap", "laugh", "party", "pray", "heart"]
let kNeutralReactions = ["just_okay", "cry", "confuse"]
let kNegativeReactions = ["thumb_down", "angry"]

func getReactionIcon(_ symbol: String) -> String {
    return kReactionTemplates[symbol]?.icon ?? "❓"
}

func getReactionAttitude(_ symbol: String) -> Int {
    return kReactionTemplates[symbol]?.attitude ?? 1
}