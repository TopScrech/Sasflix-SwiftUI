nonisolated struct BlogPostsResponse: Decodable, Sendable {
    let rows: [BlogPost]
    let total: Int
}
