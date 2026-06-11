import Foundation

@Observable
final class FeedVM {
    private let feedService: RSSFeedService
    var items: [FeedItem] = []
    var selectedCategory: FeedCategory = .all
    var searchText = ""
    var isLoading = false
    var errorMessage: String?
    var lastUpdated: Date?
    
    init(feedService: RSSFeedService = RSSFeedService()) {
        self.feedService = feedService
    }
    
    var visibleItems: [FeedItem] {
        items.filter {
            selectedCategory.matches($0) && matchesSearch($0)
        }
    }
    
    var featuredItem: FeedItem? {
        visibleItems.first
    }
    
    var listItems: [FeedItem] {
        guard !visibleItems.isEmpty else { return [] }
        return Array(visibleItems.dropFirst())
    }
    
    func loadIfNeeded() async {
        guard items.isEmpty else { return }
        await load()
    }
    
    func load() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            items = try await feedService.fetchItems()
            lastUpdated = .now
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Не удалось загрузить ленту"
        }
        
        isLoading = false
    }
    
    private func matchesSearch(_ item: FeedItem) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else { return true }
        
        return item.title.localizedStandardContains(query)
        || item.category.title.localizedStandardContains(query)
        || (item.author?.localizedStandardContains(query) ?? false)
    }
}
