import Foundation

nonisolated struct SasflixTopicCategory: Decodable, Sendable {
	let id: Int?
	let title: String?
	let uri: String?

	enum CodingKeys: String, CodingKey {
		case id, title, uri
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		id = container.decodeFlexibleInt(forKey: .id)
		title = container.decodeFlexibleString(forKey: .title)
		uri = container.decodeFlexibleString(forKey: .uri)
	}
}
