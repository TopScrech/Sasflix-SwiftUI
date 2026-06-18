import AVFoundation
import AVKit
import SwiftUI

struct TopicVideoPlayerView: View {
    let video: SasflixVideo
    let fallbackPosterURL: URL?
    let authorizationHeader: String?
    let localFileURL: URL?
    @State private var player: AVPlayer?
    @State private var isPresentingFullScreen = false
    
    var body: some View {
        ZStack {
            if let player {
                TopicVideoPlayerControllerView(player: player, isPresentingFullScreen: $isPresentingFullScreen)
            } else {
                RemotePosterView(url: video.posterURL ?? fallbackPosterURL)
                
                if #available(iOS 26, *) {
                    Button("Смотреть", systemImage: "play.fill", action: startPlayback)
#if !os(visionOS)
                        .buttonStyle(.glassProminent)
#endif
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
        .onChange(of: video.id) { _, _ in
            stopPlayback()
        }
        .onDisappear {
            guard !isPresentingFullScreen else {
                return
            }
            
            stopPlayback()
        }
    }
    
    private func startPlayback() {
        guard let playbackURL else {
            return
        }
        
        configureAudioSession()
        
        let asset = AVURLAsset(url: playbackURL, options: assetOptions)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        
        if localFileURL == nil, let time = video.time, time > 0 {
            player.seek(to: CMTime(seconds: time, preferredTimescale: 600))
        }
        
        self.player = player
        player.playAtSavedPlaybackSpeed()
    }
    
    private func stopPlayback() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        isPresentingFullScreen = false
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            assertionFailure("Failed to configure video audio session: \(error.localizedDescription)")
        }
    }
    
    private var assetOptions: [String: Any]? {
        guard localFileURL == nil, let authorizationHeader else {
            return nil
        }
        
        return [
            "AVURLAssetHTTPHeaderFieldsKey": [
                "Authorization": authorizationHeader
            ]
        ]
    }
    
    private var playbackURL: URL? {
        localFileURL ?? video.streamURL
    }
}
