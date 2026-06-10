import Foundation

nonisolated struct AuthenticationTokenResponse: Decodable, Sendable {
	let token: String
}
