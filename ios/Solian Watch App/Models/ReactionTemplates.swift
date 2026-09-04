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
    "cry": ReactionInfo(icon: "😭", attitude: 1),
    "confuse": ReactionInfo(icon: "🧐", attitude: 1),
    "hello": ReactionInfo(icon: "👋", attitude: 1),
    "shock": ReactionInfo(icon: "😱", attitude: 1),
    "speechless": ReactionInfo(icon: "😶", attitude: 1),
    "ridicule": ReactionInfo(icon: "😏", attitude: 1),
    "salute": ReactionInfo(icon: "🫡", attitude: 0),
    "clap": ReactionInfo(icon: "👏", attitude: 0),
    "laugh": ReactionInfo(icon: "😂", attitude: 0),
    "angry": ReactionInfo(icon: "😡", attitude: 2),
    "party": ReactionInfo(icon: "🎉", attitude: 0),
    "pray": ReactionInfo(icon: "🙏", attitude: 1),
    "heart": ReactionInfo(icon: "❤️", attitude: 0),
]

let kPositiveReactions = ["thumb_up", "clap", "laugh", "party", "salute", "heart"]
let kNeutralReactions = ["cry", "confuse", "hello", "shock", "speechless", "ridicule", "pray"]
let kNegativeReactions = ["thumb_down", "angry"]

func getReactionIcon(_ symbol: String) -> String {
    return kReactionTemplates[symbol]?.icon ?? "❓"
}

func getReactionAttitude(_ symbol: String) -> Int {
    return kReactionTemplates[symbol]?.attitude ?? 1
}

// MARK: - Post category display helpers

/// Localized title for a known category slug, mirroring the main app's
/// `postCategory<CapitalizedSlug>` translation keys (en-US/base fallback).
func localizedCategoryName(_ slug: String) -> String {
    let known: [String: String] = [
        "art": "Art",
        "finance": "Finance",
        "food": "Food",
        "gaming": "Gaming",
        "health": "Health",
        "life": "Life",
        "music": "Music",
        "programming": "Programming",
        "science": "Science",
        "sports": "Sports",
    ]
    return known[slug] ?? slug.replacingOccurrences(of: "-", with: " ").capitalized
}

/// Display label for a tag: prefer its name, else "#slug" (matches the SDK).
func tagDisplayName(_ slug: String, name: String?) -> String {
    if let name = name, !name.isEmpty { return name }
    return "#\(slug)"
}