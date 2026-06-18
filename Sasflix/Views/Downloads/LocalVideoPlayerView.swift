import AVFoundation
import SwiftUI

struct LocalVideoPlayerView: View {
    let fileURL: URL?
    let posterURL: URL?
    
    @State private var player: AVPlayer?
    @State private var isPresentingFullScreen = false
    
    var body: some View {
        Group {
            if let fileURL {
                ZStack {
                    if let player {
                        TopicVideoPlayerControllerView(player: player, isPresentingFullScreen: $isPresentingFullScreen)
                    } else {
                        RemotePosterView(url: posterURL)
                        
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
                .onChange(of: fileURL) { _, _ in
                    resetPlayback()
                }
            } else {
                TopicPlaybackStatusView(
                    posterURL: posterURL,
                    title: "Файл недоступен",
                    systemImage: "exclamationmark.triangle",
                    message: "Удалите загрузку и скачайте видео заново"
                )
            }
        }
    }
    
    private func startPlayback() {
        guard let fileURL else {
            return
        }
        
        configureAudioSession()
        let asset = AVURLAsset(url: fileURL)
        let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        self.player = player
        player.playAtSavedPlaybackSpeed()
    }
    
    private func resetPlayback() {
        player?.pause()
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
}
