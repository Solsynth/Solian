//
//  SolianWidgetExtension.swift
//  SolianWidgetExtension
//
//  Created by LittleSheep on 2026/1/3.
//

import AppIntents
import WidgetKit
import SwiftUI

struct CheckInTip: Codable {
    let isPositive: Bool
    let title: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case isPositive = "is_positive"
        case title
        case content
    }
}

struct CheckInResult: Codable {
    let id: String
    let level: Int
    let tips: [CheckInTip]
    let fortuneReport: CheckInFortuneReport?
    let accountId: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case level
        case tips
        case fortuneReport = "fortune_report"
        case accountId = "account_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    var createdDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: createdAt) {
            return date
        }

        // Fallback for timestamps without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: createdAt)
    }
}

struct CheckInFortuneReport: Codable {
    let version: Int
    let poem: String
    let summary: String
    let summaryDetail: String?
    let wish: String
    let love: String
    let study: String
    let career: String
    let health: String
    let lostItem: String
    let luckyColor: String
    let luckyDirection: String
    let luckyTime: String
    let luckyItem: String
    let luckyAction: String
    let avoidAction: String
    let ritual: String

    enum CodingKeys: String, CodingKey {
        case version, poem, summary, wish, love, study, career, health, ritual
        case summaryDetail = "summary_detail"
        case lostItem = "lost_item"
        case luckyColor = "lucky_color"
        case luckyDirection = "lucky_direction"
        case luckyTime = "lucky_time"
        case luckyItem = "lucky_item"
        case luckyAction = "lucky_action"
        case avoidAction = "avoid_action"
    }
}

struct NotableDay: Codable {
    let date: String
    let localName: String
    let globalName: String
    let countryCode: String?
    let localizableKey: String?
    let holidays: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case date
        case startDate = "start_date"
        case localName = "local_name"
        case globalName = "global_name"
        case name
        case countryCode = "country_code"
        case localizableKey = "localizable_key"
        case holidays
    }

    init(
        date: String,
        localName: String,
        globalName: String,
        countryCode: String?,
        localizableKey: String?,
        holidays: [Int]?
    ) {
        self.date = date
        self.localName = localName
        self.globalName = globalName
        self.countryCode = countryCode
        self.localizableKey = localizableKey
        self.holidays = holidays
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawDate = try container.decodeIfPresent(String.self, forKey: .date)
            ?? container.decodeIfPresent(String.self, forKey: .startDate)
            ?? ""
        let rawGlobal = try container.decodeIfPresent(String.self, forKey: .globalName)
            ?? container.decodeIfPresent(String.self, forKey: .name)
            ?? ""
        let rawLocal = try container.decodeIfPresent(String.self, forKey: .localName)
            ?? rawGlobal

        self.date = Self.projectedDateString(from: rawDate)
        self.localName = rawLocal.isEmpty ? rawGlobal : rawLocal
        self.globalName = rawGlobal
        self.countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        self.localizableKey = try container.decodeIfPresent(String.self, forKey: .localizableKey)
        self.holidays = try container.decodeIfPresent([Int].self, forKey: .holidays)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(localName, forKey: .localName)
        try container.encode(globalName, forKey: .globalName)
        try container.encodeIfPresent(countryCode, forKey: .countryCode)
        try container.encodeIfPresent(localizableKey, forKey: .localizableKey)
        try container.encodeIfPresent(holidays, forKey: .holidays)
    }

    private static func parseISO8601(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }

    private static func projectedDateString(from rawDate: String) -> String {
        guard let parsed = parseISO8601(rawDate) else { return rawDate }
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let parsedYear = calendar.component(.year, from: parsed)
        if parsedYear == currentYear {
            return rawDate
        }
        var components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: parsed)
        components.year = currentYear
        guard let projected = calendar.date(from: components) else { return rawDate }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: projected)
    }
    
    var notableDate: Date? {
        Self.parseISO8601(date)
    }
    
    var isToday: Bool {
        guard let notableDate = notableDate else { return false }
        let calendar = Calendar.current
        return calendar.isDateInToday(notableDate)
    }
}

struct NotableDaysResponse: Codable {
    let notableDays: [NotableDay]?

    enum CodingKeys: String, CodingKey {
        case notableDays = "notable_days"
    }
}

class CheckInService {
    private let networkService = WidgetNetworkService()
    
    func fetchCheckInResult() async throws -> CheckInResult? {
        return try await networkService.makeRequest(path: "/stargate/accounts/me/check-in?version=2")
    }

    func claimCheckIn() async throws -> CheckInResult? {
        return try await networkService.makeRequest(
            path: "/stargate/accounts/me/check-in?version=2",
            method: "POST"
        )
    }
}

