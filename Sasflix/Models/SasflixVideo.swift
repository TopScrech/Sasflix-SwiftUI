import Foundation

nonisolated struct SasflixVideo: Decodable, Hashable, Sendable {
    let id: String
    let duration: Int?
    let time: Double?
    let updatedAt: Date?
    
    var streamURL: URL? {
        URL(string: "https://sasflix.ru/api/video/\(id)")
    }

    var compatibilityStreamURL: URL? {
        streamURL?.appending(path: "240")
    }
    
    var posterURL: URL? {
        URL(string: "https://sasflix.ru/api/poster/\(id)/800")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, duration, time
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = container.decodeFlexibleString(forKey: .id) ?? ""
        duration = container.decodeFlexibleInt(forKey: .duration)
        time = container.decodeFlexibleDouble(forKey: .time)
        updatedAt = container.decodeFlexibleString(forKey: .updatedAt)?.sasflixDate
    }
}
