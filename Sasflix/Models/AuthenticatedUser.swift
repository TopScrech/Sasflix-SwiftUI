import Foundation

nonisolated struct AuthenticatedUser: Codable, Equatable, Identifiable, Sendable {
	let id: Int
	let username: String?
	let fullname: String?
	let email: String?

	var displayName: String {
		if let fullname, !fullname.isEmpty {
			return fullname
		}

		if let username, !username.isEmpty {
			return username
		}

		if let email, !email.isEmpty {
			return email
		}

		return "Аккаунт Sasflix"
	}
}
