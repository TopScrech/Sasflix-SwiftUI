import Foundation
import Observation
import OSLog

@Observable
final class AuthenticationStore {
	var username = ""
	var password = ""
	var user: AuthenticatedUser?
	var paymentHistory: [PaymentHistoryItem] = []
	var isLoading = false
	var isPaymentHistoryLoading = false
	var errorMessage: String?
	var paymentHistoryErrorMessage: String?

	private let service: AuthenticationService
	private let tokenStore: AuthenticationTokenStore
	private let logger = Logger(subsystem: "ru.sasflix.mobile", category: "AuthenticationStore")
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
			Task {
				await loadPaymentHistory()
			}
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
			Task {
				await loadPaymentHistory()
			}
		} catch let error as AuthenticationRequestError {
			errorMessage = error.localizedDescription
		} catch {
			errorMessage = "Не удалось войти"
		}
	}

	func loadPaymentHistory() async {
		guard let token else {
			paymentHistory = []
			paymentHistoryErrorMessage = nil
			logger.debug("payment_history_load_skipped reason=missing_token")
			return
		}

		guard !isPaymentHistoryLoading else {
			logger.debug("payment_history_load_skipped reason=already_loading")
			return
		}

		isPaymentHistoryLoading = true
		paymentHistoryErrorMessage = nil
		defer { isPaymentHistoryLoading = false }

		logger.info("payment_history_load_started user_id=\(self.user?.id ?? 0, privacy: .private)")

		do {
			let response = try await service.loadPaymentHistory(token: token)
			paymentHistory = response.rows
			logger.info(
				"payment_history_load_finished rows=\(response.rows.count, privacy: .public) total=\(response.total, privacy: .public) dropped_rows=\(response.droppedRowsCount, privacy: .public)"
			)
		} catch AuthenticationRequestError.unauthorized {
			paymentHistoryErrorMessage = "Не удалось загрузить историю платежей"
			logger.warning("payment_history_load_failed reason=unauthorized")
		} catch {
			paymentHistoryErrorMessage = "Не удалось загрузить историю платежей"
			logger.error("payment_history_load_failed error=\(String(describing: error), privacy: .public)")
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
		paymentHistory = []
		password = ""
		errorMessage = nil
		paymentHistoryErrorMessage = nil
	}
}
