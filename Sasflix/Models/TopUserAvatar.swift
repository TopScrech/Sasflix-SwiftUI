import Foundation

nonisolated struct TopUserAvatar: Decodable, Hashable, Sendable {
    let uuid: String
    let updatedAt: String?
    
    var imageURL: URL? {
        guard !uuid.isEmpty else {
            return nil
        }
        
        var queryItems = [URLQueryItem(name: "fm", value: "webp")]
        
        if let updatedAt {
            let timestamp = updatedAt.replacing(#/\D/#, with: "")
            
            if !timestamp.isEmpty {
                queryItems.append(URLQueryItem(name: "t", value: timestamp))
            }
        }
        
        return URL(string: "https://sasflix.ru/api/image/\(uuid)")?
            .appending(queryItems: queryItems)
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        uuid = container.decodeFlexibleString(forKey: .uuid) ?? ""
        updatedAt = container.decodeFlexibleString(forKey: .updatedAt)
    }
}
