import Foundation

nonisolated struct PaymentHistoryMetadata: Decodable, Equatable, Sendable {
	let title: String?
	let until: String?

	var untilDate: Date? {
		until?.sasflixDate
	}
}
