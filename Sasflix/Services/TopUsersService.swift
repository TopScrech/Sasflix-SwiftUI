import Foundation

nonisolated struct TopUsersService: Sendable {
    private let baseURL: URL
    
    init(baseURL: URL = Self.defaultBaseURL()) {
        self.baseURL = baseURL
    }
    
    func loadTopUsers(offset: Int, limit: Int) async throws -> TopUsersResponse {
        let url = baseURL
            .appending(path: "web/users")
            .appending(
                queryItems: [
                    URLQueryItem(name: "offset", value: String(offset)),
                    URLQueryItem(name: "limit", value: String(limit)),
                    URLQueryItem(name: "sort", value: "rating"),
                    URLQueryItem(name: "dir", value: "desc")
                ]
            )
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationRequestError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw AuthenticationRequestError.server
        }
        
        return try JSONDecoder().decode(TopUsersResponse.self, from: data)
    }
    
    private static func defaultBaseURL() -> URL {
        guard let url = URL(string: "https://sasflix.ru/api/") else {
            preconditionFailure("Invalid Sasflix API URL")
        }
        
        return url
    }
}
