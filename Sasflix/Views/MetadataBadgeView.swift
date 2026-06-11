import SwiftUI

struct MetadataBadgeView: View {
    let title: String
    let systemImage: String
    
    var body: some View {
#if DEBUG
        Label(title, systemImage: systemImage)
            .caption()
            .secondary()
#else
        if item.category == .solovev {
            EmptyView()
        } else {
            Label(title, systemImage: systemImage)
                .caption()
                .secondary()
        }
#endif
    }
}
