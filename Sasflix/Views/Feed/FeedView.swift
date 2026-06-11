import SwiftUI

struct FeedView: View {
    @Bindable var viewModel: FeedVM
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                CategoryPickerView(selectedCategory: $viewModel.selectedCategory)
                
                if let featuredItem = viewModel.featuredItem {
                    NavigationLink(value: featuredItem) {
                        FeedHeroView(item: featuredItem)
                    }
                    .buttonStyle(.plain)
                }
                
                ForEach(viewModel.listItems) { item in
                    NavigationLink(value: item) {
                        FeedItemRowView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Сасфликс")
        .searchable(text: $viewModel.searchText, prompt: "Поиск")
        .refreshable {
            await viewModel.load()
        }
        .task {
            await viewModel.loadIfNeeded()
        }
        .overlay {
            if viewModel.isLoading, viewModel.items.isEmpty {
                LoadingStateView("Загружаем ленту")
                
            } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
                EmptyStateView(title: "Нет соединения", systemImage: "wifi.exclamationmark", message: errorMessage)
                
            } else if viewModel.visibleItems.isEmpty, !viewModel.items.isEmpty {
                EmptyStateView(title: "Ничего не найдено", systemImage: "magnifyingglass", message: "Попробуйте другой запрос или категорию")
            }
        }
        .navigationDestination(for: FeedItem.self) {
            VideoView(item: $0)
        }
    }
    
}
