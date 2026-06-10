import SwiftUI

struct ContentView: View {
	@State private var selectedTab: AppTab = .feed
	@State private var feedViewModel = FeedViewModel()
	@State private var bookmarkStore = BookmarkStore()
	@State private var authenticationStore = AuthenticationStore()

	var body: some View {
		TabView(selection: $selectedTab) {
			Tab(AppTab.feed.title, systemImage: AppTab.feed.systemImage, value: AppTab.feed) {
				NavigationStack {
					FeedView(viewModel: feedViewModel)
				}
			}

			Tab(AppTab.saved.title, systemImage: AppTab.saved.systemImage, value: AppTab.saved) {
				NavigationStack {
					SavedView()
				}
			}

			Tab(AppTab.more.title, systemImage: AppTab.more.systemImage, value: AppTab.more) {
				NavigationStack {
					MoreView()
				}
			}
		}
		.environment(bookmarkStore)
		.environment(authenticationStore)
		.task {
			await authenticationStore.restoreSession()
			await bookmarkStore.loadSavedItems()
		}
		.onChange(of: authenticationStore.user?.id) { _, userID in
			Task {
				if userID == nil {
					bookmarkStore.clear()
				} else {
					await bookmarkStore.loadSavedItems()
				}
			}
		}
	}
}
