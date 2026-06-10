import Foundation

nonisolated struct FeedItem: Identifiable, Hashable, Codable, Sendable {
	let id: URL
	let title: String
	let link: URL
	let publishedAt: Date
	let posterURL: URL?
	let author: String?

	var category: FeedCategory {
		FeedCategory(url: link)
	}

	var topicUUID: String? {
		let uuid = link.lastPathComponent
		return uuid.isEmpty ? nil : uuid
	}

	init(title: String, link: URL, publishedAt: Date, posterURL: URL?, author: String?) {
		self.id = link
		self.title = title
		self.link = link
		self.publishedAt = publishedAt
		self.posterURL = posterURL
		self.author = author
	}
}
