import Foundation

nonisolated struct SasflixTopicCover: Decodable, Sendable {
    let id: Int?
    let uuid: String?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, uuid
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = container.decodeFlexibleInt(forKey: .id)
        uuid = container.decodeFlexibleString(forKey: .uuid)
        updatedAt = container.decodeFlexibleString(forKey: .updatedAt)?.sasflixDate
    }
}
