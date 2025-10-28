//
//  ContentView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/28.
//

import SwiftUI
import Combine
import WatchConnectivity

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var token: String? = nil
    @Published var serverUrl: String? = nil
    @Published var isReady = false
    
    private var wcService = WatchConnectivityService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        wcService.$token.combineLatest(wcService.$serverUrl)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] token, serverUrl in
                self?.token = token
                self?.serverUrl = serverUrl
                if token != nil && serverUrl != nil {
                    self?.isReady = true
                }
            }
            .store(in: &cancellables)
    }
    
    func requestData() {
        wcService.requestDataFromPhone()
    }
}

// MARK: - Watch Connectivity

class WatchConnectivityService: NSObject, WCSessionDelegate, ObservableObject {
    @Published var token: String?
    @Published var serverUrl: String?

    private let session: WCSession

    override init() {
        self.session = .default
        super.init()
        print("[watchOS] Activating WCSession")
        self.session.delegate = self
        self.session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("[watchOS] WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("[watchOS] WCSession activated with state: \(activationState.rawValue)")
        if activationState == .activated {
            requestDataFromPhone()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[watchOS] Received message: \(message)")
        DispatchQueue.main.async {
            if let token = message["token"] as? String {
                self.token = token
            }
            if let serverUrl = message["serverUrl"] as? String {
                self.serverUrl = serverUrl
            }
        }
    }

    func requestDataFromPhone() {
        guard session.isReachable else {
            print("[watchOS] Phone is not reachable")
            return
        }
        
        print("[watchOS] Requesting data from phone")
        session.sendMessage(["request": "data"]) { [weak self] response in
            print("[watchOS] Received reply: \(response)")
            DispatchQueue.main.async {
                if let token = response["token"] as? String {
                    self?.token = token
                }
                if let serverUrl = response["serverUrl"] as? String {
                    self?.serverUrl = serverUrl
                }
            }
        } errorHandler: { error in
            print("[watchOS] sendMessage failed with error: \(error.localizedDescription)")
        }
    }
}


// MARK: - Models

struct AppToken: Codable {
    let token: String
}

struct SnActivity: Codable, Identifiable {
    let id: String
    let type: String
    let data: ActivityData?
    let createdAt: Date
}

enum ActivityData: Codable {
    case post(SnPost)
    case discovery(DiscoveryData)
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let post = try? container.decode(SnPost.self) {
            self = .post(post)
            return
        }
        if let discoveryData = try? container.decode(DiscoveryData.self) {
            self = .discovery(discoveryData)
            return
        }
        self = .unknown
    }

    func encode(to encoder: Encoder) throws {
        // Not needed for decoding
    }
}

struct SnPost: Codable, Identifiable {
    let id: String
    let content: String?
    let title: String?
}

struct DiscoveryData: Codable {
    let items: [DiscoveryItem]
}

struct DiscoveryItem: Codable, Identifiable {
    var id = UUID()
    let type: String
    let data: DiscoveryItemData

    enum CodingKeys: String, CodingKey {
        case type, data
    }
}

enum DiscoveryItemData: Codable {
    case realm(SnRealm)
    case publisher(SnPublisher)
    case article(SnWebArticle)
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let realm = try? container.decode(SnRealm.self) {
            self = .realm(realm)
            return
        }
        if let publisher = try? container.decode(SnPublisher.self) {
            self = .publisher(publisher)
            return
        }
        if let article = try? container.decode(SnWebArticle.self) {
            self = .article(article)
            return
        }
        self = .unknown
    }
    
    func encode(to encoder: Encoder) throws {
        // Not needed for decoding
    }
}

struct SnRealm: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
}

struct SnPublisher: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
}

struct SnWebArticle: Codable, Identifiable {
    let id: String
    let title: String
    let url: String
}


// MARK: - Network Service

class NetworkService {
    private let session = URLSession.shared

    func fetchActivities(filter: String, cursor: String? = nil, token: String, serverUrl: String) async throws -> [SnActivity] {
        guard let baseURL = URL(string: serverUrl) else { 
            throw URLError(.badURL)
        }
        var components = URLComponents(url: baseURL.appendingPathComponent("/sphere/activities"), resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem(name: "take", value: "20")]
        if filter.lowercased() != "explore" {
            queryItems.append(URLQueryItem(name: "filter", value: filter.lowercased()))
        }
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await session.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([SnActivity].self, from: data)
    }
}

// MARK: - View Models

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var activities: [SnActivity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkService = NetworkService()
    let filter: String

    init(filter: String) {
        self.filter = filter
    }

    func fetchActivities(appState: AppState) async {
        guard !isLoading, appState.isReady, let token = appState.token, let serverUrl = appState.serverUrl else { return }
        isLoading = true
        errorMessage = nil

        do {
            let fetchedActivities = try await networkService.fetchActivities(filter: filter, token: token, serverUrl: serverUrl)
            self.activities = fetchedActivities
        } catch {
            self.errorMessage = error.localizedDescription
            print("[watchOS] fetchActivities failed with error: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Views

struct ActivityListView: View {
    @StateObject private var viewModel: ActivityViewModel
    @EnvironmentObject var appState: AppState

    init(filter: String) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(filter: filter))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error fetching data")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .lineLimit(nil)
                }
                .padding()
            } else if viewModel.activities.isEmpty {
                Text("No activities found.")
            } else {
                List(viewModel.activities) { activity in
                    switch activity.type {
                    case "posts.new", "posts.new.replies":
                        if case .post(let post) = activity.data {
                            PostRowView(post: post)
                        }
                    case "discovery":
                         if case .discovery(let discoveryData) = activity.data {
                             DiscoveryView(discoveryData: discoveryData)
                         }
                    default:
                        Text("Unknown activity type: \(activity.type)")
                    }
                }
            }
        }
        .task {
            await viewModel.fetchActivities(appState: appState)
        }
        .navigationTitle(viewModel.filter)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostRowView: View {
    let post: SnPost

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(post.title ?? "Post")
                .font(.headline)
            if let content = post.content {
                Text(content)
                    .font(.body)
            }
        }
    }
}

struct DiscoveryView: View {
    let discoveryData: DiscoveryData

    var body: some View {
        VStack(alignment: .leading) {
            Text("Discovery")
                .font(.headline)
                .padding(.bottom, 2)
            ForEach(discoveryData.items) { item in
                switch item.data {
                case .realm(let realm):
                    Text("Realm: \(realm.name)")
                case .publisher(let publisher):
                    Text("Publisher: \(publisher.name)")
                case .article(let article):
                    Text("Article: \(article.title)")
                case .unknown:
                    Text("Unknown discovery item")
                }
            }
        }
    }
}


// The main view with the TabView for filtering.
struct ExploreView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            if appState.isReady {
                TabView {
                    NavigationStack {
                        ActivityListView(filter: "Explore")
                    }
                    .tabItem {
                        Label("Explore", systemImage: "safari")
                    }

                    NavigationStack {
                        ActivityListView(filter: "Subscriptions")
                    }
                    .tabItem {
                        Label("Subscriptions", systemImage: "star")
                    }

                    NavigationStack {
                        ActivityListView(filter: "Friends")
                    }
                    .tabItem {
                        Label("Friends", systemImage: "person.2")
                    }
                }
                .environmentObject(appState)
            } else {
                ProgressView { Text("Connecting to phone...") }
                .onAppear {
                    appState.requestData()
                }
            }
        }
    }
}

// The root view of the app.
struct ContentView: View {
    var body: some View {
        ExploreView()
    }
}

#Preview {
    ContentView()
}