@available(iOS 17.0, *)
struct ClaimCheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Claim Daily Check-In"
    static var description = IntentDescription("Claim today's Solar Network check-in directly from the widget.")

    func perform() async throws -> some IntentResult {
        _ = try await CheckInService().claimCheckIn()
        WidgetCenter.shared.reloadTimelines(ofKind: "SolianCheckInWidget")
        return .result()
    }
}

class NotableDayService {
    private let networkService = WidgetNetworkService()
    
    func fetchRecentNotableDay() async throws -> NotableDay? {
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let path = "/stargate/notable-days?region=CN&year=\(year)&take=50"

        let days: [NotableDay]
        if let wrapped: NotableDaysResponse = try await networkService.makeRequest(path: path),
           let list = wrapped.notableDays {
            days = list
        } else if let direct: [NotableDay] = try? await networkService.makeRequest(path: path) {
            days = direct
        } else {
            return nil
        }

        let startOfToday = Calendar.current.startOfDay(for: now)
        return days
            .compactMap { day -> (NotableDay, Date)? in
                guard let date = day.notableDate, date >= startOfToday else { return nil }
                return (day, date)
            }
            .sorted { $0.1 < $1.1 }
            .first?
            .0
    }
}

struct CheckInEntry: TimelineEntry {
    let date: Date
    let result: CheckInResult?
    let notableDay: NotableDay?
    let error: String?
    let isLoading: Bool
    
    static func placeholder() -> CheckInEntry {
        CheckInEntry(date: Date(), result: nil, notableDay: nil, error: nil, isLoading: true)
    }
}

struct Provider: TimelineProvider {
    private let apiService = CheckInService()
    
    func placeholder(in context: Context) -> CheckInEntry {
        CheckInEntry.placeholder()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CheckInEntry) -> ()) {
        Task {
            print("[WidgetKit] [Provider] Getting snapshot...")
            async let checkInResult = apiService.fetchCheckInResult()
            async let notableDay = NotableDayService().fetchRecentNotableDay()
            
            let result = try? await checkInResult
            let day = try? await notableDay
            
            print("[WidgetKit] [Provider] Snapshot - CheckIn: \(result != nil ? "Found" : "Not found"), NotableDay: \(day != nil ? "Found" : "Not found")")
            
            let entry = CheckInEntry(date: Date(), result: result, notableDay: day, error: nil, isLoading: false)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let currentDate = Date()
            print("[WidgetKit] [Provider] Getting timeline at \(currentDate)...")
            
            do {
                async let checkInResult = try await apiService.fetchCheckInResult()
                async let notableDay = try await NotableDayService().fetchRecentNotableDay()
                
                let result = try await checkInResult
                let day = try await notableDay
                
                print("[WidgetKit] [Provider] Timeline - CheckIn: \(result != nil ? "Found" : "Not found"), NotableDay: \(day != nil ? "Found" : "Not found")")
                
                let entry = CheckInEntry(date: currentDate, result: result, notableDay: day, error: nil, isLoading: false)
                
                let nextUpdateDate: Date
                if let result = result, let createdDate = result.createdDate {
                    let calendar = Calendar.current
                    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: createdDate) {
                        nextUpdateDate = min(tomorrow, calendar.date(byAdding: .hour, value: 1, to: currentDate)!)
                    } else {
                        nextUpdateDate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
                    }
                } else {
                    nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
                }
                
                print("[WidgetKit] [Provider] Next update at: \(nextUpdateDate)")
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            } catch {
                print("[WidgetKit] [Provider] Error in getTimeline: \(error.localizedDescription)")
                let entry = CheckInEntry(date: currentDate, result: nil, notableDay: nil, error: error.localizedDescription, isLoading: false)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }
}

