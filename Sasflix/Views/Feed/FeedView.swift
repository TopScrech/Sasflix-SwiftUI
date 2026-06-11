import SwiftUI

struct FeedView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @AppStorage(DebugSettingKey.hideSubscriptionRequiredVideos) private var hideSubscriptionRequiredVideos = true
    @State private var contentWidth: CGFloat = 0
    @Bindable var vm: FeedVM
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                CategoryPickerView(selectedCategory: $vm.selectedCategory)
                
                if let featuredItem {
                    NavigationLink(value: featuredItem) {
                        FeedHeroView(item: featuredItem)
                    }
                    .buttonStyle(.plain)
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
                    ForEach(listItems) { item in
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
        }
        .navigationTitle("Сасфликс")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    TopUsersView()
                } label: {
                    Image(systemName: "person.2")
                        .frame(32)
                }
                .accessibilityLabel("Топ пользователей")
                
                NavigationLink {
                    DownloadedVideosView()
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .frame(32)
                }
                .accessibilityLabel("Загрузки")
                
                NavigationLink {
                    SavedView()
                } label: {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(.yellow.gradient)
                        .frame(32)
                }
                .accessibilityLabel("Закладки")
            }
        }
        .searchable(text: $vm.searchText, prompt: "Поиск")
        .refreshable {
            await vm.load()
        }
        .task {
            await vm.loadIfNeeded()
        }
        .overlay {
            if vm.isLoading, vm.items.isEmpty {
                LoadingStateView("Загружаем ленту")
                
            } else if let errorMessage = vm.errorMessage, vm.items.isEmpty {
                EmptyStateView(title: "Нет соединения", systemImage: "wifi.exclamationmark", message: errorMessage)
                
            } else if visibleItems.isEmpty, !vm.items.isEmpty {
                EmptyStateView(title: "Ничего не найдено", systemImage: "magnifyingglass", message: "Попробуйте другой запрос или категорию")
            }
        }
        .navigationDestination(for: FeedItem.self) {
            VideoView(item: $0)
        }
    }
    
    private var visibleItems: [FeedItem] {
        vm.visibleItems(hideSubscriptionRequiredVideos: hideSubscriptionRequiredVideos)
    }
    
    private var featuredItem: FeedItem? {
        vm.featuredItem(hideSubscriptionRequiredVideos: hideSubscriptionRequiredVideos)
    }
    
    private var listItems: [FeedItem] {
        vm.listItems(hideSubscriptionRequiredVideos: hideSubscriptionRequiredVideos)
    }
}
