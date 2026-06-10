import Foundation
import Observation

@Observable
final class BookmarkStore {
	private let defaults: UserDefaults
	private let storageKey = "savedFeedItems"
	var savedItems: [FeedItem] = []

	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
		savedItems = Self.loadSavedItems(defaults: defaults, storageKey: storageKey)
	}

	var sortedSavedItems: [FeedItem] {
		savedItems.sorted { $0.publishedAt > $1.publishedAt }
	}

	func isSaved(_ item: FeedItem) -> Bool {
		savedItems.contains { $0.id == item.id }
	}

	func toggle(_ item: FeedItem) {
		if isSaved(item) {
			savedItems.removeAll { $0.id == item.id }
		} else {
			savedItems.append(item)
		}

		persist()
	}

	func removeSavedItems(at offsets: IndexSet) {
		let selectedItems = offsets.map { sortedSavedItems[$0] }
		let selectedIDs = Set(selectedItems.map(\.id))
		savedItems.removeAll { selectedIDs.contains($0.id) }
		persist()
	}

	private func persist() {
		guard let data = try? JSONEncoder().encode(savedItems) else { return }
		defaults.set(data, forKey: storageKey)
	}

	private static func loadSavedItems(defaults: UserDefaults, storageKey: String) -> [FeedItem] {
		guard let data = defaults.data(forKey: storageKey) else { return [] }
		return (try? JSONDecoder().decode([FeedItem].self, from: data)) ?? []
	}
}
