import SwiftUI

struct MoreView: View {
	@Environment(\.openURL) private var openURL
	@Environment(AuthenticationStore.self) private var authStore

	var body: some View {
		List {
			Section("Аккаунт") {
				if let user = authStore.user {
					LabeledContent("Пользователь", value: user.displayName)

					Button("Выйти", systemImage: "rectangle.portrait.and.arrow.right", action: signOut)
						.disabled(authStore.isLoading)
				} else {
					NavigationLink {
						SignInView(authStore: authStore)
					} label: {
						Label("Войти", systemImage: "person.crop.circle.badge.checkmark")
					}
				}
			}

			Section("Сасфликс") {
				Button("Открыть сайт", systemImage: "safari", action: openSite)
				Button("Открыть RSS", systemImage: "dot.radiowaves.left.and.right", action: openRSS)
				Button("Поддержка", systemImage: "envelope", action: openSupport)
			}

			Section("О приложении") {
				LabeledContent("Источник", value: "sasflix.ru/rss.xml")
				LabeledContent("Версия", value: "0.1")
				LabeledContent("Сборка", value: "0")
			}
		}
		.navigationTitle("Ещё")
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
