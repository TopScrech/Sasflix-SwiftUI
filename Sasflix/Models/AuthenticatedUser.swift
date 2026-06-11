import Foundation

nonisolated struct AuthenticatedUser: Decodable, Equatable, Identifiable, Sendable {
    let id: Int
    let username: String?
    let fullname: String?
    let email: String?
    let subscription: SasflixSubscription?
    
    var displayName: String {
        if let fullname, !fullname.isEmpty {
            return fullname
        }
        
        if let username, !username.isEmpty {
            return username
        }
        
        if let email, !email.isEmpty {
            return email
        }
        
        return "Аккаунт Sasflix"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, fullname, email, subscription
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        fullname = try container.decodeIfPresent(String.self, forKey: .fullname)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        subscription = try? container.decodeIfPresent(SasflixSubscription.self, forKey: .subscription)
    }
}
