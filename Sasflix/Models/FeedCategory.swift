import Foundation

nonisolated enum FeedCategory: String, CaseIterable, Identifiable, Codable, Sendable {
	case all, topics, solovev, commentator, trainings, critic, documentary, review, techno, streams, algoritm

	var id: String { rawValue }

	var title: String {
		switch self {
		case .all: "Все"
		case .topics: "Видео"
		case .solovev: "Соловьёв Live"
		case .commentator: "Комментатор"
		case .trainings: "Тренировки"
		case .critic: "Икиностас"
		case .documentary: "Докфильм"
		case .review: "Разбор"
		case .techno: "Техно"
		case .streams: "Twitch"
		case .algoritm: "Алгоритм"
		}
	}

	var systemImage: String {
		switch self {
		case .all: "sparkles"
		case .topics: "play.square.stack"
		case .solovev: "tv"
		case .commentator: "mic"
		case .trainings: "figure.strengthtraining.traditional"
		case .critic: "film"
		case .documentary: "doc.text.image"
		case .review: "list.bullet.rectangle"
		case .techno: "cpu"
		case .streams: "dot.radiowaves.left.and.right"
		case .algoritm: "point.3.connected.trianglepath.dotted"
		}
	}

	init(url: URL) {
		switch url.pathComponents.dropFirst().first {
		case "solovev": self = .solovev
		case "commentator": self = .commentator
		case "trainings": self = .trainings
		case "critic": self = .critic
		case "documentary": self = .documentary
		case "review": self = .review
		case "techno": self = .techno
		case "streams": self = .streams
		case "algoritm": self = .algoritm
		default: self = .topics
		}
	}

	func matches(_ item: FeedItem) -> Bool {
		self == .all || item.category == self
	}
}
