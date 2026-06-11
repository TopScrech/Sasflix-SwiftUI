import SwiftUI

struct TopUsersView: View {
    @State private var vm = TopUsersVM()
    
    var body: some View {
        List {
            ForEach(vm.users.indices, id: \.self) {
                TopUserRowView(user: vm.users[$0], rank: $0 + 1)
            }
        }
        .navigationTitle("Топ пользователей")
        .refreshable {
            await vm.load()
        }
        .task {
            await vm.loadIfNeeded()
        }
        .overlay {
            if vm.isLoading, vm.users.isEmpty {
                LoadingStateView("Загружаем пользователей")
                
            } else if let errorMessage = vm.errorMessage, vm.users.isEmpty {
                EmptyStateView(title: "Нет соединения", systemImage: "wifi.exclamationmark", message: errorMessage)
                
            } else if vm.users.isEmpty {
                EmptyStateView(title: "Пользователей нет", systemImage: "person.2", message: "Топ пользователей пока пуст")
            }
        }
    }
}
