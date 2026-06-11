nonisolated enum AccountProfileField: Identifiable {
    case username, fullname
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .username:
            "Логин"
            
        case .fullname:
            "Псевдоним"
        }
    }
}
