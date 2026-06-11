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
        
        init(isPresentingFullScreen: Binding<Bool>) {
            _isPresentingFullScreen = isPresentingFullScreen
        }
        
        func update(isPresentingFullScreen: Binding<Bool>) {
            _isPresentingFullScreen = isPresentingFullScreen
        }
        
        func playerViewControllerWillBeginFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
            isPresentingFullScreen = true
        }
        
        func playerViewControllerDidEndFullScreenPresentation(_ playerViewController: AVPlayerViewController) {
            isPresentingFullScreen = false
        }
    }
}
