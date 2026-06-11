import SwiftUI

struct ViewingHistoryRowView: View {
    let topic: SasflixTopic
    
    var body: some View {
        VStack(alignment: .leading) {
            if let item = topic.feedItem {
                FeedItemRowView(item: item)
            }
            
            HStack {
                Image(systemName: "clock")
                
                if let watchedAt = topic.watchedAt {
                    Text(watchedAt, format: .dateTime.day().month(.wide).year().hour().minute())
                } else {
                    Text("Просмотрено")
                }
            }
            .caption()
            .secondary()
        }
    }
}
