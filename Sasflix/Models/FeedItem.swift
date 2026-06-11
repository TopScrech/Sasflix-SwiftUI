import Foundation

nonisolated struct FeedItem: Identifiable, Hashable, Codable, Sendable {
    let id: URL
    let title: String
    let link: URL
    let publishedAt: Date
    let posterURL: URL?
    let author: String?
    let requiresSubscription: Bool
    
    var category: FeedCategory {
        FeedCategory(url: link)
    }
    
    var topicUUID: String? {
        let uuid = link.lastPathComponent
        return uuid.isEmpty ? nil : uuid
    }
    
    enum CodingKeys: String, CodingKey {
        case title, link, publishedAt, posterURL, author, requiresSubscription
    }
    
    init(title: String, link: URL, publishedAt: Date, posterURL: URL?, author: String?, requiresSubscription: Bool = false) {
        self.id = link
        self.title = title
        self.link = link
        self.publishedAt = publishedAt
        self.posterURL = posterURL
        self.author = author
        self.requiresSubscription = requiresSubscription
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        link = try container.decode(URL.self, forKey: .link)
        id = link
        publishedAt = try container.decode(Date.self, forKey: .publishedAt)
        posterURL = try container.decodeIfPresent(URL.self, forKey: .posterURL)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        requiresSubscription = try container.decodeIfPresent(Bool.self, forKey: .requiresSubscription) ?? false
    }
}
