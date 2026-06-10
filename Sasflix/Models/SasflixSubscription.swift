import Foundation

nonisolated struct SasflixSubscription: Decodable, Equatable, Sendable {
	let id: Int?
	let userID: Int?
	let levelID: Int?
	let nextLevelID: Int?
	let title: String?
	let activeUntil: String?
	let paidUntil: String?
	let cancelled: Bool?
	let fake: Bool?
	let level: SubscriptionLevel?
	let nextLevel: SubscriptionLevel?

	var displayTitle: String {
		if let title, !title.isEmpty {
			return title
		}

		if let title = level?.title, !title.isEmpty {
			return title
		}

		return "Подписка"
	}

	var activeUntilDate: Date? {
		activeUntil?.sasflixDate ?? paidUntil?.sasflixDate
	}

	var nextLevelTitle: String? {
		if let title = nextLevel?.title, !title.isEmpty {
			return title
		}

		return nil
	}

	enum CodingKeys: String, CodingKey {
		case id, title, activeUntil = "active_until", paidUntil = "paid_until", cancelled, fake, level
		case userID = "user_id"
		case levelID = "level_id"
		case nextLevelID = "next_level_id"
		case nextLevel = "next_level"
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		id = container.decodeFlexibleInt(forKey: .id)
		userID = container.decodeFlexibleInt(forKey: .userID)
		levelID = container.decodeFlexibleInt(forKey: .levelID)
		nextLevelID = container.decodeFlexibleInt(forKey: .nextLevelID)
		title = try container.decodeIfPresent(String.self, forKey: .title)
		activeUntil = try container.decodeIfPresent(String.self, forKey: .activeUntil)
		paidUntil = try container.decodeIfPresent(String.self, forKey: .paidUntil)
		cancelled = container.decodeFlexibleBool(forKey: .cancelled)
		fake = container.decodeFlexibleBool(forKey: .fake)
		level = try container.decodeIfPresent(SubscriptionLevel.self, forKey: .level)
		nextLevel = try container.decodeIfPresent(SubscriptionLevel.self, forKey: .nextLevel)
	}
}
