import AVKit
import SwiftUI

struct TopicVideoPlayerControllerView: UIViewControllerRepresentable {
    let player: AVPlayer
    @Binding var isPresentingFullScreen: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresentingFullScreen: $isPresentingFullScreen)
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        controller.entersFullScreenWhenPlaybackBegins = false
        controller.exitsFullScreenWhenPlaybackEnds = true
        controller.player = player
        controller.showsPlaybackControls = true
        controller.updatesNowPlayingInfoCenter = true
        controller.delegate = context.coordinator
        context.coordinator.observePlaybackRate(on: player)
        return controller
    }
    
    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        context.coordinator.update(isPresentingFullScreen: $isPresentingFullScreen)
        
        if controller.player !== player {
            controller.player = player
            context.coordinator.observePlaybackRate(on: player)
        }
    }
    
    static func dismantleUIViewController(_ controller: AVPlayerViewController, coordinator: Coordinator) {
        controller.player?.pause()
        controller.player?.replaceCurrentItem(with: nil)
        controller.player = nil
        coordinator.stopObservingPlaybackRate()
    }
    
    final class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        @Binding var isPresentingFullScreen: Bool
        private var playbackRateObservation: NSKeyValueObservation?
        
        init(isPresentingFullScreen: Binding<Bool>) {
            _isPresentingFullScreen = isPresentingFullScreen
        }
        
        func update(isPresentingFullScreen: Binding<Bool>) {
            _isPresentingFullScreen = isPresentingFullScreen
        }
        
        func observePlaybackRate(on player: AVPlayer) {
            playbackRateObservation?.invalidate()
            playbackRateObservation = player.observe(\.rate, options: [.new]) { _, change in
                guard let rate = change.newValue, rate.isFinite, rate > 0 else {
                    return
                }
                
                Task { @MainActor in
                    PlaybackSpeedStore().save(rate: rate)
                }
            }
        }
        
        func stopObservingPlaybackRate() {
            playbackRateObservation?.invalidate()
            playbackRateObservation = nil
        }
        
        func playerViewControllerWillBeginFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
            isPresentingFullScreen = true
        }
        
        func playerViewControllerDidEndFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
            isPresentingFullScreen = false
        }
    }
}
