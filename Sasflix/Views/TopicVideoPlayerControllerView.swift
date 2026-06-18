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
        context.coordinator.observeSelectedSpeed(on: controller)
        return controller
    }
    
    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        context.coordinator.update(isPresentingFullScreen: $isPresentingFullScreen)
        
        if controller.player !== player {
            controller.player = player
        }
    }
    
    final class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        @Binding var isPresentingFullScreen: Bool
        private var selectedSpeedObservation: NSKeyValueObservation?
        
        init(isPresentingFullScreen: Binding<Bool>) {
            _isPresentingFullScreen = isPresentingFullScreen
        }
        
        func update(isPresentingFullScreen: Binding<Bool>) {
            _isPresentingFullScreen = isPresentingFullScreen
        }
        
        func observeSelectedSpeed(on controller: AVPlayerViewController) {
            selectedSpeedObservation = controller.observe(\.selectedSpeed, options: [.new]) { _, change in
                guard let selectedSpeed = change.newValue, let speed = selectedSpeed else {
                    return
                }
                
                let rate = speed.rate
                
                Task { @MainActor in
                    PlaybackSpeedStore().save(rate: rate)
                }
            }
        }
        
        func playerViewControllerWillBeginFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
            isPresentingFullScreen = true
        }
        
        func playerViewControllerDidEndFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
            isPresentingFullScreen = false
        }
    }
}
