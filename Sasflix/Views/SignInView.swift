import SwiftUI

struct SignInView: View {
    @AppStorage("loginUsername") private var username = ""
    @Environment(\.dismiss) private var dismiss
    @Bindable var authStore: AuthenticationStore
    
    var body: some View {
        Form {
            TextField("Логин или email", text: $username)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            SecureField("Пароль", text: $authStore.password)
                .textContentType(.password)
            
            if let errorMessage = authStore.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            
            Section {
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
        .onAppear {
            authStore.username = username
        }
        .onChange(of: username) { _, username in
            authStore.username = username
        }
        .onChange(of: authStore.username) { _, username in
            self.username = username
        }
    }
    
    private func signIn() {
        Task {
            await authStore.signIn()

            if authStore.user != nil {
                dismiss()
            }
        }
    }
}
