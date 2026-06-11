import SwiftUI

struct MetadataBadgeView: View {
    let category: FeedCategory
    
    var body: some View {
#if DEBUG
        Label(category.title, systemImage: category.systemImage)
            .caption()
            .secondary()
#else
        if category == .solovev {
            EmptyView()
        } else {
            Label(category.title, systemImage: category.systemImage)
                .caption()
                .secondary()
        }
#endif
    }
}
