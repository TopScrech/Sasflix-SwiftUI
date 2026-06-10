import SwiftUI

struct PaymentHistoryRowView: View {
	let payment: PaymentHistoryItem

	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(payment.displayTitle)
					.bold()

				Spacer()

				if let amount = payment.amount {
					Text(amount, format: .currency(code: "RUB").precision(.fractionLength(0...2)))
						.monospacedDigit()
				}
			}

			if let createdDate = payment.createdDate {
				Text(createdDate, format: .dateTime.day().month(.wide).year().hour().minute())
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			if let untilDate = payment.metadata?.untilDate {
				Text("Активна до \(untilDate, format: .dateTime.day().month(.wide).year())")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			HStack {
				PaymentStatusLabelView(payment: payment)

				if let service = payment.service, !service.isEmpty {
					Text(service)
						.foregroundStyle(.secondary)
				}
			}
			.font(.caption)
		}
	}
}
