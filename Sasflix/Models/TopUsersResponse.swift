nonisolated struct TopUsersResponse: Decodable, Sendable {
    let rows: [TopUser]
    let total: Int
}
