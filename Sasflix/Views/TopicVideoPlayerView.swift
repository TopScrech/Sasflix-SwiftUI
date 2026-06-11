import AVFoundation
import AVKit
import SwiftUI

struct TopicVideoPlayerView: View {
    let video: SasflixVideo
    let fallbackPosterURL: URL?
    let authorizationHeader: String?
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
            } else {
                RemotePosterView(url: video.posterURL ?? fallbackPosterURL)
                
                if #available(iOS 26, *) {
                    Button("Смотреть", systemImage: "play.fill", action: startPlayback)
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                } else {
                    Button("Смотреть", systemImage: "play.fill", action: startPlayback)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 8))
        .onDisappear(perform: pausePlayback)
        .onChange(of: video.id) { _, _ in
            resetPlayback()
        }
    }
    
    private func startPlayback() {
        guard let streamURL = video.streamURL else {
            return
        }
        
        let asset = AVURLAsset(url: streamURL, options: assetOptions)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        if let time = video.time, time > 0 {
            player.seek(to: CMTime(seconds: time, preferredTimescale: 600))
        }
        
        self.player = player
        player.play()
    }
    
    private func pausePlayback() {
        player?.pause()
    }
    
    private func resetPlayback() {
        player?.pause()
        player = nil
    }
    
    private var assetOptions: [String: Any]? {
        guard let authorizationHeader else {
            return nil
        }
        
        return [
            "AVURLAssetHTTPHeaderFieldsKey": [
                "Authorization": authorizationHeader
            ]
        ]
    }
}
