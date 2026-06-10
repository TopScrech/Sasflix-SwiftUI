import SwiftUI

struct SignInView: View {
	@Bindable var authStore: AuthenticationStore
	@Environment(\.openURL) private var openURL

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

				Button("Войти", systemImage: "person.crop.circle.badge.checkmark", action: signIn)
					.disabled(!authStore.canSubmit)
			}

			Section {
				Button("Открыть sasflix.ru", systemImage: "safari", action: openSite)
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

	private func openSite() {
		guard let url = URL(string: "https://sasflix.ru/") else {
			return
		}

		openURL(url)
	}
}
