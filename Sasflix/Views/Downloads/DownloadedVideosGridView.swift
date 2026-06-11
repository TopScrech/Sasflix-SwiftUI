import SwiftUI

struct DownloadedVideosGridView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var contentWidth: CGFloat = 0
    let downloads: [DownloadedVideo]
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: VideoGridLayout.columns(
                    contentWidth: contentWidth,
                    horizontalSizeClass: horizontalSizeClass,
                    verticalSizeClass: verticalSizeClass
                ),
                alignment: .leading,
                spacing: VideoGridLayout.spacing
            ) {
                ForEach(downloads) { download in
                    NavigationLink {
                        DownloadedVideoView(download: download)
                    } label: {
                        DownloadedVideoRowView(download: download)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .onGeometryChange(for: CGFloat.self) {
                $0.size.width
            } action: {
                contentWidth = $0
            }
        }
    }
}
