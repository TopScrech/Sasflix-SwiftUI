import Foundation

nonisolated struct AuthenticationService: Sendable {
	private let baseURL: URL

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

	func signOut(token: String) async throws {
		let request = try makeRequest(path: "security/logout", method: "POST", token: token)
		_ = try await responseData(for: request)
	}

	private func makeRequest(path: String, method: String, token: String? = nil) throws -> URLRequest {
		var request = URLRequest(url: baseURL.appending(path: path))
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
		token: String? = nil
	) throws -> URLRequest {
		var request = try makeRequest(path: path, method: method, token: token)
		request.httpBody = try JSONEncoder().encode(body)
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		return request
	}

	private func responseData(for request: URLRequest) async throws -> Data {
		let (data, response) = try await URLSession.shared.data(for: request)

		guard let httpResponse = response as? HTTPURLResponse else {
			throw AuthenticationRequestError.invalidResponse
		}

		switch httpResponse.statusCode {
		case 200..<300:
			return data
		case 400, 422:
			throw AuthenticationRequestError.invalidCredentials
		case 401, 403:
			throw AuthenticationRequestError.unauthorized
		default:
			throw AuthenticationRequestError.server
		}
	}

	private static func defaultBaseURL() -> URL {
		guard let url = URL(string: "https://sasflix.ru/api/") else {
			preconditionFailure("Invalid Sasflix API URL")
		}

		return url
	}
}
