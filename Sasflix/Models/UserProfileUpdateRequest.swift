nonisolated struct UserProfileUpdateRequest: Encodable, Sendable {
    let id: Int
    let username: String
    let fullname: String
    let email: String?
}
