import Foundation

@Observable
final class BookmarkStore {
	private let service: AuthenticationService
	private let tokenStore: AuthenticationTokenStore
	private var topicIDsByUUID: [String: Int] = [:]
	private var updatingItemIDs: Set<String> = []
	var savedItems: [FeedItem] = []
	var isLoading = false
	var errorMessage: String?

	init(service: AuthenticationService = AuthenticationService(), tokenStore: AuthenticationTokenStore = AuthenticationTokenStore()) {
		self.service = service
		self.tokenStore = tokenStore
	}

	var sortedSavedItems: [FeedItem] {
		savedItems.sorted { $0.publishedAt > $1.publishedAt }
	}

	func isSaved(_ item: FeedItem) -> Bool {
		let identifier = savedIdentifier(for: item)
		return savedItems.contains { savedIdentifier(for: $0) == identifier }
	}

	func isUpdating(_ item: FeedItem) -> Bool {
		updatingItemIDs.contains(savedIdentifier(for: item))
	}

	func loadSavedItems() async {
		guard let token = tokenStore.loadToken() else {
			clear()
			return
		}

		guard !isLoading else {
			return
		}

		isLoading = true
		errorMessage = nil
		defer { isLoading = false }

		do {
			let topics = try await loadAllFavoriteTopics(token: token)

			guard tokenStore.loadToken() == token else {
				return
			}

			topicIDsByUUID = topics.reduce(into: [:]) {
				if !$1.uuid.isEmpty, $1.id > 0 {
					$0[$1.uuid] = $1.id
				}
			}
			savedItems = topics.compactMap(\.feedItem)
		} catch AuthenticationRequestError.unauthorized {
			clear()
			errorMessage = "Сессия истекла, войдите снова"
		} catch {
			errorMessage = "Не удалось загрузить закладки"
		}
	}

	func toggle(_ item: FeedItem) async {
		guard let token = tokenStore.loadToken() else {
			errorMessage = "Войдите, чтобы сохранять закладки"
			return
		}

		let identifier = savedIdentifier(for: item)
		guard !updatingItemIDs.contains(identifier) else {
			return
		}

		let wasSaved = isSaved(item)
		let previousItems = savedItems
		updatingItemIDs.insert(identifier)
		errorMessage = nil

		if isSaved(item) {
			removeItem(item)
		} else {
			addItem(item)
		}

		do {
			let topicID = try await resolveTopicID(for: item, token: token)

			if wasSaved {
				try await service.removeFavoriteTopic(id: topicID, token: token)
			} else {
				try await service.addFavoriteTopic(id: topicID, token: token)
			}
		} catch {
			savedItems = previousItems
			errorMessage = "Не удалось обновить закладки"
		}

		updatingItemIDs.remove(identifier)
	}

	func removeSavedItems(at offsets: IndexSet) async {
		guard let token = tokenStore.loadToken() else {
			clear()
			return
		}

		let selectedItems = offsets.map { sortedSavedItems[$0] }
		let selectedIDs = Set(selectedItems.map(savedIdentifier))
		let previousItems = savedItems

		savedItems.removeAll { selectedIDs.contains(savedIdentifier(for: $0)) }
		errorMessage = nil

		do {
			for item in selectedItems {
				let topicID = try await resolveTopicID(for: item, token: token)
				try await service.removeFavoriteTopic(id: topicID, token: token)
			}
		} catch {
			savedItems = previousItems
			errorMessage = "Не удалось обновить закладки"
		}
	}

	func clear() {
		savedItems = []
		isLoading = false
		errorMessage = nil
		topicIDsByUUID = [:]
		updatingItemIDs = []
	}

	private func loadAllFavoriteTopics(token: String) async throws -> [SasflixTopic] {
		let limit = 50
		var offset = 0
		var topics: [SasflixTopic] = []
		var total = 0

		repeat {
			let response = try await service.loadFavoriteTopics(token: token, offset: offset, limit: limit)
			total = response.total
			topics.append(contentsOf: response.rows)
			offset += response.rows.count

			if response.rows.isEmpty {
				break
			}
		} while topics.count < total

		return topics
	}

	private func resolveTopicID(for item: FeedItem, token: String) async throws -> Int {
		guard let uuid = item.topicUUID else {
			throw URLError(.badURL)
		}

		if let topicID = topicIDsByUUID[uuid] {
			return topicID
		}

		let topic = try await service.loadTopic(uuid: uuid, token: token)
		guard topic.id > 0 else {
			throw URLError(.cannotParseResponse)
		}

		topicIDsByUUID[topic.uuid] = topic.id
		return topic.id
	}

	private func savedIdentifier(for item: FeedItem) -> String {
		item.topicUUID ?? item.link.absoluteString
	}

	private func addItem(_ item: FeedItem) {
		guard !isSaved(item) else {
			return
		}

		savedItems.append(item)
	}

	private func removeItem(_ item: FeedItem) {
		let identifier = savedIdentifier(for: item)
		savedItems.removeAll { savedIdentifier(for: $0) == identifier }
	}
}
