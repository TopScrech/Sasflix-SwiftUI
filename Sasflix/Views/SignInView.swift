import SwiftUI

struct SignInView: View {
    @Bindable var authStore: AuthenticationStore
    
    var body: some View {
        Form {
            Section("Аккаунт") {
                TextField("Логин или email", text: $authStore.username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Пароль", text: $authStore.password)
                    .textContentType(.password)
                
                if let errorMessage = authStore.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
                
                Button("Войти", action: signIn)
                    .disabled(!authStore.canSubmit)
            }
        }
        .navigationTitle("Вход")
        .overlay {
            if authStore.isLoading {
                ProgressView()
            }
        }
    }
    
    private func signIn() {
        Task {
            await authStore.signIn()
        }
    }
}
