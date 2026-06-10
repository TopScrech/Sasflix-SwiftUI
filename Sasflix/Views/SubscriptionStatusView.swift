import SwiftUI

struct SubscriptionStatusView: View {
	let subscription: SasflixSubscription

	var body: some View {
		Group {
			LabeledContent("Текущая", value: subscription.displayTitle)

			if let activeUntilDate = subscription.activeUntilDate {
				LabeledContent("Активна до") {
					Text(activeUntilDate, format: .dateTime.day().month(.wide).year())
				}
			} else {
				LabeledContent("Активна до", value: "Не указано")
			}

			if let nextLevelTitle = subscription.nextLevelTitle {
				LabeledContent("Следующая", value: nextLevelTitle)
			}

			if subscription.cancelled == true {
				Label("Автопродление отключено", systemImage: "repeat")
					.foregroundStyle(.secondary)
			}
		}
	}
}
