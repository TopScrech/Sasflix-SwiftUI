import Foundation

nonisolated struct PaymentHistoryItem: Decodable, Equatable, Identifiable, Sendable {
	let id: String
	let createdAt: String?
	let type: String?
	let amount: Double?
	let service: String?
	let paid: Bool?
	let paidAt: String?
	let metadata: PaymentHistoryMetadata?
	let topic: PaymentHistoryTopic?

	var createdDate: Date? {
		createdAt?.sasflixDate
	}

	var paidDate: Date? {
		paidAt?.sasflixDate
	}

	var displayTitle: String {
		if let title = topic?.title, !title.isEmpty {
			return title
		}

		if let title = metadata?.title, !title.isEmpty {
			return title
		}

		if type == "subscription" {
			return "Подписка"
		}

		return "Платёж"
	}

	enum CodingKeys: String, CodingKey {
		case id, type, amount, service, paid, metadata, topic
		case createdAt = "created_at"
		case paidAt = "paid_at"
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		guard let id = container.decodeFlexibleString(forKey: .id) else {
			throw DecodingError.keyNotFound(
				CodingKeys.id,
				DecodingError.Context(codingPath: container.codingPath, debugDescription: "Payment id is missing")
			)
		}

		self.id = id
		createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
		type = try container.decodeIfPresent(String.self, forKey: .type)
		amount = container.decodeFlexibleDouble(forKey: .amount)
		service = try container.decodeIfPresent(String.self, forKey: .service)
		paid = container.decodeFlexibleBool(forKey: .paid)
		paidAt = try container.decodeIfPresent(String.self, forKey: .paidAt)
		metadata = try? container.decodeIfPresent(PaymentHistoryMetadata.self, forKey: .metadata)
		topic = try? container.decodeIfPresent(PaymentHistoryTopic.self, forKey: .topic)
	}
}
