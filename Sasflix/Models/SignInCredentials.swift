import Foundation

nonisolated struct SignInCredentials: Encodable, Sendable {
    let username: String
    let password: String
}
