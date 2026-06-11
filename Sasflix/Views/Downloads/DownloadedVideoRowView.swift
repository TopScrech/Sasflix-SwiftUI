import SwiftUI

struct DownloadedVideoRowView: View {
    let download: DownloadedVideo
    
    var body: some View {
        VStack(alignment: .leading) {
            RemotePosterView(url: download.feedItem.posterURL)
            
            HStack {
                MetadataBadgeView(category: download.feedItem.category)
                
                Spacer()
                
                Label(VideoDownloadProgress.formattedByteCount(download.byteCount), systemImage: "arrow.down.circle.fill")
                    .caption()
                    .secondary()
            }
            
            Text(download.feedItem.title)
                .headline()
                .lineLimit(2)
            
            Text(download.downloadedAt, format: .dateTime.day().month(.abbreviated).hour().minute())
                .caption()
                .secondary()
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 8))
    }
}
