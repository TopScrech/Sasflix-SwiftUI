import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .feed
    @State private var feedVM = FeedVM()
    @State private var blogVM = BlogVM()
    @State private var bookmarkStore = BookmarkStore()
    @State private var authenticationStore = AuthenticationStore()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.feed.title, systemImage: AppTab.feed.systemImage, value: AppTab.feed) {
                NavigationStack {
                    FeedView(vm: feedVM)
                }
            }
            
            Tab(AppTab.blog.title, systemImage: AppTab.blog.systemImage, value: AppTab.blog) {
                NavigationStack {
                    BlogView(vm: blogVM)
                }
            }
            
            Tab(AppTab.more.title, systemImage: AppTab.more.systemImage, value: AppTab.more) {
                NavigationStack {
                    AccountSettings()
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
