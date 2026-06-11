import Foundation
import OSLog

nonisolated struct AuthenticationService: Sendable {
    private let baseURL: URL
    private let logger = Logger(subsystem: "ru.sasflix.mobile", category: "AuthenticationService")
    
    init(baseURL: URL = Self.defaultBaseURL()) {
        self.baseURL = baseURL
    }
    
    func signIn(username: String, password: String) async throws -> (token: String, user: AuthenticatedUser) {
        let credentials = SignInCredentials(username: username, password: password)
        let request = try makeRequest(path: "security/login", method: "POST", body: credentials)
        let data = try await responseData(for: request)
        let tokenResponse = try JSONDecoder().decode(AuthenticationTokenResponse.self, from: data)
        
        guard !tokenResponse.token.isEmpty else {
            throw AuthenticationRequestError.missingToken
        }
        
        let token = "Bearer \(tokenResponse.token)"
        let user = try await loadProfile(token: token)
        return (token, user)
    }
    
    func loadProfile(token: String) async throws -> AuthenticatedUser {
        let request = try makeRequest(path: "user/profile", method: "GET", token: token)
        let data = try await responseData(for: request)
        return try JSONDecoder().decode(UserProfileResponse.self, from: data).user
    }
    
    func loadPaymentHistory(token: String) async throws -> PaymentHistoryResponse {
        let request = try makeRequest(
            path: "user/payments",
            method: "GET",
            token: token,
            queryItems: [
                URLQueryItem(name: "limit", value: "20"),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "sort", value: "created_at"),
                URLQueryItem(name: "dir", value: "desc")
            ]
        )
        let data = try await responseData(for: request)
        
        do {
            let response = try JSONDecoder().decode(PaymentHistoryResponse.self, from: data)
            logger.info(
                "payment_history_decode_finished rows=\(response.rows.count, privacy: .public) total=\(response.total, privacy: .public) dropped_rows=\(response.droppedRowsCount, privacy: .public)"
            )
            return response
        } catch {
            logger.error(
                "payment_history_decode_failed error=\(Self.describe(error), privacy: .public) payload_shape=\(Self.describeJSONShape(data), privacy: .public) bytes=\(data.count, privacy: .public)"
            )
            throw error
        }
    }
    
    func loadFavoriteTopics(token: String, offset: Int, limit: Int) async throws -> SasflixTopicsResponse {
        let request = try makeRequest(
            path: "user/favorite/topics",
            method: "GET",
            token: token,
            queryItems: [
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        )
        let data = try await responseData(for: request)
        return try JSONDecoder().decode(SasflixTopicsResponse.self, from: data)
    }
    
    func loadViewingHistory(token: String, offset: Int, limit: Int) async throws -> SasflixTopicsResponse {
        let request = try makeRequest(
            path: "user/views",
            method: "GET",
            token: token,
            queryItems: [
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        )
        let data = try await responseData(for: request)
        return try JSONDecoder().decode(SasflixTopicsResponse.self, from: data)
    }
    
    func loadTopic(uuid: String, token: String? = nil) async throws -> SasflixTopic {
        let request = try makeRequest(path: "web/topics/\(uuid)", method: "GET", token: token)
        let data = try await responseData(for: request)
        return try JSONDecoder().decode(SasflixTopic.self, from: data)
    }
    
    func addFavoriteTopic(id: Int, token: String) async throws {
        let request = try makeRequest(path: "user/favorite/topics/\(id)", method: "PUT", token: token)
        _ = try await responseData(for: request)
    }
    
    func removeFavoriteTopic(id: Int, token: String) async throws {
        let request = try makeRequest(path: "user/favorite/topics/\(id)", method: "DELETE", token: token)
        _ = try await responseData(for: request)
    }
    
    func signOut(token: String) async throws {
        let request = try makeRequest(path: "security/logout", method: "POST", token: token)
        _ = try await responseData(for: request)
    }
    
    private func makeRequest(
        path: String,
        method: String,
        token: String? = nil,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        let url = baseURL.appending(path: path).appending(queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func makeRequest<Body: Encodable>(
        path: String,
        method: String,
        body: Body,
        token: String? = nil,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        var request = try makeRequest(path: path, method: method, token: token, queryItems: queryItems)
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func responseData(for request: URLRequest) async throws -> Data {
        let startedAt = Date()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("api_request_failed route=\(Self.routeDescription(for: request), privacy: .public) reason=invalid_response")
            throw AuthenticationRequestError.invalidResponse
        }
        
        let durationMS = Int(Date().timeIntervalSince(startedAt) * 1000)
        logger.debug(
            "api_request_finished method=\(request.httpMethod ?? "GET", privacy: .public) route=\(Self.routeDescription(for: request), privacy: .public) status=\(httpResponse.statusCode, privacy: .public) duration_ms=\(durationMS, privacy: .public) bytes=\(data.count, privacy: .public)"
        )
        
        switch httpResponse.statusCode {
        case 200..<300:
            return data
        case 400, 422:
            logger.warning(
                "api_request_rejected route=\(Self.routeDescription(for: request), privacy: .public) status=\(httpResponse.statusCode, privacy: .public) response=\(Self.describeErrorBody(data), privacy: .public)"
            )
            throw AuthenticationRequestError.invalidCredentials
        case 401, 403:
            logger.warning(
                "api_request_unauthorized route=\(Self.routeDescription(for: request), privacy: .public) status=\(httpResponse.statusCode, privacy: .public) response=\(Self.describeErrorBody(data), privacy: .public)"
            )
            throw AuthenticationRequestError.unauthorized
        default:
            logger.error(
                "api_request_server_error route=\(Self.routeDescription(for: request), privacy: .public) status=\(httpResponse.statusCode, privacy: .public) response=\(Self.describeErrorBody(data), privacy: .public)"
            )
            throw AuthenticationRequestError.server
        }
    }
    
    private static func routeDescription(for request: URLRequest) -> String {
        guard let url = request.url else {
            return "unknown"
        }
        
        var value = url.path
        
        if let query = url.query, !query.isEmpty {
            value += "?\(query)"
        }
        
        return value
    }
    
    private static func describe(_ error: Error) -> String {
        if let decodingError = error as? DecodingError {
            return describe(decodingError)
        }
        
        return String(describing: error)
    }
    
    private static func describe(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "type_mismatch type=\(type) path=\(describe(context.codingPath)) debug=\(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "value_not_found type=\(type) path=\(describe(context.codingPath)) debug=\(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "key_not_found key=\(key.stringValue) path=\(describe(context.codingPath)) debug=\(context.debugDescription)"
        case .dataCorrupted(let context):
            return "data_corrupted path=\(describe(context.codingPath)) debug=\(context.debugDescription)"
        @unknown default:
            return String(describing: error)
        }
    }
    
    private static func describe(_ codingPath: [CodingKey]) -> String {
        codingPath.map(\.stringValue).joined(separator: ".")
    }
    
    private static func describeJSONShape(_ data: Data) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: data) else {
            return "non_json"
        }
        
        return describeJSONShape(object)
    }
    
    private static func describeJSONShape(_ object: Any) -> String {
        if let dictionary = object as? [String: Any] {
            return "object(keys=\(dictionary.keys.sorted().joined(separator: ",")))"
        }
        
        if let array = object as? [Any] {
            if let first = array.first {
                return "array(count=\(array.count), first=\(describeJSONShape(first)))"
            }
            
            return "array(count=0)"
        }
        
        return String(describing: type(of: object))
    }
    
    private static func describeErrorBody(_ data: Data) -> String {
        guard !data.isEmpty else {
            return "empty"
        }
        
        let text = String(decoding: data, as: UTF8.self)
            .replacing("\n", with: " ")
            .replacing("\r", with: " ")
        
        return String(text.prefix(180))
    }
    
    private static func defaultBaseURL() -> URL {
        guard let url = URL(string: "https://sasflix.ru/api/") else {
            preconditionFailure("Invalid Sasflix API URL")
        }
        
        return url
    }
}
