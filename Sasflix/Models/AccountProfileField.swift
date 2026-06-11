nonisolated enum AccountProfileField: Identifiable {
    case username, fullname, email
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .username: "Логин"
        case .fullname: "Псевдоним"
        case .email: "E-mail для уведомлений"
        }
    }
}
