import SwiftUI

struct PaymentHistoryView: View {
	@Environment(AuthenticationStore.self) private var authStore

	var body: some View {
		Group {
			if authStore.isPaymentHistoryLoading && authStore.paymentHistory.isEmpty {
				LoadingStateView(title: "Загружаем историю платежей")
			} else if let message = authStore.paymentHistoryErrorMessage, authStore.paymentHistory.isEmpty {
				EmptyStateView(title: "История недоступна", systemImage: "exclamationmark.triangle", message: message)
			} else if authStore.paymentHistory.isEmpty {
				EmptyStateView(
					title: "Платежей нет",
					systemImage: "creditcard",
					message: "История платежей появится здесь после оплаты"
				)
			} else {
				List {
					Section("История") {
						ForEach(authStore.paymentHistory) {
							PaymentHistoryRowView(payment: $0)
						}
					}
				}
			}
		}
		.navigationTitle("Платежи")
		.task {
			await authStore.loadPaymentHistory()
		}
		.refreshable {
			await authStore.loadPaymentHistory()
		}
	}
}
