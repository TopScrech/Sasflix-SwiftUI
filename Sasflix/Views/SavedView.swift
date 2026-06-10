import SwiftUI

struct SavedView: View {
	@Environment(BookmarkStore.self) private var bookmarkStore
	@Environment(AuthenticationStore.self) private var authStore

	var body: some View {
		Group {
			if authStore.user == nil {
				ContentUnavailableView {
					Label("Войдите", systemImage: "person.crop.circle.badge.checkmark")
				} description: {
					Text("Закладки хранятся в аккаунте Sasflix")
				} actions: {
					NavigationLink("Войти") {
						SignInView(authStore: authStore)
					}
				}
			} else if bookmarkStore.isLoading && bookmarkStore.sortedSavedItems.isEmpty {
				LoadingStateView(title: "Загружаем закладки")
			} else if let errorMessage = bookmarkStore.errorMessage, bookmarkStore.sortedSavedItems.isEmpty {
				EmptyStateView(title: "Не удалось загрузить", systemImage: "exclamationmark.triangle", message: errorMessage)
			} else if bookmarkStore.sortedSavedItems.isEmpty {
				EmptyStateView(title: "Пока пусто", systemImage: "bookmark", message: "Сохраняйте выпуски из ленты")
			} else {
				List {
					if let errorMessage = bookmarkStore.errorMessage {
						Text(errorMessage)
							.foregroundStyle(.red)
					}

					ForEach(bookmarkStore.sortedSavedItems) { item in
						NavigationLink(value: item) {
							FeedItemRowView(item: item)
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
		.navigationTitle("Сохранённое")
		.navigationDestination(for: FeedItem.self) {
			FeedDetailView(item: $0)
		}
	}

	private func removeSavedItems(_ offsets: IndexSet) {
		Task {
			await bookmarkStore.removeSavedItems(at: offsets)
		}
	}
}
