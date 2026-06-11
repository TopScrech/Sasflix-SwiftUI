import Foundation

@Observable
final class BlogVM {
    private let service: AuthenticationService
    private let tokenStore: AuthenticationTokenStore
    private let pageSize = 10
    
    var posts: [BlogPost] = []
    var total = 0
    var searchText = ""
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    
    init(service: AuthenticationService = AuthenticationService(), tokenStore: AuthenticationTokenStore = AuthenticationTokenStore()) {
        self.service = service
        self.tokenStore = tokenStore
    }
    
    var visiblePosts: [BlogPost] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            return posts
        }
        
        return posts.filter {
            $0.title.localizedStandardContains(query)
            || $0.preview.localizedStandardContains(query)
        }
    }
    
    var canLoadMore: Bool {
        !isLoading && !isLoadingMore && posts.count < total
    }
    
    func reset() {
        posts = []
        total = 0
        searchText = ""
        errorMessage = nil
        isLoading = false
        isLoadingMore = false
    }
    
    func loadIfNeeded(canAccessBlog: Bool) async {
        guard posts.isEmpty else {
            return
        }
        
        await load(canAccessBlog: canAccessBlog)
    }
    
    func load(canAccessBlog: Bool) async {
        guard canAccessBlog else {
            reset()
            return
        }
        
        guard let token = tokenStore.loadToken() else {
            reset()
            return
        }
        
        guard !isLoading else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response = try await service.loadBlogPosts(token: token, offset: 0, limit: pageSize)
            posts = response.rows
            total = response.total
        } catch AuthenticationRequestError.unauthorized {
            reset()
            errorMessage = "Блог доступен только подписчикам"
        } catch {
            errorMessage = "Не удалось загрузить блог"
        }
    }
    
    func loadMore(canAccessBlog: Bool) async {
        guard canAccessBlog, canLoadMore, let token = tokenStore.loadToken() else {
            return
        }
        
        isLoadingMore = true
        errorMessage = nil
        defer { isLoadingMore = false }
        
        do {
            let response = try await service.loadBlogPosts(token: token, offset: posts.count, limit: pageSize)
            posts.append(contentsOf: response.rows)
            total = response.total
        } catch AuthenticationRequestError.unauthorized {
            errorMessage = "Блог доступен только подписчикам"
        } catch {
            errorMessage = "Не удалось загрузить новые посты"
        }
    }
}
