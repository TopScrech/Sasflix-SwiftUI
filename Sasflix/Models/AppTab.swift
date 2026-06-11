import SwiftUI

nonisolated enum AppTab: Hashable, CaseIterable, Identifiable, Sendable {
    case feed, blog, saved, more
    
    var id: Self { self }
    
    var title: LocalizedStringKey {
        switch self {
        case .feed: "Лента"
        case .blog: "Блог"
        case .saved: "Закладки"
        case .more: "Аккаунт"
        }
    }
    
    var systemImage: String {
        switch self {
        case .feed: "play.rectangle"
        case .blog: "text.page"
        case .saved: "bookmark"
        case .more: "person.crop.circle"
        }
    }
}
