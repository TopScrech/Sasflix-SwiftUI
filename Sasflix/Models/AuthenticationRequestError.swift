import Foundation

nonisolated enum AuthenticationRequestError: Error, LocalizedError, Sendable {
	case invalidCredentials, unauthorized, server, missingToken, invalidResponse

	var errorDescription: String? {
		switch self {
		case .invalidCredentials:
			"Неверный логин или пароль"
		case .unauthorized:
			"Сессия истекла, войдите снова"
		case .server:
			"Сервис Sasflix сейчас недоступен"
		case .missingToken:
			"Сервер не вернул токен входа"
		case .invalidResponse:
			"Не удалось прочитать ответ Sasflix"
		}
	}
}
