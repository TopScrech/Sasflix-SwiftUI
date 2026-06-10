import SwiftUI

struct SavedView: View {
	@Environment(BookmarkStore.self) private var bookmarkStore

	var body: some View {
		Group {
			if bookmarkStore.sortedSavedItems.isEmpty {
				EmptyStateView(title: "Пока пусто", systemImage: "bookmark", message: "Сохраняйте выпуски из ленты")
			} else {
				List {
					ForEach(bookmarkStore.sortedSavedItems) { item in
						NavigationLink(value: item) {
							FeedItemRowView(item: item)
						}
					}
					.onDelete(perform: removeSavedItems)
				}
				.listStyle(.plain)
			}
		}
		.navigationTitle("Сохранённое")
		.navigationDestination(for: FeedItem.self) {
			FeedDetailView(item: $0)
		}
	}

	private func removeSavedItems(_ offsets: IndexSet) {
		bookmarkStore.removeSavedItems(at: offsets)
	}
}
