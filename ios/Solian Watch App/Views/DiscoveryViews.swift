//
//  DiscoveryViews.swift
//  WatchRunner Watch App
//
//  Created by LittleSheep on 2025/10/29.
//

import SwiftUI

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
