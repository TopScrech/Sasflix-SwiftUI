import SwiftUI

struct SavedAuthenticatedContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var contentWidth: CGFloat = 0
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                LazyVGrid(
                    columns: VideoGridLayout.columns(
                        contentWidth: contentWidth,
                        horizontalSizeClass: horizontalSizeClass,
                        verticalSizeClass: verticalSizeClass
                    ),
                    alignment: .leading,
                    spacing: VideoGridLayout.spacing
                ) {
                    ForEach(bookmarkStore.sortedSavedItems) { item in
                        NavigationLink(value: item) {
                            FeedItemRowView(item)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
            .onGeometryChange(for: CGFloat.self) {
                $0.size.width
            } action: {
                contentWidth = $0
            }
            .refreshable {
                await bookmarkStore.loadSavedItems()
            }
        }
    }
}
