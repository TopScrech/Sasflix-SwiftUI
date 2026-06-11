import ScrechKit

struct PaymentHistoryView: View {
    @Environment(AuthenticationStore.self) private var authStore
    
    var body: some View {
        Group {
            if authStore.isPaymentHistoryLoading && authStore.paymentHistory.isEmpty {
                LoadingStateView("Загружаем историю платежей")
                
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
                    ForEach(authStore.paymentHistory) {
                        PaymentHistoryRowView(payment: $0)
                    }
                }
            }
        }
        .navigationTitle("Платежи")
        .refreshableTask {
            await authStore.loadPaymentHistory()
        }
    }
}
