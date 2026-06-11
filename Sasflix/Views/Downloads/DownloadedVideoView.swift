import SwiftUI

struct DownloadedVideoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(VideoDownloadStore.self) private var downloadStore
    
    let download: DownloadedVideo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                LocalVideoPlayerView(
                    fileURL: downloadStore.fileURL(for: download),
                    posterURL: download.feedItem.posterURL
                )
                
                MetadataBadgeView(category: download.feedItem.category)
                
                Text(download.feedItem.title)
                    .title(.bold)
                
                Text(download.feedItem.publishedAt, format: .dateTime.day().month(.wide).year().hour().minute())
                    .subheadline()
                    .secondary()
                
                Label(VideoDownloadProgress.formattedByteCount(download.byteCount), systemImage: "internaldrive")
                    .subheadline()
                    .secondary()
                
                Label {
                    Text(download.downloadedAt, format: .dateTime.day().month(.wide).year().hour().minute())
                } icon: {
                    Image(systemName: "arrow.down.circle")
                }
                .subheadline()
                .secondary()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Удалить", systemImage: "trash", role: .destructive, action: deleteDownload)
            }
        }
    }
    
    private func deleteDownload() {
        downloadStore.delete(download)
        dismiss()
    }
}
