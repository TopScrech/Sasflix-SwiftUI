import SwiftUI

struct SavedAuthenticatedContentView: View {
    let bookmarkStore: BookmarkStore
    
    var body: some View {
        if bookmarkStore.sortedSavedItems.isEmpty {
            ScrollView {
                VStack {
                    if bookmarkStore.isLoading {
                        LoadingStateView("Загружаем закладки")
                        
                    } else if let errorMessage = bookmarkStore.errorMessage {
                        EmptyStateView(title: "Не удалось загрузить", systemImage: "exclamationmark.triangle", message: errorMessage)
                        
                    } else {
                        EmptyStateView(title: "Пока пусто", systemImage: "bookmark", message: "Сохраняйте выпуски из ленты")
                    }
                }
                .containerRelativeFrame(.vertical)
            }
            .refreshable {
                await bookmarkStore.loadSavedItems()
            }
        } else {
            ScrollView {
                if let errorMessage = bookmarkStore.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
                
                ForEach(bookmarkStore.sortedSavedItems) { item in
                    NavigationLink(value: item) {
                        FeedItemRowView(item)
                    }
                }
                .onDelete(perform: removeSavedItems)
            }
            .listStyle(.plain)
            .refreshable {
                await bookmarkStore.loadSavedItems()
            }
        }
    }
    
    private func removeSavedItems(_ offsets: IndexSet) {
        Task {
            await bookmarkStore.removeSavedItems(at: offsets)
        }
    }
}
