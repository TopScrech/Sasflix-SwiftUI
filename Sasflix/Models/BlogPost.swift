import Foundation

nonisolated struct BlogPost: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let uuid: String
    let title: String
    let content: String
    let publishedAt: Date?
    let commentsCount: Int
    let active: Bool
    let hidden: Bool
    let files: [BlogPostFile]
    
    var imageURL: URL? {
        files
            .sorted { ($0.rank ?? .max) < ($1.rank ?? .max) }
            .compactMap(\.imageURL)
            .first
    }
    
    var link: URL? {
        guard !uuid.isEmpty else {
            return nil
        }
        
        return URL(string: "https://sasflix.ru/blog/\(uuid)")
    }
    
    var preview: String {
        let text = content
            .replacing(#/\[file\d+\]/#, with: "")
            .replacing(#/!\[[^\]]*\]\([^)]+\)/#, with: "")
            .replacing(#/\[([^\]]+)\]\([^)]+\)/#, with: "$1")
            .replacing(#/[*_`>#-]/#, with: "")
            .replacing("\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return text.isEmpty ? "Без описания" : text
    }
    
    enum CodingKeys: String, CodingKey {
        case id, uuid, title, body, active, hidden, files
        case publishedAt = "published_at"
        case commentsCount = "comments_count"
    }
    
    enum BodyCodingKeys: String, CodingKey {
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = container.decodeFlexibleInt(forKey: .id) ?? 0
        uuid = container.decodeFlexibleString(forKey: .uuid) ?? ""
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        publishedAt = container.decodeFlexibleString(forKey: .publishedAt)?.sasflixDate
        commentsCount = container.decodeFlexibleInt(forKey: .commentsCount) ?? 0
        active = container.decodeFlexibleBool(forKey: .active) ?? false
        hidden = container.decodeFlexibleBool(forKey: .hidden) ?? false
        files = (try? container.decode([BlogPostFile].self, forKey: .files)) ?? []
        
        if let body = try? container.nestedContainer(keyedBy: BodyCodingKeys.self, forKey: .body) {
            content = (try? body.decode(String.self, forKey: .content)) ?? ""
        } else {
            content = ""
        }
    }
}
