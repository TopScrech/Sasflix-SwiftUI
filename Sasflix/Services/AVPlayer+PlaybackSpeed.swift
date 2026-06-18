import AVFoundation

extension AVPlayer {
    func playAtSavedPlaybackSpeed(_ store: PlaybackSpeedStore = PlaybackSpeedStore()) {
        let rate = store.rate
        defaultRate = rate
        playImmediately(atRate: rate)
    }
}
