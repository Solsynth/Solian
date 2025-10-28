//
//  MockData.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import Foundation

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
