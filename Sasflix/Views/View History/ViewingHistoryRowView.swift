import SwiftUI

struct ViewingHistoryRowView: View {
    let topic: SasflixTopic
    
    var body: some View {
        VStack(alignment: .leading) {
            if let item = topic.feedItem {
                FeedItemRowView(item)
            }
        }
    }
}
