import Foundation

nonisolated struct TopUser: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let fullname: String
    let rating: Int
    let commentsCount: Int
    let role: TopUserRole?
    let avatar: TopUserAvatar?
    
    var displayName: String {
        fullname.isEmpty ? "Пользователь Sasflix" : fullname
    }
    
    enum CodingKeys: String, CodingKey {
        case id, fullname, rating, role, avatar
        case commentsCount = "comments_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = container.decodeFlexibleInt(forKey: .id) ?? 0
        fullname = container.decodeFlexibleString(forKey: .fullname) ?? ""
        rating = container.decodeFlexibleInt(forKey: .rating) ?? 0
        commentsCount = container.decodeFlexibleInt(forKey: .commentsCount) ?? 0
        role = try? container.decodeIfPresent(TopUserRole.self, forKey: .role)
        avatar = try? container.decodeIfPresent(TopUserAvatar.self, forKey: .avatar)
    }
}
