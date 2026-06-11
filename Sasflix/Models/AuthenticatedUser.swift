import Foundation

nonisolated struct AuthenticatedUser: Decodable, Equatable, Identifiable, Sendable {
    let id: Int
    let username: String?
    let fullname: String?
    let email: String?
    let notifyEmail: Bool?
    let notifyWeb: Bool?
    let notifyApp: Bool?
    let canReadBlog: Bool
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
        case notifyEmail = "notify_email"
        case notifyWeb = "notify_web"
        case notifyApp = "notify_app"
        case notify
        case canReadBlog = "blog"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        fullname = try container.decodeIfPresent(String.self, forKey: .fullname)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        notifyEmail = container.decodeFlexibleBool(forKey: .notify) ?? container.decodeFlexibleBool(forKey: .notifyEmail)
        notifyWeb = container.decodeFlexibleBool(forKey: .notifyWeb)
        notifyApp = container.decodeFlexibleBool(forKey: .notifyApp)
        canReadBlog = container.decodeFlexibleBool(forKey: .canReadBlog) ?? false
        subscription = try? container.decodeIfPresent(SasflixSubscription.self, forKey: .subscription)
    }
}
