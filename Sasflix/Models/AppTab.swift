import SwiftUI

nonisolated enum AppTab: Hashable, CaseIterable, Identifiable, Sendable {
    case feed, saved, more
    
    var id: Self { self }
    
    var title: LocalizedStringKey {
        switch self {
        case .feed: "Лента"
        case .saved: "Сохранённое"
        case .more: "Аккаунт"
        }
    }
    
    var systemImage: String {
        switch self {
        case .feed: "play.rectangle"
        case .saved: "bookmark"
        case .more: "person.crop.circle"
        }
    }
}
