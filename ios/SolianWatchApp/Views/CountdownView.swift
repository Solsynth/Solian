//
//  CountdownView.swift
//  Solian Watch App
//
//  Created by LittleSheep on 2026/09/12.
//

import SwiftUI
import Combine

/// Upcoming event countdowns on the watch. Mirrors the main app's dashboard
/// countdown line (`ClockCard`): the next user events and notable days with a
/// live remaining-time readout. Rows are glanceable; tapping one opens a sheet
/// with the event's description, time, and location.
@MainActor
final class CountdownViewModel: ObservableObject {
    @Published private(set) var items: [SnEventCountdownItem] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let networkService = NetworkService()
    private var hasLoaded = false

    /// Loads the upcoming countdowns once on appear.
    func load(token: String, serverUrl: String) async {
        guard !hasLoaded, !isLoading else { return }
        hasLoaded = true
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            items = try await networkService.fetchEventCountdowns(token: token, serverUrl: serverUrl)
        } catch {
            errorMessage = error.localizedDescription
            print("[watchOS] fetchEventCountdowns failed with error: \(error)")
        }
    }

    /// Silent re-poll while the panel is open: countdowns end and new ones
    /// appear. Failures keep the current list (non-fatal, like the main app's
    /// minute-interval provider invalidation).
    func refresh(token: String, serverUrl: String) async {
        guard !isLoading else { return }
        do {
            items = try await networkService.fetchEventCountdowns(token: token, serverUrl: serverUrl)
            errorMessage = nil
        } catch {
            print("[watchOS] refreshEventCountdowns failed with error: \(error)")
        }
    }

    /// A user-visible retry re-fetches state (in case a prior failure was cached).
    func reload(token: String, serverUrl: String) async {
        hasLoaded = false
        await load(token: token, serverUrl: serverUrl)
    }
}

struct CountdownView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = CountdownViewModel()
    @State private var selectedItem: SnEventCountdownItem?

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView()
                    .padding(.top, 40)
            } else if let error = viewModel.errorMessage, viewModel.items.isEmpty {
                VStack(spacing: 8) {
                    Text(L10n.countdownCouldntLoad)
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button(L10n.countdownRetry) {
                        guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
                        Task { await viewModel.reload(token: token, serverUrl: serverUrl) }
                    }
                    .font(.caption)
                }
                .padding()
            } else if viewModel.items.isEmpty {
                CountdownEmptyState()
            } else {
                List(viewModel.items) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        CountdownRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(L10n.countdownTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItem) { item in
            CountdownDetailSheet(item: item)
        }
        .task {
            guard let token = appState.token, let serverUrl = appState.serverUrl else { return }
            await viewModel.load(token: token, serverUrl: serverUrl)
            // Keep the list current while the panel is on screen. Cancels
            // automatically when the view disappears.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                guard !Task.isCancelled else { return }
                await viewModel.refresh(token: token, serverUrl: serverUrl)
            }
        }
    }
}

/// SF Symbol for a countdown's event type, mirroring the main app's
/// `Symbols.event` (user events) vs `Symbols.celebration` (notable days).
private func countdownIconName(eventType: Int) -> String {
    switch eventType {
    case SnEventCountdownType.userEvent:
        return "calendar"
    case SnEventCountdownType.notableDay:
        return "party.popper.fill"
    default:
        return "sparkles"
    }
}

private struct CountdownEmptyState: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "hourglass")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            Text(L10n.countdownEmpty)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(L10n.countdownEmptyHint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

/// One countdown row: event icon, title, and the live remaining-time readout
/// underneath. The readout ticks via `TimelineView` (once a minute — enough
/// for a days/hours countdown) and flips to accent "now" the moment the event
/// starts, without waiting for a refetch.
private struct CountdownRow: View {
    let item: SnEventCountdownItem

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let happening = item.isHappeningNow(at: context.date)
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(happening ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.12))
                        .frame(width: 30, height: 30)
                    Image(systemName: countdownIconName(eventType: item.eventType))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(happening ? Color.accentColor : Color.secondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(item.countdownText(at: context.date))
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundStyle(happening ? Color.accentColor : Color.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
        }
    }
}

/// Full details for one countdown, presented from a row tap: what's coming,
/// when, and where. The time is rendered in the watch's current locale.
private struct CountdownDetailSheet: View {
    let item: SnEventCountdownItem

    @Environment(\.dismiss) private var dismiss

    private var scheduleText: String {
        item.isAllDay
            ? item.startTime.formatted(date: .abbreviated, time: .omitted)
            : item.startTime.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if let description = item.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    Label(scheduleText, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let location = item.location, !location.isEmpty {
                        Label(location, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L10n.checkInDone)
                    }
                }
            }
        }
    }
}

private extension SnEventCountdownItem {
    /// Mirrors the dashboard's `isOngoing` badge, but recomputed locally so a
    /// countdown flips to "now" the moment it starts without a refetch.
    func isHappeningNow(at date: Date) -> Bool {
        isOngoing || (startTime <= date && date < endTime)
    }

    /// Compact remaining-time readout, mirroring the main app's short
    /// countdown keys (`{}d`/`{}h`/…).
    func countdownText(at date: Date) -> String {
        guard date < startTime else { return L10n.countdownNow }
        let seconds = Int(startTime.timeIntervalSince(date))
        let days = seconds / 86_400
        let hours = (seconds % 86_400) / 3_600
        if days > 0 {
            return L10n.countdownDaysHours(days: days, hours: hours)
        }
        let minutes = (seconds % 3_600) / 60
        if hours > 0 {
            return L10n.countdownHoursMinutes(hours: hours, minutes: minutes)
        }
        if minutes > 0 {
            return L10n.countdownMinutesSeconds(minutes: minutes, seconds: seconds % 60)
        }
        return L10n.countdownSeconds(seconds % 60)
    }
}

#Preview {
    NavigationStack {
        CountdownView()
            .environmentObject(AppState())
    }
}