struct CheckInWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let result = entry.result {
            CheckedInView(result: result, notableDay: entry.notableDay)
        } else if entry.isLoading {
            LoadingView()
        } else if let error = entry.error {
            ErrorView(error: error)
        } else {
            NotCheckedInView(notableDay: entry.notableDay)
        }
    }
    
    private func getLevelName(for level: Int) -> String {
        let key = "checkInResultT\(level)"
        return NSLocalizedString(key, comment: "Check-in result level name")
    }
    
    @ViewBuilder
    private func NotableDayView(notableDay: NotableDay) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if !notableDay.isToday {
                Text(NSLocalizedString("notableDayUpcoming", comment: "Upcoming"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: isAccessory ? 8 : 6) {
                Image(systemName: "sparkles")
                    .foregroundColor(.orange)
                    .font(isAccessory ? .caption : .subheadline)
                
                VStack(alignment: .leading, spacing: 2) {
                    if notableDay.isToday {
                        Text(String(format: NSLocalizedString("notableDayToday", comment: "{name} is today!"), notableDay.localName))
                            .font(isAccessory ? .caption : .footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    } else {
                        if let notableDate = notableDay.notableDate {
                            let dateString = isCompact ? formatDateCompact(notableDate) : formatDateRegular(notableDate)
                            Text(String(format: NSLocalizedString("notableDayIs", comment: "{date} is {name}"), dateString, notableDay.localName))
                                .font(isAccessory ? .caption : .footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                        } else {
                            Text(notableDay.localName)
                                .font(isAccessory ? .caption : .footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                        }
                    }
                }
                
                Spacer()
            }
            
            if notableDay.isToday && !isAccessory {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text(NSLocalizedString("today", comment: "Today"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var isCompact: Bool {
        family == .systemSmall || isAccessory
    }
    
    private func formatDateCompact(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
    
    private func formatDateRegular(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    @ViewBuilder
    private func CheckedInView(result: CheckInResult, notableDay: NotableDay?) -> some View {
        Link(destination: URL(string: "solian://dashboard")!) {
            VStack(alignment: .leading, spacing: isAccessory ? 2 : 8) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(isAccessory ? .caption : .title3)
                    Text(getLevelName(for: result.level))
                        .font(isAccessory ? .caption2 : .headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                if !result.tips.isEmpty {
                    if isAccessory {
                        let positiveTips = result.tips.filter { $0.isPositive }
                        let negativeTips = result.tips.filter { !$0.isPositive }
                        
                        HStack(spacing: 2) {
                            if let positiveTip = positiveTips.first {
                                HStack(spacing: 8) {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text(positiveTip.title)
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                            }
                            if let negativeTip = negativeTips.first {
                                HStack(spacing: 8) {
                                    Image(systemName: "hand.thumbsdown.fill")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text(negativeTip.title)
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                        }
                    } else if family == .systemSmall {
                        let positiveTips = result.tips.filter { $0.isPositive }
                        let negativeTips = result.tips.filter { !$0.isPositive }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let positiveTip = positiveTips.first {
                                HStack(spacing: 4) {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .font(.caption)
                                        .foregroundColor(.green.opacity(0.8))
                                    Text(positiveTip.title)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                            if let negativeTip = negativeTips.first {
                                HStack(spacing: 4) {
                                    Image(systemName: "hand.thumbsdown.fill")
                                        .font(.caption)
                                        .foregroundColor(.red.opacity(0.8))
                                    Text(negativeTip.title)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                    } else {
                        let positiveTips = result.tips.filter { $0.isPositive }
                        let negativeTips = result.tips.filter { !$0.isPositive }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if !positiveTips.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .font(.caption)
                                        .foregroundColor(.green.opacity(0.8))
                                    ForEach(Array(positiveTips.prefix(3)), id: \.title) { tip in
                                        Text(tip.title)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                        if tip.title != positiveTips.last?.title {
                                            Text("•")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            
                            if !negativeTips.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "hand.thumbsdown.fill")
                                        .font(.caption)
                                        .foregroundColor(.red.opacity(0.8))
                                    ForEach(Array(negativeTips.prefix(3)), id: \.title) { tip in
                                        Text(tip.title)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                        if tip.title != negativeTips.last?.title {
                                            Text("•")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                } else if let summary = result.fortuneReport?.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else if !isAccessory && family != .systemSmall {
                    Text("No fortune today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let notableDay = notableDay {
                    NotableDayView(notableDay: notableDay)
                }
                
                if family == .systemLarge {
                    Spacer()
                    WidgetFooter()
                    
                }
            }
            .padding(isAccessory ? 0 : (family == .systemSmall ? 6 : 12))
        }
    }
    
    @ViewBuilder
    private func WidgetFooter() -> some View {
        HStack {
            Text("Solian")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var isAccessory: Bool {
        if #available(iOS 16.0, *) {
            if case .accessoryRectangular = family {
                return true
            }
        }
        return false
    }
    
    @ViewBuilder
    private func NotCheckedInView(notableDay: NotableDay?) -> some View {
        VStack(alignment: .leading, spacing: isAccessory ? 2 : 8) {
            Link(destination: URL(string: "solian://dashboard")!) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(isAccessory ? .caption : .title3)
                    Text(NSLocalizedString("checkIn", comment: "Check In"))
                        .font(isAccessory ? .caption2 : .headline)
                        .fontWeight(.bold)
                    Spacer()
                }
            }

            if !isAccessory {
                if #available(iOS 17.0, *) {
                    Button(intent: ClaimCheckInIntent()) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text(NSLocalizedString("checkIn", comment: "Check In"))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.18))
                        .foregroundColor(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                } else {
                    Link(destination: URL(string: "solian://dashboard")!) {
                        Text(NSLocalizedString("tapToCheckIn", comment: "Tap to check in today"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if let notableDay = notableDay {
                    NotableDayView(notableDay: notableDay)
                }

                Spacer()

                WidgetFooter()
            } else if let notableDay = notableDay {
                NotableDayView(notableDay: notableDay)
            }
        }
        .padding(isAccessory ? 0 : (family == .systemSmall ? 6 : 12))
    }
    
    @ViewBuilder
    private func LoadingView() -> some View {
        VStack(alignment: .leading, spacing: isAccessory ? 2 : 8) {
            HStack(spacing: 4) {
                ProgressView()
                    .scaleEffect(isAccessory ? 0.6 : 0.8)
                Text(NSLocalizedString("loading", comment: "Loading..."))
                    .font(isAccessory ? .caption2 : .caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            if !isAccessory {
                Spacer()
                WidgetFooter()
            }
        }
        .padding(isAccessory ? 0 : 12)
    }
    
    @ViewBuilder
    private func ErrorView(error: String) -> some View {
        Link(destination: URL(string: "solian://dashboard")!) {
            VStack(alignment: .leading, spacing: isAccessory ? 2 : 8) {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.secondary)
                        .font(isAccessory ? .caption : .title3)
                    Text(NSLocalizedString("error", comment: "Error"))
                        .font(isAccessory ? .caption2 : .headline)
                    Spacer()
                }
                
                if !isAccessory {
                    Text(NSLocalizedString("openAppToRefresh", comment: "Open app to refresh"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    WidgetFooter()
                }
            }
            .padding(isAccessory ? 0 : (family == .systemSmall ? 6 : 12))
        }
    }
}

struct CheckInWidgetRootView: View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ZStack {
                CheckInWidgetEntryView(entry: entry)

                if entry.result != nil || entry.notableDay != nil {
                    GeometryReader { geometry in
                        Image(colorScheme == .dark ? "CloudyLambDark" : "CloudyLamb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: geometry.size.width * 0.9,
                                height: geometry.size.width * 0.9
                            )
                            .opacity(0.18)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white,
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .position(
                                x: geometry.size.width * 0.9,
                                y: 20
                            )
                    }
                    .allowsHitTesting(false)
                }
            }
            .containerBackground(.fill.tertiary, for: .widget)
            .padding(.vertical, 8)
        } else {
            CheckInWidgetEntryView(entry: entry)
                .padding()
                .background()
        }
    }
}

struct SolianCheckInWidget: Widget {
    let kind: String = "SolianCheckInWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CheckInWidgetRootView(entry: entry)
        }
        .configurationDisplayName("Check In")
        .description("View your daily check-in status")
        .supportedFamilies(supportedFamilies)
    }
    
    private var supportedFamilies: [WidgetFamily] {
#if os(iOS)
        return [.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular]
#else
        return [.systemSmall, .systemMedium, .systemLarge]
#endif
    }
}

#Preview(as: .systemSmall) {
    SolianCheckInWidget()
} timeline: {
    CheckInEntry(date: .now, result: nil, notableDay: nil, error: nil, isLoading: false)
}

#Preview(as: .systemMedium) {
    SolianCheckInWidget()
} timeline: {
    CheckInEntry(
        date: .now,
        result: CheckInResult(
            id: "test-id",
            level: 2,
            tips: [
                CheckInTip(isPositive: true, title: "Good Luck", content: "Great day"),
                CheckInTip(isPositive: true, title: "Creative", content: "Inspiration"),
                CheckInTip(isPositive: false, title: "Shopping", content: "Expensive")
            ],
            fortuneReport: nil,
            accountId: "account-id",
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            deletedAt: nil
        ),
        notableDay: NotableDay(
            date: ISO8601DateFormatter().string(from: Calendar.current.date(byAdding: .day, value: 5, to: Date())!),
            localName: "Christmas",
            globalName: "Christmas",
            countryCode: nil,
            localizableKey: nil,
            holidays: []
        ),
        error: nil,
        isLoading: false
    )
}

#if os(iOS)
#Preview(as: .accessoryRectangular) {
    SolianCheckInWidget()
} timeline: {
    CheckInEntry(
        date: .now,
        result: CheckInResult(
            id: "test-id",
            level: 4,
            tips: [
                CheckInTip(isPositive: true, title: "Lucky", content: "Great fortune"),
                CheckInTip(isPositive: true, title: "Success", content: "Opportunity")
            ],
            fortuneReport: nil,
            accountId: "account-id",
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            deletedAt: nil
        ),
        notableDay: NotableDay(
            date: ISO8601DateFormatter().string(from: Date()),
            localName: "New Year",
            globalName: "New Year",
            countryCode: nil,
            localizableKey: nil,
            holidays: []
        ),
        error: nil,
        isLoading: false
    )
}
#endif
