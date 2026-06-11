import SwiftUI

struct ViewingHistoryView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(AuthenticationStore.self) private var authStore
    @State private var contentWidth: CGFloat = 0
    
    var body: some View {
        Group {
            if authStore.user == nil {
                ContentUnavailableView {
                    Label("Войдите", systemImage: "person.crop.circle.badge.checkmark")
                } description: {
                    Text("История просмотра хранится в аккаунте Sasflix")
                } actions: {
                    NavigationLink("Войти") {
                        SignInView(authStore: authStore)
                    }
                }
            } else if authStore.isViewingHistoryLoading && authStore.viewingHistory.isEmpty {
                LoadingStateView("Загружаем историю просмотра")
                
            } else if let message = authStore.viewingHistoryErrorMessage, authStore.viewingHistory.isEmpty {
                EmptyStateView(title: "История недоступна", systemImage: "exclamationmark.triangle", message: message)
                
            } else if authStore.viewingHistory.isEmpty {
                EmptyStateView(
                    title: "Истории нет",
                    systemImage: "clock.arrow.circlepath",
                    message: "Просмотренные видео появятся здесь"
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        if let message = authStore.viewingHistoryErrorMessage {
                            Text(message)
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
                            ForEach(authStore.viewingHistory) { topic in
                                if let item = topic.feedItem {
                                    NavigationLink(value: item) {
                                        ViewingHistoryRowView(topic: topic)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        FeedItemContextMenuView(item: item)
                                    }
                                }
                            }
                        }
                        
                        if authStore.isViewingHistoryLoading || authStore.canLoadMoreViewingHistory {
                            if authStore.isViewingHistoryLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            } else {
                                Button("Загрузить ещё", systemImage: "arrow.down.circle", action: loadMore)
                            }
                        }
                    }
                    .padding()
                    .onGeometryChange(for: CGFloat.self) {
                        $0.size.width
                    } action: {
                        contentWidth = $0
                    }
                }
                .refreshable {
                    await authStore.loadViewingHistory()
                }
            }
        }
        .navigationTitle("История")
        .navigationDestination(for: FeedItem.self) {
            VideoView(item: $0)
        }
        .task {
            await authStore.loadViewingHistoryIfNeeded()
        }
    }
    
    private func loadMore() {
        Task {
            await authStore.loadMoreViewingHistory()
        }
    }
}
