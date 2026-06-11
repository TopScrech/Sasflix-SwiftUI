nonisolated struct TopUserRole: Decodable, Hashable, Sendable {
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case title
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = container.decodeFlexibleString(forKey: .title) ?? ""
    }
}
