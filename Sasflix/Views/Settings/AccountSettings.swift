import ScrechKit

struct AccountSettings: View {
    @Environment(\.openURL) private var openURL
    @Environment(AuthenticationStore.self) private var authStore
    
    var body: some View {
        List {
            Section {
                if let user = authStore.user {
                    LabeledContent("Пользователь", value: user.displayName)
                    
                    NavigationLink {
                        ViewingHistoryView()
                    } label: {
                        Label("История просмотра", systemImage: "clock.arrow.circlepath")
                    }
                    
                    Button("Выйти", systemImage: "rectangle.portrait.and.arrow.right", action: signOut)
                        .disabled(authStore.isLoading)
                        .foregroundStyle(.red)
                } else {
                    NavigationLink {
                        SignInView(authStore: authStore)
                    } label: {
                        Label("Войти", systemImage: "person.crop.circle")
                    }
                }
            }
#if DEBUG
            if let user = authStore.user {
                Section("Подписка") {
                    if let subscription = user.subscription {
                        SubscriptionStatusView(subscription: subscription)
                    } else {
                        LabeledContent("Текущая", value: "Нет активной подписки")
                    }
                    
                    NavigationLink {
                        PaymentHistoryView()
                    } label: {
                        Label("История платежей", systemImage: "creditcard")
                    }
                }
            }
#endif
            Section("Сасфликс") {
                Button("Открыть сайт", systemImage: "safari", action: openSite)
                Button("Открыть RSS", systemImage: "dot.radiowaves.left.and.right", action: openRSS)
                Button("Поддержка", systemImage: "envelope", action: openSupport)
            }
        }
        .navigationTitle("Аккаунт")
        .refreshable {
            await authStore.refreshAccount()
        }
        .toolbar {
            NavigationLink {
                DebugSettings()
            } label: {
                Label("Debug", systemImage: "hammer")
            }
        }
    }
    
    private func openSite() {
        guard let url = URL(string: "https://sasflix.ru/") else { return }
        openURL(url)
    }
    
    private func openRSS() {
        guard let url = URL(string: "https://sasflix.ru/rss.xml") else { return }
        openURL(url)
    }
    
    private func openSupport() {
        guard let url = URL(string: "mailto:support@sasflix.ru") else { return }
        openURL(url)
    }
    
    private func signOut() {
        Task {
            await authStore.signOut()
        }
    }
}
