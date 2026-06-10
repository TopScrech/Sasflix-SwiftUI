import Foundation

nonisolated struct FavoriteTopicsResponse: Decodable, Sendable {
	let rows: [SasflixTopic]
	let total: Int
}
