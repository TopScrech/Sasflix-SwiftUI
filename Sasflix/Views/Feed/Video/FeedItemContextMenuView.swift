import SwiftUI

struct FeedItemContextMenuView: View {
    @Environment(BookmarkStore.self) private var bookmarkStore
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(VideoDownloadStore.self) private var downloadStore
    @State private var playbackVM = TopicPlaybackVM()
    
    let item: FeedItem
    
    var body: some View {
        NavigationLink(value: item) {
            Label("Смотреть", systemImage: "play.fill")
        }
        
        Button(favoriteTitle, systemImage: favoriteSystemImage, action: toggleFavorite)
            .disabled(authStore.user == nil || bookmarkStore.isUpdating(item))
        
        if let download = downloadedVideo {
            Button("Удалить загрузку", systemImage: "trash", role: .destructive) {
                downloadStore.delete(download)
            }
        } else if let video = playbackVM.video, downloadStore.progress(for: video) != nil {
            Button("Отменить загрузку", systemImage: "xmark.circle", action: cancelDownload)
        } else {
            Button("Скачать", systemImage: "arrow.down.circle", action: startDownload)
                .disabled(playbackVM.isLoading)
        }
        
        ShareLink(item: item.link) {
            Label("Поделиться", systemImage: "square.and.arrow.up")
        }
    }
    
    private var favoriteTitle: String {
        bookmarkStore.isSaved(item) ? "Убрать из избранного" : "В избранное"
    }
    
    private var favoriteSystemImage: String {
        bookmarkStore.isSaved(item) ? "heart.fill" : "heart"
    }
    
    private var downloadedVideo: DownloadedVideo? {
        downloadStore.downloads.first { $0.feedItem.id == item.id }
    }
    
    private func toggleFavorite() {
        Task {
            await bookmarkStore.toggle(item)
        }
    }
    
    private func startDownload() {
        Task {
            if playbackVM.video == nil {
                await playbackVM.load(item: item)
            }
            
            guard let video = playbackVM.video else {
                return
            }
            
            downloadStore.startDownload(
                item: item,
                video: video,
                authorizationHeader: playbackVM.authorizationHeader
            )
        }
    }
    
    private func cancelDownload() {
        guard let video = playbackVM.video else {
            return
        }
        
        downloadStore.cancelDownload(video: video)
    }
}
