//
//  SolianWidgetExtension.swift
//  SolianWidgetExtension
//
//  Created by LittleSheep on 2026/1/3.
//

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

struct CheckInAccount: Codable {
    let id: String
    let nick: String?
    let profile: CheckInProfile?
}

struct CheckInProfile: Codable {
    let picture: String?
}

struct CheckInResult: Codable {
    let id: String
    let level: Int
    let rewardPoints: Int
    let rewardExperience: Int
    let tips: [CheckInTip]
    let accountId: String
    let account: CheckInAccount?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case level
        case rewardPoints = "reward_points"
        case rewardExperience = "reward_experience"
        case tips
        case accountId = "account_id"
        case account
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    var createdDate: Date? {
        ISO8601DateFormatter().date(from: createdAt)
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
        case localName = "local_name"
        case globalName = "global_name"
        case countryCode = "country_code"
        case localizableKey = "localizable_key"
        case holidays
    }
    
    var notableDate: Date? {
        ISO8601DateFormatter().date(from: date)
    }
    
    var isToday: Bool {
        guard let notableDate = notableDate else { return false }
        let calendar = Calendar.current
        return calendar.isDateInToday(notableDate)
    }
}

enum RemoteError: Error {
    case missingCredentials
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
}

extension RemoteError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Please open the app to sign in."
        case .invalidURL:
            return "Invalid server configuration."
        case .invalidResponse:
            return "Server returned an invalid response."
        case .httpError(let code):
            return "Server error (\(code))."
        case .decodingError:
            return "Failed to read server data."
        }
    }
}

struct TokenData: Codable {
    let token: String
}

class WidgetNetworkService {
    private let appGroup = "group.solsynth.solian"
    private let tokenKey = "flutter.dyn_user_tk"
    private let urlKey = "flutter.app_server_url"
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }
    
    var token: String? {
        guard let tokenString = userDefaults?.string(forKey: tokenKey) else {
            return nil
        }
        
        guard let data = tokenString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let tokenData = try JSONDecoder().decode(TokenData.self, from: data)
            return tokenData.token
        } catch {
            print("[WidgetKit] Failed to decode token: \(error)")
            return nil
        }
    }
    
    var baseURL: String {
        return userDefaults?.string(forKey: urlKey) ?? "https://api.solian.app"
    }
    
    func makeRequest<T: Codable>(
        path: String,
        method: String = "GET",
        headers: [String: String] = [:]
    ) async throws -> T? {
        guard let token = token else {
            throw RemoteError.missingCredentials
        }
        
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw RemoteError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.timeoutInterval = 10.0
        
        print("[WidgetKit] [Network] Requesting: \(baseURL)\(path)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteError.invalidResponse
        }
        
        print("[WidgetKit] [Network] Status: \(httpResponse.statusCode), Data length: \(data.count)")
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("[WidgetKit] [Network] Response: \(jsonString.prefix(500))")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(T.self, from: data)
                print("[WidgetKit] [Network] Successfully decoded response")
                return result
            } catch {
                print("[WidgetKit] [Network] Decoding error: \(error.localizedDescription)")
                print("[WidgetKit] [Network] Expected type: \(String(describing: T.self))")
                throw RemoteError.decodingError
            }
        case 404:
            print("[WidgetKit] [Network] Resource not found (404)")
            return nil
        default:
            print("[WidgetKit] [Network] HTTP Error: \(httpResponse.statusCode)")
            throw RemoteError.httpError(httpResponse.statusCode)
        }
    }
}

class CheckInService {
    private let networkService = WidgetNetworkService()
    
    func fetchCheckInResult() async throws -> CheckInResult? {
        return try await networkService.makeRequest(path: "/pass/accounts/me/check-in")
    }
}

class NotableDayService {
    private let networkService = WidgetNetworkService()
    
    func fetchRecentNotableDay() async throws -> NotableDay? {
        print("[WidgetKit] [NotableDayService] Fetching recent notable day...")
        do {
            let result: [NotableDay]? = try await networkService.makeRequest(path: "/pass/notable/me/recent")
            print("[WidgetKit] [NotableDayService] Result: \(String(describing: result))")
            
            guard let result = result else {
                print("[WidgetKit] [NotableDayService] Result is nil")
                return nil
            }
            
            print("[WidgetKit] [NotableDayService] Result count: \(result.count)")
            
            guard result.isEmpty == false else {
                print("[WidgetKit] [NotableDayService] No notable days found")
                return nil
            }
            
            let firstDay = result.first!
            print("[WidgetKit] [NotableDayService] First notable day: \(firstDay.localName), date: \(firstDay.date)")
            
            return firstDay
        } catch let decodingError as DecodingError {
            print("[WidgetKit] [NotableDayService] Decoding error, trying as single object...")
            print("[WidgetKit] [NotableDayService] Error: \(decodingError.localizedDescription)")
            
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("[WidgetKit] [NotableDayService] Type mismatch: expected \(type), context: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("[WidgetKit] [NotableDayService] Value not found: type \(type), context: \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("[WidgetKit] [NotableDayService] Key not found: \(key), context: \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("[WidgetKit] [NotableDayService] Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("[WidgetKit] [NotableDayService] Unknown decoding error")
            }
            
            do {
                let singleResult: NotableDay? = try await networkService.makeRequest(path: "/pass/notable/me/recent")
                print("[WidgetKit] [NotableDayService] Single object decode succeeded: \(singleResult?.localName ?? "nil")")
                return singleResult
            } catch {
                print("[WidgetKit] [NotableDayService] Single object decode also failed: \(error.localizedDescription)")
                throw decodingError
            }
        } catch {
            print("[WidgetKit] [NotableDayService] Error fetching notable day: \(error.localizedDescription)")
            print("[WidgetKit] [NotableDayService] Error type: \(type(of: error))")
            throw error
        }
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
            async let checkInResult = try? await apiService.fetchCheckInResult()
            async let notableDay = try? await NotableDayService().fetchRecentNotableDay()
            
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
        Link(destination: URL(string: "solian://dashboard")!) {
            VStack(alignment: .leading, spacing: isAccessory ? 2 : 8) {
                HStack(spacing: 4) {
                    Image(systemName: "flame")
                        .foregroundColor(.secondary)
                        .font(isAccessory ? .caption : .title3)
                    Text(NSLocalizedString("checkIn", comment: "Check In"))
                        .font(isAccessory ? .caption2 : .headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                if !isAccessory {
                    Text(NSLocalizedString("tapToCheckIn", comment: "Tap to check in today"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
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

struct SolianCheckInWidget: Widget {
    let kind: String = "SolianCheckInWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CheckInWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .padding(.vertical, 8)
            } else {
                CheckInWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
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
            rewardPoints: 10,
            rewardExperience: 100,
            tips: [
                CheckInTip(isPositive: true, title: "Good Luck", content: "Great day"),
                CheckInTip(isPositive: true, title: "Creative", content: "Inspiration"),
                CheckInTip(isPositive: false, title: "Shopping", content: "Expensive")
            ],
            accountId: "account-id",
            account: nil,
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
            rewardPoints: 50,
            rewardExperience: 500,
            tips: [
                CheckInTip(isPositive: true, title: "Lucky", content: "Great fortune"),
                CheckInTip(isPositive: true, title: "Success", content: "Opportunity")
            ],
            accountId: "account-id",
            account: nil,
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
