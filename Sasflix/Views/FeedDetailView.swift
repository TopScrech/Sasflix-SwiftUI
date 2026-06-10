import SwiftUI

struct FeedDetailView: View {
	@Environment(\.openURL) private var openURL
	@Environment(BookmarkStore.self) private var bookmarkStore
	@Environment(AuthenticationStore.self) private var authStore
	let item: FeedItem

	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				RemotePosterView(url: item.posterURL)

				MetadataBadgeView(title: item.category.title, systemImage: item.category.systemImage)

				Text(item.title)
					.font(.title)
					.bold()

				if let author = item.author {
					Text(author)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}

				Text(item.publishedAt, format: .dateTime.day().month(.wide).year().hour().minute())
					.font(.subheadline)
					.foregroundStyle(.secondary)

				Button("Открыть на сайте", systemImage: "safari", action: openOfficialPage)
					.buttonStyle(.borderedProminent)
					.controlSize(.large)

				ShareLink(item: item.link) {
					Label("Поделиться", systemImage: "square.and.arrow.up")
				}
				.buttonStyle(.bordered)
				.controlSize(.large)
			}
			.padding()
		}
		.navigationTitle("Видео")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button(bookmarkStore.isSaved(item) ? "Убрать" : "Сохранить", systemImage: bookmarkStore.isSaved(item) ? "bookmark.fill" : "bookmark", action: toggleSaved)
					.disabled(authStore.user == nil || bookmarkStore.isUpdating(item))
			}
		}
	}

	private func openOfficialPage() {
		openURL(item.link)
	}

	private func toggleSaved() {
		Task {
			await bookmarkStore.toggle(item)
		}
	}
}
