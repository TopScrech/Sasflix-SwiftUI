import SwiftUI

nonisolated enum AppTab: Hashable, CaseIterable, Identifiable, Sendable {
    case feed, blog, more
    
    var id: Self { self }
    
    var title: LocalizedStringKey {
        switch self {
        case .feed: "Лента"
        case .blog: "Блог"
        case .more: "Настройки"
        }
    }
    
    var systemImage: String {
        switch self {
        case .feed: "play.rectangle"
        case .blog: "text.page"
        case .more: "gear"
        }
    }
}
