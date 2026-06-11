import SwiftUI

struct BlogView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Bindable var vm: BlogVM
    
    var body: some View {
        Group {
            if authStore.user == nil {
                signedOutView
            } else if authStore.user?.canReadBlog != true {
                noAccessView
            } else {
                postsView
            }
        }
        .navigationTitle("Блог")
        .searchable(text: $vm.searchText, prompt: "Поиск")
        .onChange(of: authStore.user?.id) { _, _ in
            vm.reset()
            
            Task {
                await vm.loadIfNeeded(canAccessBlog: authStore.user?.canReadBlog == true)
            }
        }
    }
    
    private var signedOutView: some View {
        ContentUnavailableView {
            Label("Войдите в аккаунт", systemImage: "person.crop.circle")
        } description: {
            Text("Блог доступен подписчикам Сасфликса")
        } actions: {
            NavigationLink("Войти") {
                SignInView(authStore: authStore)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var noAccessView: some View {
        EmptyStateView(title: "Нет доступа", systemImage: "lock", message: "Блог доступен только подписчикам")
    }
    
    private var postsView: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.visiblePosts) { post in
                    NavigationLink(value: post) {
                        BlogPostRowView(post: post)
                    }
                    .buttonStyle(.plain)
                    .task {
                        if post == vm.posts.last {
                            await vm.loadMore(canAccessBlog: authStore.user?.canReadBlog == true)
                        }
                    }
                }
                
                if vm.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding()
        }
        .refreshable {
            await vm.load(canAccessBlog: authStore.user?.canReadBlog == true)
        }
        .task {
            await vm.loadIfNeeded(canAccessBlog: authStore.user?.canReadBlog == true)
        }
        .overlay {
            if vm.isLoading, vm.posts.isEmpty {
                LoadingStateView("Загружаем блог")
                
            } else if let errorMessage = vm.errorMessage, vm.posts.isEmpty {
                EmptyStateView(title: "Нет соединения", systemImage: "wifi.exclamationmark", message: errorMessage)
                
            } else if vm.visiblePosts.isEmpty, !vm.posts.isEmpty {
                EmptyStateView(title: "Ничего не найдено", systemImage: "magnifyingglass", message: "Попробуйте другой запрос")
            }
        }
        .navigationDestination(for: BlogPost.self) {
            BlogPostView(post: $0)
        }
    }
}
