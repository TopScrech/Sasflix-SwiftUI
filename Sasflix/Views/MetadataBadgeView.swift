import SwiftUI

struct MetadataBadgeView: View {
    let category: FeedCategory
    
    var body: some View {
#if DEBUG
        if let systemImage = category.systemImage {
            Label(category.title, systemImage: systemImage)
                .caption()
                .secondary()
        } else {
            Text(category.title)
                .caption()
                .secondary()
        }
#else
        if category == .solovev {
            EmptyView()
        } else if let systemImage = category.systemImage {
            Label(category.title, systemImage: systemImage)
                .caption()
                .secondary()
        } else {
            Text(category.title)
                .caption()
                .secondary()
        }
#endif
    }
}
