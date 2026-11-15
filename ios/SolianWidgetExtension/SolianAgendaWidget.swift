//
//  SolianAgendaWidget.swift
//  SolianWidgetExtension
//

import Foundation
import SwiftUI
import WidgetKit

struct AgendaCalendarResponse: Codable {
    let mergedEvents: [AgendaEvent]?
    let userEvents: [AgendaEvent]?

    enum CodingKeys: String, CodingKey {
        case mergedEvents = "merged_events"
        case userEvents = "user_events"
    }
}

struct AgendaEvent: Codable, Identifiable {
    let id: String
    let title: String?
    let type: Int?
    let startTime: String?
    let endTime: String?
    let isAllDay: Bool?
    let location: String?

    enum CodingKeys: String, CodingKey {
        case id, title, type, location
        case startTime = "start_time"
        case endTime = "end_time"
        case isAllDay = "is_all_day"
    }

    var startDate: Date? {
        guard let startTime else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: startTime) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: startTime)
    }

    var displayTitle: String {
        let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "Event" : trimmed
    }
}

struct AgendaEntry: TimelineEntry {
    let date: Date
    let events: [AgendaEvent]
    let notableDay: NotableDay?
    let error: String?
}

final class AgendaService {
    private let networkService = WidgetNetworkService()

    func fetchUpcomingEvents(limit: Int = 5) async throws -> [AgendaEvent] {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)

        let path = "/stargate/accounts/me/calendar/merged?year=\(year)&month=\(month)"
        guard let response: AgendaCalendarResponse = try await networkService.makeRequest(path: path) else {
            return []
        }

        let rawEvents = (response.mergedEvents?.isEmpty == false ? response.mergedEvents : response.userEvents) ?? []
        let startOfToday = calendar.startOfDay(for: now)

        return rawEvents
            .compactMap { event -> (AgendaEvent, Date)? in
                guard let startDate = event.startDate, startDate >= startOfToday else { return nil }
                return (event, startDate)
            }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map(\.0)
    }
}

struct AgendaProvider: TimelineProvider {
    private let agendaService = AgendaService()
    private let notableService = NotableDayService()

    func placeholder(in context: Context) -> AgendaEntry {
        AgendaEntry(date: Date(), events: [], notableDay: nil, error: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (AgendaEntry) -> Void) {
        Task {
            async let events = agendaService.fetchUpcomingEvents(limit: 4)
            async let notable = notableService.fetchRecentNotableDay()

            let entry = AgendaEntry(
                date: Date(),
                events: (try? await events) ?? [],
                notableDay: try? await notable,
                error: nil
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AgendaEntry>) -> Void) {
        Task {
            let now = Date()
            do {
                async let events = agendaService.fetchUpcomingEvents(limit: 5)
                async let notable = notableService.fetchRecentNotableDay()

                let entry = AgendaEntry(
                    date: now,
                    events: try await events,
                    notableDay: try? await notable,
                    error: nil
                )
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: now)!
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            } catch {
                let entry = AgendaEntry(
                    date: now,
                    events: [],
                    notableDay: nil,
                    error: error.localizedDescription
                )
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: now)!
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            }
        }
    }
}

struct AgendaWidgetEntryView: View {
    let entry: AgendaEntry
    @Environment(\.widgetFamily) private var family

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }

    var body: some View {
        Link(destination: URL(string: "solian://dashboard")!) {
            if let error = entry.error {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Agenda", systemImage: "calendar")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else if family == .accessoryRectangular {
                accessoryView
            } else {
                standardView
            }
        }
    }

    private var accessoryView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let first = entry.events.first {
                Text(first.displayTitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                if let date = first.startDate {
                    Text(first.isAllDay == true ? dayFormatter.string(from: date) : "\(dayFormatter.string(from: date)) \(timeFormatter.string(from: date))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if let notable = entry.notableDay {
                Text(notable.localName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                if let date = notable.notableDate {
                    Text(dayFormatter.string(from: date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No upcoming events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var standardView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.tint)
                Text("Agenda")
                    .font(.headline)
                Spacer()
                if let notable = entry.notableDay {
                    Text(notable.localName)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                }
            }

            if entry.events.isEmpty {
                Spacer()
                Text("No upcoming events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                let maxRows = family == .systemLarge ? 5 : 2
                ForEach(entry.events.prefix(maxRows)) { event in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor)
                            .frame(width: 3, height: 24)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(event.displayTitle)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            if let date = event.startDate {
                                Text(event.isAllDay == true ? "\(dayFormatter.string(from: date)) • All day" : "\(dayFormatter.string(from: date)) • \(timeFormatter.string(from: date))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(12)
    }
}

struct SolianAgendaWidget: Widget {
    let kind = "SolianAgendaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AgendaProvider()) { entry in
            if #available(iOS 17.0, *) {
                AgendaWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AgendaWidgetEntryView(entry: entry)
                    .background()
            }
        }
        .configurationDisplayName("Upcoming Events")
        .description("View upcoming calendar events and notable days.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
#if os(iOS)
        return [.systemMedium, .systemLarge, .accessoryRectangular]
#else
        return [.systemMedium, .systemLarge]
#endif
    }
}
