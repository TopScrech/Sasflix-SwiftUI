import Foundation

struct RSSFeedService: Sendable {
	let feedURL: URL

	init(feedURL: URL = URL(string: "https://sasflix.ru/rss.xml")!) {
		self.feedURL = feedURL
	}

	func fetchItems() async throws -> [FeedItem] {
		let (data, response) = try await URLSession.shared.data(from: feedURL)

		guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
			throw URLError(.badServerResponse)
		}

		return try RSSFeedParser().parse(data)
	}
}
