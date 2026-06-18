import AVFoundation

nonisolated enum VideoAudioSession {
    static func configureForPlayback() async {
        await Task.detached(priority: .userInitiated) {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .moviePlayback)
                try session.setActive(true)
            } catch {
                assertionFailure("Failed to configure video audio session: \(error.localizedDescription)")
            }
        }.value
    }
}
