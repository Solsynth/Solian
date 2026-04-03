//
//  ReactionSheetView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI
#if os(watchOS)
import WatchKit
#endif

struct ReactionSheetView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isReacting = false
    
    private let networkService = NetworkService()
    
    private var screenWidth: CGFloat {
        #if os(watchOS)
        return WKInterfaceDevice.current().screenBounds.width - 16
        #else
        return 180
        #endif
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                reactionSection(title: "Positive", symbols: kPositiveReactions)
                reactionSection(title: "Neutral", symbols: kNeutralReactions)
                reactionSection(title: "Negative", symbols: kNegativeReactions)
            }
            .padding(8)
        }
        .navigationTitle("React")
        .overlay {
            if isReacting {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }

    @ViewBuilder
    private func reactionSection(title: String, symbols: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 4) {
                ForEach(symbols, id: \.self) { symbol in
                    Button {
                        Task {
                            await toggleReaction(symbol: symbol)
                        }
                    } label: {
                        Text(getReactionIcon(symbol))
                            .font(.body)
                            .padding(4)
                            .frame(width: 28, height: 28)
                            .background(
                                (post.reactionsMade?[symbol] ?? false)
                                    ? Color.accentColor.opacity(0.3)
                                    : Color.gray.opacity(0.15)
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isReacting)
                }
            }
        }
    }

    private func toggleReaction(symbol: String) async {
        guard let token = appState.token, let serverUrl = appState.serverUrl else {
            print("[ReactionSheetView] Missing token or serverUrl")
            return
        }
        
        print("[ReactionSheetView] token: \(String(token.prefix(20)))...")
        print("[ReactionSheetView] serverUrl: \(serverUrl)")
        
        isReacting = true
        
        do {
            let result = try await networkService.reactToPost(
                postId: post.id,
                symbol: symbol,
                attitude: getReactionAttitude(symbol),
                token: token,
                serverUrl: serverUrl
            )
            print("[ReactionSheetView] Reaction result: \(result)")
            dismiss()
        } catch {
            print("Reaction error: \(error)")
        }
        
        isReacting = false
    }
}