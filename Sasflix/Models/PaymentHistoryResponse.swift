import Foundation

nonisolated struct PaymentHistoryResponse: Decodable, Equatable, Sendable {
	let rows: [PaymentHistoryItem]
	let total: Int
	let droppedRowsCount: Int

	enum CodingKeys: String, CodingKey {
		case rows, total
	}

	init(from decoder: Decoder) throws {
		if let decodedRows = try? [LossyPaymentHistoryItem](from: decoder) {
			rows = decodedRows.compactMap(\.value)
			total = rows.count
			droppedRowsCount = decodedRows.count - rows.count
			return
		}

		let container = try decoder.container(keyedBy: CodingKeys.self)
		let decodedRows = try container.decodeIfPresent([LossyPaymentHistoryItem].self, forKey: .rows) ?? []
		rows = decodedRows.compactMap(\.value)
		total = try container.decodeIfPresent(Int.self, forKey: .total) ?? rows.count
		droppedRowsCount = decodedRows.count - rows.count
	}
}

nonisolated private struct LossyPaymentHistoryItem: Decodable {
	let value: PaymentHistoryItem?

	init(from decoder: Decoder) throws {
		value = try? PaymentHistoryItem(from: decoder)
	}
}
