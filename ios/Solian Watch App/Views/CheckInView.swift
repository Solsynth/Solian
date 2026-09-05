//
//  CheckInView.swift
//  Solian Watch App
//
//  Created by LittleSheep on 2026/09/06.
//

import SwiftUI
import Combine

/// Today's check-in on the watch. Mirrors the main app's `CheckInScreen` but
/// watch-scaled: a prompt to check in, and on success a fortune card showing
/// the level color, the poem/summary, and a compact "today's fortunes"
/// breakdown. The full 16-field report is deliberately reduced to what a watch
/// can glance at.
@MainActor
final class CheckInViewModel: ObservableObject {
    @Published private(set) var result: SnCheckInResult?
    @Published private(set) var fortune: SnFortuneSaying?
    @Published private(set) var isLoading = false
    @Published private(set) var isCheckingIn = false
    @Published var errorMessage: String?

    private let networkService = NetworkService()
    private var hasLoaded = false

    /// Loads today's check-in state (and the daily fortune) once on appear.
    func load(token: String, serverUrl: String) async {
        guard !hasLoaded, !isLoading else { return }
        hasLoaded = true
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            result = try await networkService.fetchCheckInResult(token: token, serverUrl: serverUrl)
        } catch {
            errorMessage = error.localizedDescription
        }

        // Daily fortune is advisory; failure is non-fatal.
        if let saying = try? await networkService.fetchDailyFortune(token: token, serverUrl: serverUrl) {
            fortune = saying
        }
    }

    /// Performs the daily check-in.
    func checkIn(token: String, serverUrl: String) async {
        guard !isCheckingIn else { return }
        isCheckingIn = true
        errorMessage = nil
        defer { isCheckingIn = false }

        do {
            result = try await networkService.checkIn(token: token, serverUrl: serverUrl)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// A user-visible retry re-fetches state (in case a prior 404 was cached).
    func reload(token: String, serverUrl: String) async {
        hasLoaded = false
        await load(token: token, serverUrl: serverUrl)
    }
}

struct CheckInView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = CheckInViewModel()

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else if let error = viewModel.errorMessage, viewModel.result == nil {
                VStack(spacing: 8) {
                    Text("Couldn't load check-in")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
                        Task { await viewModel.reload(token: token, serverUrl: serverUrl) }
                    }
                    .font(.caption)
                }
                .padding()
            } else if let result = viewModel.result {
                CheckInResultCard(
                    result: result,
                    fortune: viewModel.fortune
                )
                .padding(.horizontal)
            } else {
                CheckInPromptCard(viewModel: viewModel)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Check In")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
            Task { await viewModel.load(token: token, serverUrl: serverUrl) }
        }
    }
}

/// The "not checked in yet" prompt: a single glanceable action.
private struct CheckInPromptCard: View {
    @ObservedObject var viewModel: CheckInViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 34))
                .foregroundColor(Color.accentColor)
            Text("Check in today")
                .font(sizeCategory < .extraExtraLarge ? .headline : .title3)
                .multilineTextAlignment(.center)
            Text(descriptionText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
                Task { await viewModel.checkIn(token: token, serverUrl: serverUrl) }
            } label: {
                if viewModel.isCheckingIn {
                    ProgressView()
                } else {
                    Text("Check In")
                        .fontWeight(.semibold)
                }
            }
            .disabled(viewModel.isCheckingIn)
            .buttonStyle(.borderedProminent)
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }

    private var descriptionText: String {
        "Return daily for a poem and today's fortunes."
    }
}

/// The post-check-in fortune card. The level color carries the day's "rank".
private struct CheckInResultCard: View {
    let result: SnCheckInResult
    let fortune: SnFortuneSaying?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Level + date
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Level \(result.level)")
                        .font(.headline)
                        .foregroundColor(levelColor)
                    // The rank name — checks the same quality/fortune scale the
                    // main app uses (level 4 = "Best Luck" 大吉, level 0 =
                    // "Worst Luck" 大凶). English, matching the watch UI.
                    Text(result.levelName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                Text("Checked in \(result.createdAt, format: .dateTime.month(.abbreviated).day())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Poem (the signature moment)
            if let report = result.fortuneReport, !report.poem.isEmpty {
                Text(report.poem)
                    .font(.body)
                    .italic()
                    .foregroundStyle(.primary)
                    .lineSpacing(3)

                if !report.summary.isEmpty {
                    Text(report.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Divider()
            }

            // Today's fortunes — the glanceable essentials.
            if let report = result.fortuneReport {
                FortuneGrid(report: report)
            }

            // Daily fortune saying (advisory).
            if let fortune = fortune, !fortune.content.isEmpty {
                Divider()
                Text(fortune.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            // Tips
            if !result.tips.isEmpty {
                Divider()
                ForEach(result.tips) { tip in
                    TipRow(tip: tip)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var levelColor: Color {
        switch result.level {
        case 4: return Color(red: 0.784, green: 0.231, blue: 0.216) // #C83B37
        case 3: return Color(red: 0.722, green: 0.529, blue: 0.102) // #B8871A
        case 2: return Color(red: 0.267, green: 0.482, blue: 0.784) // #447BC8
        case 1: return Color(red: 0.373, green: 0.345, blue: 0.565) // #5F5890
        case 0: return Color(red: 0.412, green: 0.286, blue: 0.424) // #69496C
        case 5: return Color(red: 0.784, green: 0.369, blue: 0.455) // #C85E74
        default: return .accentColor
        }
    }
}

/// Compact two-column grid of the day's key fortunes.
private struct FortuneGrid: View {
    let report: SnCheckInFortuneReport

    private struct Item {
        let icon: String
        let label: String
        let value: String
    }

    private var items: [Item] {
        [
            Item(icon: "heart.fill", label: "Love", value: report.love),
            Item(icon: "book.fill", label: "Study", value: report.study),
            Item(icon: "briefcase.fill", label: "Work", value: report.career),
            Item(icon: "heart.circle.fill", label: "Health", value: report.health),
        ].filter { !$0.value.isEmpty }
    }

    var body: some View {
        if !items.isEmpty {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 8
            ) {
                ForEach(items, id: \.label) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Label(item.label, systemImage: item.icon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(item.value)
                            .font(.caption)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.gray.opacity(0.10), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }
}

private struct TipRow: View {
    let tip: SnFortuneTip

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: tip.isPositive ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                    .font(.system(size: 11))
                    .foregroundColor(tip.isPositive ? Color.accentColor : Color.red)
                Text(tip.title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            if !tip.content.isEmpty {
                Text(tip.content)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        CheckInView()
            .environmentObject(AppState())
    }
}
