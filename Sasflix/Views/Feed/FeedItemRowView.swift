import SwiftUI

struct FeedItemRowView: View {
    private let item: FeedItem
    
    init(_ item: FeedItem) {
        self.item = item
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            RemotePosterView(url: item.posterURL)
            
            HStack {
                MetadataBadgeView(category: item.category)
                
                Spacer()
                
                Text(item.publishedAt, format: .dateTime.day().month(.abbreviated))
                    .caption()
                    .secondary()
            }
            
            Text(item.title)
                .headline()
                .lineLimit(2)
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 8))
    }
}
