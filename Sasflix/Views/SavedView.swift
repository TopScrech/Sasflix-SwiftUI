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
            } else {
                SavedAuthenticatedContentView(bookmarkStore: bookmarkStore)
            }
        }
        .navigationTitle("Сохранённое")
        .navigationDestination(for: FeedItem.self) {
            FeedDetailView(item: $0)
        }
    }
}
