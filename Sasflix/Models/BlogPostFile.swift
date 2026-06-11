import Foundation

nonisolated struct BlogPostFile: Decodable, Hashable, Sendable {
    let uuid: String
    let type: String?
    let mime: String?
    let rank: Int?
    
    var imageURL: URL? {
        guard !uuid.isEmpty, isImage else {
            return nil
        }
        
        return URL(string: "https://sasflix.ru/api/image/\(uuid)?w=800&fit=max")
    }
    
    var isImage: Bool {
        if type == "image" {
            return true
        }
        
        return mime?.hasPrefix("image/") == true
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid, type, mime, rank
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        uuid = container.decodeFlexibleString(forKey: .uuid) ?? ""
        type = container.decodeFlexibleString(forKey: .type)
        mime = container.decodeFlexibleString(forKey: .mime)
        rank = container.decodeFlexibleInt(forKey: .rank)
    }
}
