import SwiftUI

struct VideoView: View {
    @Environment(BookmarkStore.self) private var bookmarkStore
    @Environment(AuthenticationStore.self) private var authStore
    
    let item: FeedItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TopicPlaybackSectionView(item: item)
                MetadataBadgeView(category: item.category)
                
                Text(item.title)
                    .title(.bold)
                
                if let author = item.author {
                    Text(author)
                        .subheadline()
                        .secondary()
                }
                
                Text(item.publishedAt, format: .dateTime.day().month(.wide).year().hour().minute())
                    .subheadline()
                    .secondary()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: item.link)
                
                Button(bookmarkStore.isSaved(item) ? "Убрать" : "Сохранить", systemImage: bookmarkStore.isSaved(item) ? "bookmark.fill" : "bookmark", action: toggleSaved)
                    .disabled(authStore.user == nil || bookmarkStore.isUpdating(item))
            }
        }
    }
    
    private func toggleSaved() {
        Task {
            await bookmarkStore.toggle(item)
        }
    }
}
