import Foundation
import Observation

@Observable
final class AuthenticationStore {
	var username = ""
	var password = ""
	var user: AuthenticatedUser?
	var isLoading = false
	var errorMessage: String?

	private let service: AuthenticationService
	private let tokenStore: AuthenticationTokenStore
	private var token: String?

	var canSubmit: Bool {
		!trimmedUsername.isEmpty && !password.isEmpty && !isLoading
	}

	init(service: AuthenticationService = AuthenticationService(), tokenStore: AuthenticationTokenStore = AuthenticationTokenStore()) {
		self.service = service
		self.tokenStore = tokenStore
		token = tokenStore.loadToken()
	}

	func restoreSession() async {
		guard let token, user == nil else {
			return
		}

		isLoading = true
		defer { isLoading = false }

		do {
			user = try await service.loadProfile(token: token)
			username = user?.username ?? username
		} catch {
			clearSession()
		}
	}

	func signIn() async {
		guard canSubmit else {
			return
		}

		isLoading = true
		errorMessage = nil
		defer { isLoading = false }

		do {
			let session = try await service.signIn(username: trimmedUsername, password: password)
			token = session.token
			tokenStore.saveToken(session.token)
			user = session.user
			username = session.user.username ?? trimmedUsername
			password = ""
		} catch let error as AuthenticationRequestError {
			errorMessage = error.localizedDescription
		} catch {
			errorMessage = "Не удалось войти"
		}
	}

	func signOut() async {
		let activeToken = token
		clearSession()

		if let activeToken {
			try? await service.signOut(token: activeToken)
		}
	}

	private var trimmedUsername: String {
		username.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private func clearSession() {
		token = nil
		tokenStore.deleteToken()
		user = nil
		password = ""
		errorMessage = nil
	}
}
