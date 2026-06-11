import SwiftUI

struct FeedHeroView: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            RemotePosterView(url: item.posterURL)
            MetadataBadgeView(category: item.category)
            
            Text(item.title)
                .title2(.bold)
                .lineLimit(3)
            
            Text(item.publishedAt, format: .dateTime.day().month(.wide).year().hour().minute())
                .subheadline()
                .secondary()
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 8))
    }
}
