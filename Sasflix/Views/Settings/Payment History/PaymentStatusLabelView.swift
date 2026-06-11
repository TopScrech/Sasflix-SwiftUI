import SwiftUI

struct PaymentStatusLabelView: View {
    let payment: PaymentHistoryItem
    
    var body: some View {
        switch payment.paid {
        case true:
            Label("Оплачен", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case false:
            Label("Не оплачен", systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
        case nil:
            Label("Ожидает", systemImage: "hourglass")
                .secondary()
        }
    }
}
