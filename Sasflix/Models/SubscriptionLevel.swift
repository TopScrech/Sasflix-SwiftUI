import Foundation

nonisolated struct SubscriptionLevel: Decodable, Equatable, Sendable {
	let id: Int?
	let title: String?
	let color: String?
	let price: Double?
	let content: String?

	enum CodingKeys: String, CodingKey {
		case id, title, color, price, content
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		id = container.decodeFlexibleInt(forKey: .id)
		title = try container.decodeIfPresent(String.self, forKey: .title)
		color = try container.decodeIfPresent(String.self, forKey: .color)
		price = container.decodeFlexibleDouble(forKey: .price)
		content = try container.decodeIfPresent(String.self, forKey: .content)
	}
}
