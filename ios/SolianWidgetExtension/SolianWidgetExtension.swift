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
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        case 404:
            return nil
        default:
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

struct CheckInEntry: TimelineEntry {
    let date: Date
    let result: CheckInResult?
    let error: String?
    let isLoading: Bool
    
    static func placeholder() -> CheckInEntry {
        CheckInEntry(date: Date(), result: nil, error: nil, isLoading: true)
    }
}

struct Provider: TimelineProvider {
    private let apiService = CheckInService()
    
    func placeholder(in context: Context) -> CheckInEntry {
        CheckInEntry.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (CheckInEntry) -> ()) {
        Task {
            let result = try? await apiService.fetchCheckInResult()
            let entry = CheckInEntry(date: Date(), result: result, error: nil, isLoading: false)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let currentDate = Date()
            
            do {
                let result = try await apiService.fetchCheckInResult()
                let entry = CheckInEntry(date: currentDate, result: result, error: nil, isLoading: false)
                
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
                
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            } catch {
                let entry = CheckInEntry(date: currentDate, result: nil, error: error.localizedDescription, isLoading: false)
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
            CheckedInView(result: result)
        } else if entry.isLoading {
            LoadingView()
        } else if let error = entry.error {
            ErrorView(error: error)
        } else {
            NotCheckedInView()
        }
    }
    
    private func getLevelName(for level: Int) -> String {
        let key = "checkInResultT\(level)"
        return NSLocalizedString(key, comment: "Check-in result level name")
    }
    
    @ViewBuilder
    private func CheckedInView(result: CheckInResult) -> some View {
        Link(destination: URL(string: "solian://dashboard")!) {
            VStack(alignment: .leading, spacing: isAccessory ? 2 : 8) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.secondary)
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
                        
                        VStack(alignment: .leading, spacing: 1) {
                            if let positiveTip = positiveTips.first {
                                HStack(spacing: 2) {
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
                                HStack(spacing: 2) {
                                    Image(systemName: "hand.thumbsdown.fill")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text(negativeTip.title)
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    } else if family == .systemSmall {
                        let positiveTips = result.tips.filter { $0.isPositive }
                        let negativeTips = result.tips.filter { !$0.isPositive }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let positiveTip = positiveTips.first {
                                HStack(spacing: 4) {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
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
                                        .foregroundColor(.secondary)
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
                                        .foregroundColor(.secondary)
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
                                        .foregroundColor(.secondary)
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
                
                if !isAccessory {
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
    private func NotCheckedInView() -> some View {
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
                    
                    Spacer()
                    
                    WidgetFooter()
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

struct SolianWidgetExtension: Widget {
    let kind: String = "SolianWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CheckInWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
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
    SolianWidgetExtension()
} timeline: {
    CheckInEntry(date: .now, result: nil, error: nil, isLoading: false)
}

#Preview(as: .systemMedium) {
    SolianWidgetExtension()
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
        error: nil,
        isLoading: false
    )
}

#if os(iOS)
#Preview(as: .accessoryRectangular) {
    SolianWidgetExtension()
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
        error: nil,
        isLoading: false
    )
}
#endif
