import SwiftUI

struct FeedView: View {
    @Bindable var vm: FeedVM
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                CategoryPickerView(selectedCategory: $vm.selectedCategory)
                
                if let featuredItem = vm.featuredItem {
                    NavigationLink(value: featuredItem) {
                        FeedHeroView(item: featuredItem)
                    }
                    .buttonStyle(.plain)
                }
                
                ForEach(vm.listItems) { item in
                    NavigationLink(value: item) {
                        FeedItemRowView(item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
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
                
            } else if vm.visibleItems.isEmpty, !vm.items.isEmpty {
                EmptyStateView(title: "Ничего не найдено", systemImage: "magnifyingglass", message: "Попробуйте другой запрос или категорию")
            }
        }
        .navigationDestination(for: FeedItem.self) {
            VideoView(item: $0)
        }
    }
    
}
