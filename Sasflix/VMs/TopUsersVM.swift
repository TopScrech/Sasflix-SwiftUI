import Foundation

@Observable
final class TopUsersVM {
    private let service: TopUsersService
    private let pageSize = 30
    
    var users: [TopUser] = []
    var total = 0
    var isLoading = false
    var errorMessage: String?
    
    init(service: TopUsersService = TopUsersService()) {
        self.service = service
    }
    
    func loadIfNeeded() async {
        guard users.isEmpty else {
            return
        }
        
        await load()
    }
    
    func load() async {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response = try await service.loadTopUsers(offset: 0, limit: pageSize)
            users = response.rows
            total = response.total
        } catch {
            errorMessage = "Не удалось загрузить топ пользователей"
        }
    }
}
