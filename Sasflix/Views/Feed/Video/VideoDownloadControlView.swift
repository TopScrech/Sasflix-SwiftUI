import SwiftUI

struct VideoDownloadControlView: View {
    @Environment(VideoDownloadStore.self) private var downloadStore
    
    let item: FeedItem
    let video: SasflixVideo
    let authorizationHeader: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            if downloadStore.download(for: video) != nil {
                HStack {
                    Label("Загружено", systemImage: "checkmark.circle.fill")
                        .caption()
                        .foregroundStyle(.green)
                    
                    Spacer()
                    
                    Button("Удалить", systemImage: "trash", role: .destructive, action: deleteDownload)
                        .buttonStyle(.bordered)
                }
            } else if let progress = downloadStore.progress(for: video) {
                VideoDownloadProgressView(progress: progress)
                
                Button("Отменить", systemImage: "xmark.circle", action: cancelDownload)
                    .buttonStyle(.bordered)
            } else {
                Button("Скачать", systemImage: "arrow.down.circle", action: startDownload)
                    .buttonStyle(.borderedProminent)
                    .disabled(video.streamURL == nil)
            }
            
            if let errorMessage = downloadStore.errorMessage(for: video) {
                Text(errorMessage)
                    .caption()
                    .foregroundStyle(.red)
            }
        }
        .monospacedDigit()
    }
    
    private func startDownload() {
        downloadStore.startDownload(item: item, video: video, authorizationHeader: authorizationHeader)
    }
    
    private func cancelDownload() {
        downloadStore.cancelDownload(video: video)
    }
    
    private func deleteDownload() {
        guard let download = downloadStore.download(for: video) else {
            return
        }
        
        downloadStore.delete(download)
    }
}
