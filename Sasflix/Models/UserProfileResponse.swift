import Foundation

nonisolated struct UserProfileResponse: Decodable, Sendable {
    let user: AuthenticatedUser
}
