import Foundation

@Observable
final class TopicPlaybackViewModel {
	private let service: AuthenticationService
	private let tokenStore: AuthenticationTokenStore
	var topic: SasflixTopic?
	var authorizationHeader: String?
	var isLoading = false
	var errorMessage: String?

	init(service: AuthenticationService = AuthenticationService(), tokenStore: AuthenticationTokenStore = AuthenticationTokenStore()) {
		self.service = service
		self.tokenStore = tokenStore
	}

	var video: SasflixVideo? {
		guard topic?.access == true else {
			return nil
		}

		return topic?.video
	}

	var isLocked: Bool {
		topic?.hasVideo == true && topic?.access == false
	}

	func load(item: FeedItem) async {
		guard let uuid = item.topicUUID else {
			topic = nil
			authorizationHeader = nil
			errorMessage = "Не удалось найти видео"
			return
		}

		isLoading = true
		errorMessage = nil
		defer { isLoading = false }

		let token = tokenStore.loadToken()

		do {
			topic = try await service.loadTopic(uuid: uuid, token: token)
			authorizationHeader = token
		} catch AuthenticationRequestError.unauthorized where token != nil {
			await loadPublicTopic(uuid: uuid)
		} catch is CancellationError {
			return
		} catch {
			topic = nil
			authorizationHeader = nil
			errorMessage = "Не удалось загрузить видео"
		}
	}

	private func loadPublicTopic(uuid: String) async {
		do {
			topic = try await service.loadTopic(uuid: uuid)
			authorizationHeader = nil
		} catch is CancellationError {
			return
		} catch {
			topic = nil
			authorizationHeader = nil
			errorMessage = "Не удалось загрузить видео"
		}
	}
}
