import Foundation

nonisolated struct DownloadedVideo: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let feedItem: FeedItem
    let localAssetPath: String
    let downloadedAt: Date
    let byteCount: Int64
    let duration: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, feedItem, localAssetPath, downloadedAt, byteCount, duration
        case localFilename
    }
    
    init(
        id: String,
        feedItem: FeedItem,
        localAssetPath: String,
        downloadedAt: Date,
        byteCount: Int64,
        duration: Int?
    ) {
        self.id = id
        self.feedItem = feedItem
        self.localAssetPath = localAssetPath
        self.downloadedAt = downloadedAt
        self.byteCount = byteCount
        self.duration = duration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        feedItem = try container.decode(FeedItem.self, forKey: .feedItem)
        localAssetPath = try container.decodeIfPresent(String.self, forKey: .localAssetPath)
        ?? container.decode(String.self, forKey: .localFilename)
        downloadedAt = try container.decode(Date.self, forKey: .downloadedAt)
        byteCount = try container.decode(Int64.self, forKey: .byteCount)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(feedItem, forKey: .feedItem)
        try container.encode(localAssetPath, forKey: .localAssetPath)
        try container.encode(downloadedAt, forKey: .downloadedAt)
        try container.encode(byteCount, forKey: .byteCount)
        try container.encodeIfPresent(duration, forKey: .duration)
    }
}
