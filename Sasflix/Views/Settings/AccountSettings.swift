import ScrechKit

struct AccountSettings: View {
    @Environment(\.openURL) private var openURL
    @Environment(AuthenticationStore.self) private var authStore
    @State private var editedProfileField: AccountProfileField?
    @State private var isProfileEditorPresented = false
    @State private var profileDraft = ""
    
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
            
            if authStore.user != nil {
                Section("Логин") {
                    Button(action: editUsername) {
                        LabeledContent(authStore.user?.username ?? "-", value: "Изменить")
                    }
                    .buttonStyle(.plain)
                    .disabled(authStore.isProfileUpdating)
                }
                
                Section("Псевдоним") {
                    Button(action: editFullname) {
                        LabeledContent(authStore.user?.fullname ?? "-", value: "Изменить")
                    }
                    .buttonStyle(.plain)
                    .disabled(authStore.isProfileUpdating)
                }
                
                if let errorMessage = authStore.profileErrorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
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
        .overlay {
            if authStore.isProfileUpdating {
                ProgressView()
            }
        }
        .refreshable {
            await authStore.refreshAccount()
        }
        .alert(editedProfileField?.title ?? "", isPresented: $isProfileEditorPresented) {
            AccountProfileTextField(field: editedProfileField, text: $profileDraft)
            
            Button("Сохранить", action: updateProfile)
            Button("Отменить", role: .cancel, action: clearProfileEditor)
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
    
    private func editUsername() {
        editedProfileField = .username
        profileDraft = authStore.user?.username ?? ""
        isProfileEditorPresented = true
    }
    
    private func editFullname() {
        editedProfileField = .fullname
        profileDraft = authStore.user?.fullname ?? ""
        isProfileEditorPresented = true
    }
    
    private func clearProfileEditor() {
        isProfileEditorPresented = false
        editedProfileField = nil
        profileDraft = ""
    }
    
    private func updateProfile() {
        let field = editedProfileField
        let draft = profileDraft
        clearProfileEditor()
        
        Task {
            switch field {
            case .username:
                await authStore.updateProfile(username: draft)
                
            case .fullname:
                await authStore.updateProfile(fullname: draft)
                
            case nil:
                break
            }
        }
    }
}
