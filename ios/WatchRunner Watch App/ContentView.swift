
//
//  ContentView.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/28.
//

import SwiftUI
import Combine
import WatchConnectivity
import Kingfisher // Import Kingfisher
import KingfisherWebP // Import KingfisherWebP

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
    let title: String?
    let content: String?
    let publisher: SnPublisher
    let attachments: [SnCloudFile]
    let tags: [SnPostTag]
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
    let nick: String?
    let description: String?
    let picture: SnCloudFile?
}

struct SnCloudFile: Codable, Identifiable {
    let id: String
    let mimeType: String?
}

struct SnPostTag: Codable, Identifiable {
    let id: String
    let slug: String
    let name: String?
}

struct SnWebArticle: Codable, Identifiable {
    let id: String
    let title: String
    let url: String
}

// MARK: - Helper Functions

func getAttachmentUrl(for fileId: String, serverUrl: String) -> URL? {
    let urlString: String
    if fileId.starts(with: "http") {
        urlString = fileId
    } else {
        urlString = "\(serverUrl)/drive/files/\(fileId)"
    }
    print("[watchOS] Generated image URL: \(urlString)")
    return URL(string: urlString)
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
    private var isMock = false
    
    init(filter: String, mockActivities: [SnActivity]? = nil) {
        self.filter = filter
        if let mockActivities = mockActivities {
            self.activities = mockActivities
            self.isMock = true
        }
    }

    func fetchActivities(token: String, serverUrl: String) async {
        if isMock { return }
        guard !isLoading else { return }
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

// MARK: - Custom Layouts

struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? 0
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for size in sizes {
            if currentX + size.width > containerWidth {
                // New line
                currentX = 0
                currentY += lineHeight + spacing
                totalHeight = currentY + size.height
                lineHeight = 0
            }

            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        totalHeight = currentY + lineHeight

        return CGSize(width: containerWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let containerWidth = bounds.width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var lineElements: [(offset: Int, size: CGSize)] = []

        func placeLine() {
            let lineWidth = lineElements.map { $0.size.width }.reduce(0, +) + CGFloat(lineElements.count - 1) * spacing
            var startX: CGFloat = 0
            switch alignment {
            case .leading:
                startX = bounds.minX
            case .center:
                startX = bounds.minX + (containerWidth - lineWidth) / 2
            case .trailing:
                startX = bounds.maxX - lineWidth
            default:
                startX = bounds.minX
            }

            var xOffset = startX
            for (offset, size) in lineElements {
                subviews[offset].place(at: CGPoint(x: xOffset, y: bounds.minY + currentY), proposal: ProposedViewSize(size)) // Use bounds.minY + currentY
                xOffset += size.width + spacing
            }
            lineElements.removeAll() // Clear elements for the next line
        }

        for (offset, size) in sizes.enumerated() {
            if currentX + size.width > containerWidth && !lineElements.isEmpty {
                // New line
                placeLine()
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            lineElements.append((offset, size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        placeLine() // Place the last line
    }
}

// MARK: - Image Loader

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var dataTask: URLSessionDataTask?
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func loadImage(from initialUrl: URL, token: String) async {
        isLoading = true
        errorMessage = nil
        image = nil

        do {
            // First request with Authorization header
            var request = URLRequest(url: initialUrl)
            request.setValue("AtField \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("SolianWatch/1.0", forHTTPHeaderField: "User-Agent")

            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 302, let redirectLocation = httpResponse.allHeaderFields["Location"] as? String, let redirectUrl = URL(string: redirectLocation) {
                    print("[watchOS] Redirecting to: \(redirectUrl)")
                    // Second request to the redirected URL (S3 signed URL) without Authorization header
                    let (redirectData, _) = try await session.data(from: redirectUrl)
                    if let uiImage = UIImage(data: redirectData) {
                        self.image = Image(uiImage: uiImage)
                    } else {
                        // Try KingfisherWebP for WebP
                        let processor = WebPProcessor.default // Correct usage
                        if let kfImage = processor.process(item: .data(redirectData), options: KingfisherParsedOptionsInfo(
                            [
                                .processor(processor),
                                .loadDiskFileSynchronously,
                                .cacheOriginalImage
                            ]
                        )) {
                            self.image = Image(uiImage: kfImage)
                        } else {
                            self.errorMessage = "Invalid image data from redirect (could not decode with KingfisherWebP)."
                        }
                    }
                } else if httpResponse.statusCode == 200 {
                    if let uiImage = UIImage(data: data) {
                        self.image = Image(uiImage: uiImage)
                    } else {
                        // Try KingfisherWebP for WebP
                        let processor = WebPProcessor.default // Correct usage
                        if let kfImage = processor.process(item: .data(data), options: KingfisherParsedOptionsInfo(
                            [
                                .processor(processor),
                                .loadDiskFileSynchronously,
                                .cacheOriginalImage
                            ]
                        )) {
                            self.image = Image(uiImage: kfImage)
                        } else {
                            self.errorMessage = "Invalid image data (could not decode with KingfisherWebP)."
                        }
                    }
                } else {
                    self.errorMessage = "HTTP Status Code: \(httpResponse.statusCode)"
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("[watchOS] Image loading failed: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func cancel() {
        dataTask?.cancel()
    }
}

// MARK: - Views

struct ActivityListView: View {
    @StateObject private var viewModel: ActivityViewModel
    @EnvironmentObject var appState: AppState

    init(filter: String, mockActivities: [SnActivity]? = nil) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(filter: filter, mockActivities: mockActivities))
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
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostRowView(post: post)
                            }
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
            // Only fetch if appState is ready and token/serverUrl are available
            if appState.isReady, let token = appState.token, let serverUrl = appState.serverUrl {
                await viewModel.fetchActivities(token: token, serverUrl: serverUrl)
            }
        }
        .navigationTitle(viewModel.filter)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostRowView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader() // Instantiate ImageLoader

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let serverUrl = appState.serverUrl, let pictureId = post.publisher.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                    if imageLoader.isLoading {
                        ProgressView()
                            .frame(width: 24, height: 24)
                    } else if let image = imageLoader.image {
                        image
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                    } else if let errorMessage = imageLoader.errorMessage {
                        Text("Failed: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                    } else {
                        // Placeholder if no image and not loading
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }
                }
                Text(post.publisher.nick ?? post.publisher.name)
                    .font(.subheadline)
                    .bold()
            }
            .task(id: post.publisher.picture?.id) { // Use task(id:) to reload image when pictureId changes
                if let serverUrl = appState.serverUrl, let pictureId = post.publisher.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                    await imageLoader.loadImage(from: imageUrl, token: token)
                }
            }
            
            if let title = post.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
            }
            
            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(.body)
            }
        }
    }
}

