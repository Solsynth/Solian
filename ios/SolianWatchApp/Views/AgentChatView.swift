//
//  AgentChatView.swift
//  Solian Watch App
//
//  Created on 2026-09-06.
//
//  Agent conversation UI — minimalist watchOS design matching
//  ChatRoomView patterns: conversation list → thread with streaming
//  bubbles, expandable thinking traces, compact tool indicators,
//  and an icon-only compose bar.
//

import SwiftUI

// MARK: - Root view

/// Agent chat panel: conversation list as the main view. Tapping a
/// conversation pushes the chat thread. "New Chat" starts a fresh thread.
struct AgentChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: AgentChatViewModel
    @State private var showingAgentPicker = false
    @State private var navigatingToThread = false

    init() {
        _viewModel = StateObject(wrappedValue: AgentChatViewModel(appState: AppState.shared))
    }

    var body: some View {
        conversationList
            .navigationDestination(isPresented: $navigatingToThread) {
                AgentChatThreadView(viewModel: viewModel)
            }
    }

    // MARK: - Conversation list

    private var conversationList: some View {
        List {
            Button {
                viewModel.pendingNewChat = true
                navigatingToThread = true
            } label: {
                Label(L10n.agentNewChat, systemImage: "plus.circle")
            }

            if viewModel.isLoading || viewModel.isLoadingConversations {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }

            ForEach(viewModel.conversations) { conversation in
                Button {
                    viewModel.pendingConversation = conversation
                    navigatingToThread = true
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(conversation.displayName)
                            .lineLimit(1)
                            .font(.body)
                        if let date = conversation.lastMessageAt {
                            Text(date, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(L10n.agentTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAgentPicker = true
                } label: {
                    Image(systemName: "person.circle")
                }
            }
        }
        .sheet(isPresented: $showingAgentPicker) {
            agentPickerSheet
        }
        .alert(L10n.agentError, isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task { await viewModel.loadInitial() }
    }

    // MARK: - Agent picker sheet

    private var agentPickerSheet: some View {
        NavigationStack {
            List(viewModel.agents) { agent in
                Button {
                    viewModel.selectAgent(agent.id)
                    showingAgentPicker = false
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(agent.displayName)
                                .font(.body)
                            if let desc = agent.description, !desc.isEmpty {
                                Text(desc)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        Spacer()
                        if agent.id == viewModel.selectedAgentId {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle(L10n.agentPickAgent)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAgentPicker = false
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

// MARK: - Chat thread

/// The active conversation: scrollable message list + compose bar.
/// Mirrors ChatRoomView's structure and visual language.
struct AgentChatThreadView: View {
    @ObservedObject var viewModel: AgentChatViewModel
    @FocusState private var composerFocused: Bool

    var body: some View {
        messageList
            .navigationTitle(L10n.agentTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.abort()
                        viewModel.newConversation()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .task { await viewModel.consumePending() }
    }

    // MARK: - Message list

    @ViewBuilder
    private var messageList: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        if viewModel.bubbles.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.bubbles) { bubble in
                                AgentBubbleRow(bubble: bubble)
                                    .id(bubble.id)
                            }
                        }
                        composeBar
                            .id("compose-bar")
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)
                }
                .onAppear { scrollToLatest(proxy) }
                .onChange(of: viewModel.bubbles.count) { _, _ in
                    scrollToLatest(proxy)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }

    private func scrollToLatest(_ proxy: ScrollViewProxy) {
        withAnimation { proxy.scrollTo("compose-bar", anchor: .bottom) }
    }

    // MARK: - Compose bar

    private var composeBar: some View {
        HStack(alignment: .center, spacing: 12) {
            messageField
            if showSendButton {
                sendButton
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var messageField: some View {
        TextField(L10n.agentMessagePlaceholder, text: $viewModel.draft)
            .buttonBorderShape(.capsule)
            .submitLabel(.send)
            .labelsHidden()
            .onSubmit { sendFromBar() }
            .focused($composerFocused)
            .textFieldStyle(.plain)
    }

    @ViewBuilder
    private var sendButton: some View {
        Button {
            sendFromBar()
        } label: {
            if viewModel.isBusy {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.red)
            } else {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 22))
            }
        }
        .buttonStyle(.plain)
        .disabled(!canSendFromBar || viewModel.isBusy)
    }

    private var canSendFromBar: Bool {
        !viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var showSendButton: Bool {
        canSendFromBar || viewModel.isBusy
    }

    private func sendFromBar() {
        guard canSendFromBar else { return }
        WKInterfaceDevice.current().play(.click)
        viewModel.send()
        if !viewModel.isBusy {
            composerFocused = true
        }
    }
}

// MARK: - Bubble rows

/// A single agent conversation bubble. User messages right-aligned with
/// accent fill; assistant left-aligned with subtle surface. Thinking and
/// tool traces are compact, expandable on tap.
private struct AgentBubbleRow: View {
    let bubble: AgentBubble
    /// Starts synced with the bubble's collapsed state from the ViewModel.
    /// User toggles override; streaming traces force expanded.
    @State private var expanded: Bool

    init(bubble: AgentBubble) {
        self.bubble = bubble
        _expanded = State(initialValue: !bubble.collapsed)
    }

    var body: some View {
        switch bubble.kind {
        case .user:
            userBubble
        case .assistant:
            assistantBubble
        case .thinking:
            thinkingTrace
        case .tool:
            toolTrace
        }
    }

    // MARK: User bubble — matches ChatRoomView own-message style

    private var userBubble: some View {
        HStack {
            Spacer(minLength: 32)
            Text(bubble.text)
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.85), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: Assistant bubble — matches ChatRoomView other-message style

    private var assistantBubble: some View {
        HStack {
            Text(bubble.text.isEmpty && bubble.streaming ? "…" : bubble.text)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.16), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .opacity(bubble.streaming ? 0.8 : 1.0)
            Spacer(minLength: 32)
        }
    }

    // MARK: Thinking trace — expandable, compact

    /// Collapsed: `✨ › thinking…` (one line). Expanded: full text with
    /// italic styling. Tap toggles. Streaming traces stay expanded.
    private var thinkingTrace: some View {
        let isExpanded = expanded || bubble.streaming
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                expanded.toggle()
            }
        } label: {
            HStack(spacing: 3) {
                if bubble.streaming {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                }
                Text(isExpanded ? bubble.text : "…")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(isExpanded && expanded ? nil : 2)
                    .italic()
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 1)
    }

    // MARK: Tool trace — minimal inline chip

    /// `✓ tool_name` when done, `⟳ tool_name` while running. Tap to expand args.
    private var toolTrace: some View {
        let isExpanded = expanded
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                expanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 3) {
                    Image(systemName: bubble.toolRunning ? "arrow.triangle.2.circlepath" : "checkmark")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(bubble.toolRunning ? .orange : .green)
                    Text(bubble.text)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    if bubble.toolRunning {
                        ProgressView()
                            .controlSize(.mini)
                    }
                    Spacer(minLength: 0)
                }
                if isExpanded {
                    if let result = bubble.toolResult, !result.isEmpty {
                        Text(result)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 1)
        .background(Color.orange.opacity(0.06), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

// MARK: - Preview

struct AgentChatView_Previews: PreviewProvider {
    static var previews: some View {
        AgentChatView()
    }
}
