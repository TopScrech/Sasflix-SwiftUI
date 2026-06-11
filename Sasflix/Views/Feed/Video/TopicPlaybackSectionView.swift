import SwiftUI

struct TopicPlaybackSectionView: View {
    @State private var vm = TopicPlaybackVM()
    @Environment(AuthenticationStore.self) private var authStore
    
    let item: FeedItem
    
    var body: some View {
        Group {
            if let video = vm.video {
                TopicVideoPlayerView(video: video, fallbackPosterURL: item.posterURL, authorizationHeader: vm.authorizationHeader)
            } else if vm.isLoading {
                ZStack {
                    RemotePosterView(url: item.posterURL)
                    
                    ProgressView()
                        .controlSize(.large)
                }
            } else if vm.isLocked {
                TopicPlaybackStatusView(
                    posterURL: item.posterURL,
                    title: lockedTitle,
                    systemImage: "lock.fill",
                    message: lockedMessage
                )
            } else if let errorMessage = vm.errorMessage {
                TopicPlaybackStatusView(
                    posterURL: item.posterURL,
                    title: "Видео недоступно",
                    systemImage: "wifi.exclamationmark",
                    message: errorMessage
                )
            } else {
                RemotePosterView(url: item.posterURL)
            }
        }
        .task(id: loadIdentifier) {
            await vm.load(item: item)
        }
    }
    
    private var loadIdentifier: String {
        "\(item.id.absoluteString)-\(authStore.user?.id ?? 0)"
    }
    
    private var lockedTitle: String {
        authStore.user == nil ? "Видео закрыто" : "Нужна подписка"
    }
    
    private var lockedMessage: String {
        authStore.user == nil ? "Войдите в аккаунт или откройте выпуск на сайте" : "Проверьте доступ к выпуску на сайте"
    }
}
