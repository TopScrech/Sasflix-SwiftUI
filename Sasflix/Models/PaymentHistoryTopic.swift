import Foundation

nonisolated struct PaymentHistoryTopic: Decodable, Equatable, Identifiable, Sendable {
	let id: Int?
	let uuid: String?
	let title: String?
}
