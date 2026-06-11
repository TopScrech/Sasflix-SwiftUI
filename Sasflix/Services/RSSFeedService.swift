import Foundation

struct RSSFeedService: Sendable {
    let feedURL: URL
    let topicsURL: URL
    let pageSize: Int
    private let categoryIDs = [1, 2, 3, 4, 5, 6, 8, 9, 10]
    
    init(
        feedURL: URL = Self.defaultFeedURL(),
        topicsURL: URL = Self.defaultTopicsURL(),
        pageSize: Int = 100
    ) {
        self.feedURL = feedURL
        self.topicsURL = topicsURL
        self.pageSize = pageSize
    }
    
    func fetchItems() async throws -> [FeedItem] {
        do {
            return try await fetchTopicItems()
        } catch {
            return try await fetchRSSItems()
        }
    }
    
    private func fetchTopicItems() async throws -> [FeedItem] {
        var items: [FeedItem] = []
        items.append(contentsOf: try await fetchTopicItems(categoryID: nil))
        
        for categoryID in categoryIDs {
            items.append(contentsOf: try await fetchTopicItems(categoryID: categoryID))
        }
        
        return unique(items).sorted { $0.publishedAt > $1.publishedAt }
    }
    
    private func fetchTopicItems(categoryID: Int?) async throws -> [FeedItem] {
        var items: [FeedItem] = []
        var offset = 0
        var total: Int?
        
        repeat {
            let response = try await fetchTopicPage(offset: offset, categoryID: categoryID)
            items.append(contentsOf: response.rows.compactMap(\.feedItem))
            total = response.total
            
            guard !response.rows.isEmpty else {
                break
            }
            
            offset += response.rows.count
        } while offset < (total ?? 0)
        
        return items
    }
    
    private func fetchTopicPage(offset: Int, categoryID: Int?) async throws -> SasflixTopicsResponse {
        var queryItems = [
            URLQueryItem(name: "limit", value: String(pageSize)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        if let categoryID {
            queryItems.append(URLQueryItem(name: "category_id", value: String(categoryID)))
        }
        
        let url = topicsURL.appending(queryItems: queryItems)
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(SasflixTopicsResponse.self, from: data)
    }
    
    private func unique(_ items: [FeedItem]) -> [FeedItem] {
        var seen: Set<URL> = []
        
        return items.filter {
            seen.insert($0.id).inserted
        }
    }
    
    private func fetchRSSItems() async throws -> [FeedItem] {
        let (data, response) = try await URLSession.shared.data(from: feedURL)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try RSSFeedParser().parse(data)
    }
    
    private static func defaultFeedURL() -> URL {
        guard let url = URL(string: "https://sasflix.ru/rss.xml") else {
            preconditionFailure("Invalid Sasflix RSS URL")
        }
        
        return url
    }
    
    private static func defaultTopicsURL() -> URL {
        guard let url = URL(string: "https://sasflix.ru/api/web/topics") else {
            preconditionFailure("Invalid Sasflix topics URL")
        }
        
        return url
    }
}
