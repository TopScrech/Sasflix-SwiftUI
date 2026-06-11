nonisolated struct UserProfileUpdateRequest: Encodable, Sendable {
    let id: Int
    let username: String
    let fullname: String
    let email: String?
    let notifyEmail: Bool?
    let notifyWeb: Bool?
    let notifyApp: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, username, fullname, email
        case notifyEmail = "notify"
        case notifyWeb = "notify_web"
        case notifyApp = "notify_app"
    }
}