struct PostDetailView: View {
    let post: SnPost
    @EnvironmentObject var appState: AppState
    @StateObject private var publisherImageLoader = ImageLoader() // Instantiate ImageLoader for publisher avatar

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let serverUrl = appState.serverUrl, let pictureId = post.publisher.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                        if publisherImageLoader.isLoading {
                            ProgressView()
                                .frame(width: 32, height: 32)
                        } else if let image = publisherImageLoader.image {
                            image
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        } else if let errorMessage = publisherImageLoader.errorMessage {
                            Text("Failed: \(errorMessage)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(width: 32, height: 32)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                    }
                    Text("@\(post.publisher.name)")
                        .font(.headline)
                }
                .task(id: post.publisher.picture?.id) { // Use task(id:) to reload image when pictureId changes
                    if let serverUrl = appState.serverUrl, let pictureId = post.publisher.picture?.id, let imageUrl = getAttachmentUrl(for: pictureId, serverUrl: serverUrl), let token = appState.token {
                        await publisherImageLoader.loadImage(from: imageUrl, token: token)
                    }
                }
                
                if let title = post.title, !title.isEmpty {
                    Text(title)
                        .font(.title2)
                        .bold()
                }
                
                if let content = post.content, !content.isEmpty {
                    Text(content)
                        .font(.body)
                }
                
                if !post.attachments.isEmpty {
                    Divider()
                    Text("Attachments").font(.headline)
                    ForEach(post.attachments) { attachment in
                        AttachmentImageView(attachment: attachment)
                    }
                }
                
                if !post.tags.isEmpty {
                    Divider()
                    Text("Tags").font(.headline)
                    FlowLayout(alignment: .leading, spacing: 4) {
                        ForEach(post.tags) { tag in
                            Text("#\(tag.name ?? tag.slug)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.accentColor.opacity(0.2)))
                                .cornerRadius(5)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Post")
    }
}

struct AttachmentImageView: View {
    let attachment: SnCloudFile
    @EnvironmentObject var appState: AppState
    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        Group {
            if imageLoader.isLoading {
                ProgressView()
            } else if let image = imageLoader.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } else if let errorMessage = imageLoader.errorMessage {
                Text("Failed to load attachment: \(errorMessage)")
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("File: \(attachment.id)")
            }
        }
        .task(id: attachment.id) {
            if let serverUrl = appState.serverUrl, let imageUrl = getAttachmentUrl(for: attachment.id, serverUrl: serverUrl), let token = appState.token, attachment.mimeType?.starts(with: "image") == true {
                await imageLoader.loadImage(from: imageUrl, token: token)
            }
        }
    }
}

struct DiscoveryView: View {
    let discoveryData: DiscoveryData

    var body: some View {
        NavigationLink(destination: DiscoveryDetailView(discoveryData: discoveryData)) {
            VStack(alignment: .leading) {
                Text("Discovery")
                    .font(.headline)
                Text("\(discoveryData.items.count) new items to discover")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DiscoveryDetailView: View {
    let discoveryData: DiscoveryData

    var body: some View {
        List(discoveryData.items) { item in
            NavigationLink(destination: destinationView(for: item)) {
                itemView(for: item)
            }
        }
        .navigationTitle("Discovery")
    }

    @ViewBuilder
    private func itemView(for item: DiscoveryItem) -> some View {
        VStack(alignment: .leading) {
            switch item.data {
            case .realm(let realm):
                Text("Realm").font(.headline)
                Text(realm.name).foregroundColor(.secondary)
            case .publisher(let publisher):
                Text("Publisher").font(.headline)
                Text(publisher.name).foregroundColor(.secondary)
            case .article(let article):
                Text("Article").font(.headline)
                Text(article.title).foregroundColor(.secondary)
            case .unknown:
                Text("Unknown item")
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for item: DiscoveryItem) -> some View {
        switch item.data {
        case .realm(let realm):
            RealmDetailView(realm: realm)
        case .publisher(let publisher):
            PublisherDetailView(publisher: publisher)
        case .article(let article):
            ArticleDetailView(article: article)
        case .unknown:
            Text("Detail view not available")
        }
    }
}

struct RealmDetailView: View {
    let realm: SnRealm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(realm.name).font(.headline)
            if let description = realm.description {
                Text(description).font(.body)
            }
        }
        .navigationTitle("Realm")
    }
}

struct PublisherDetailView: View {
    let publisher: SnPublisher
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(publisher.name).font(.headline)
            if let description = publisher.description {
                Text(description).font(.body)
            }
        }
        .navigationTitle("Publisher")
    }
}

struct ArticleDetailView: View {
    let article: SnWebArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title).font(.headline)
            Text(article.url).font(.caption).foregroundColor(.secondary)
        }
        .navigationTitle("Article")
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

#if DEBUG
extension SnActivity {
    static var mock: [SnActivity] {
        let mockPublisher = SnPublisher(id: "pub1", name: "Mock Publisher", nick: "mock_nick", description: "A publisher for testing", picture: SnCloudFile(id: "mock_avatar_id", mimeType: "image/png"))
        let mockTag1 = SnPostTag(id: "tag1", slug: "swiftui", name: "SwiftUI")
        let mockTag2 = SnPostTag(id: "tag2", slug: "watchos", name: "watchOS")
        let mockAttachment1 = SnCloudFile(id: "mock_image_id_1", mimeType: "image/jpeg")
        let mockAttachment2 = SnCloudFile(id: "mock_image_id_2", mimeType: "image/png")

        let post1 = SnPost(id: "1", title: "Hello from a Mock Post!", content: "This is a mock post content. It can be a bit longer to see how it wraps.", publisher: mockPublisher, attachments: [mockAttachment1, mockAttachment2], tags: [mockTag1, mockTag2])
        let activity1 = SnActivity(id: "1", type: "posts.new", data: .post(post1), createdAt: Date())
        
        let realm1 = SnRealm(id: "r1", name: "SwiftUI Previews", description: "A place for designing in previews.")
        let publisher1 = SnPublisher(id: "p1", name: "The Mock Times", nick: "mock_times", description: "All the news that's fit to mock.", picture: nil)
        let article1 = SnWebArticle(id: "a1", title: "The Art of Mocking Data", url: "https://example.com")

        let discoveryItem1 = DiscoveryItem(type: "realm", data: .realm(realm1))
        let discoveryItem2 = DiscoveryItem(type: "publisher", data: .publisher(publisher1))
        let discoveryItem3 = DiscoveryItem(type: "article", data: .article(article1))
        let discoveryData = DiscoveryData(items: [discoveryItem1, discoveryItem2, discoveryItem3])
        let activity2 = SnActivity(id: "2", type: "discovery", data: .discovery(discoveryData), createdAt: Date())
        
        return [activity1, activity2]
    }
}
#endif

#Preview {
    NavigationStack {
        ActivityListView(filter: "Preview", mockActivities: SnActivity.mock)
            .environmentObject(AppState())
    }
}
