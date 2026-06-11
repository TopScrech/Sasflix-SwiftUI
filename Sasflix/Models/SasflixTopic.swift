import Foundation

nonisolated struct SasflixTopic: Decodable, Identifiable, Sendable {
    let id: Int
    let uuid: String
    let title: String
    let publishedAt: Date
    let watchedAt: Date?
    let cover: SasflixTopicCover?
    let category: SasflixTopicCategory?
    let favoriteAt: Date?
    let access: Bool
    let hasVideo: Bool
    let video: SasflixVideo?
    
    var link: URL? {
        guard !uuid.isEmpty else {
            return nil
        }
        
        return URL(string: "https://sasflix.ru/\(category?.uri ?? "topics")/\(uuid)")
    }
    
    var posterURL: URL? {
        guard let uuid = cover?.uuid else {
            return nil
        }
        
        return URL(string: "https://sasflix.ru/api/image/\(uuid)?w=800&fit=max")
    }
    
    var feedItem: FeedItem? {
        guard let link else {
            return nil
        }
        
        return FeedItem(
            title: title,
            link: link,
            publishedAt: publishedAt,
            posterURL: posterURL,
            author: nil,
            requiresSubscription: hasVideo && !access
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id, uuid, title, cover, category, access, video
        case publishedAt = "published_at"
        case watchedAt = "watched_at"
        case favoriteAt = "favorite_at"
        case hasVideo = "has_video"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = container.decodeFlexibleInt(forKey: .id) ?? 0
        uuid = container.decodeFlexibleString(forKey: .uuid) ?? ""
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        cover = try? container.decodeIfPresent(SasflixTopicCover.self, forKey: .cover)
        category = try? container.decodeIfPresent(SasflixTopicCategory.self, forKey: .category)
        video = try? container.decodeIfPresent(SasflixVideo.self, forKey: .video)
        access = container.decodeFlexibleBool(forKey: .access) ?? false
        hasVideo = container.decodeFlexibleBool(forKey: .hasVideo) ?? (video != nil)
        publishedAt = container.decodeFlexibleString(forKey: .publishedAt)?.sasflixDate ?? .distantPast
        watchedAt = container.decodeFlexibleString(forKey: .watchedAt)?.sasflixDate
        favoriteAt = container.decodeFlexibleString(forKey: .favoriteAt)?.sasflixDate
    }
}
