import AVFoundation
import AVKit
import OSLog
import SwiftUI

struct TopicVideoPlayerView: View {
    let video: SasflixVideo
    let fallbackPosterURL: URL?
    let authorizationHeader: String?
    let localFileURL: URL?
    @State private var player: AVPlayer?
    @State private var isPresentingFullScreen = false
    @State private var isPreparingPlayback = false
    @State private var playbackErrorMessage: String?
    @State private var playbackTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "ru.sasflix.mobile", category: "TopicVideoPlayer")

    var body: some View {
        ZStack {
            if let player {
                TopicVideoPlayerControllerView(player: player, isPresentingFullScreen: $isPresentingFullScreen)
            } else {
                RemotePosterView(url: video.posterURL ?? fallbackPosterURL)

                if isPreparingPlayback {
                    ProgressView()
                        .controlSize(.large)
                } else {
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

                if let playbackErrorMessage {
                    VStack {
                        Spacer()

                        Label(playbackErrorMessage, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(.rect(cornerRadius: 8))
                            .padding()
                    }
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
        guard playbackTask == nil else {
            return
        }

        playbackErrorMessage = nil
        isPreparingPlayback = true
        playbackTask = Task {
            do {
                let playbackCandidates = try playbackCandidates()
                guard !Task.isCancelled else {
                    return
                }

                await VideoAudioSession.configureForPlayback()

                let player = try await preparedPlayer(for: playbackCandidates)

                if localFileURL == nil, let time = video.time, time > 0 {
                    await player.seek(to: CMTime(seconds: time, preferredTimescale: 600))
                }

                self.player = player
                player.playAtSavedPlaybackSpeed()
            } catch is CancellationError {
                return
            } catch {
                logger.error("Video playback preparation failed for \(video.id, privacy: .public): \(error.localizedDescription, privacy: .public)")
                playbackErrorMessage = "Не удалось запустить видео"
            }

            isPreparingPlayback = false
            playbackTask = nil
        }
    }

    private func stopPlayback() {
        playbackTask?.cancel()
        playbackTask = nil
        isPreparingPlayback = false
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        isPresentingFullScreen = false
    }

    private func playbackCandidates() throws -> [(url: URL, assetOptions: [String: Any]?)] {
        if let localFileURL {
            return [(localFileURL, nil)]
        }

        guard let streamURL = video.streamURL else {
            throw URLError(.badURL)
        }

        let assetOptions = assetOptions(authorizationHeader: authorizationHeader)
        return [
            (video.compatibilityStreamURL ?? streamURL, assetOptions),
            (streamURL, assetOptions)
        ]
    }

    private func preparedPlayer(for playbackCandidates: [(url: URL, assetOptions: [String: Any]?)]) async throws -> AVPlayer {
        var lastError: Error?

        for playbackCandidate in playbackCandidates {
            do {
                let asset = AVURLAsset(url: playbackCandidate.url, options: playbackCandidate.assetOptions)
                let isPlayable = try await asset.load(.isPlayable)
                guard isPlayable else {
                    throw URLError(.cannotDecodeContentData)
                }

                return AVPlayer(playerItem: AVPlayerItem(asset: asset))
            } catch let error as CancellationError {
                throw error
            } catch {
                lastError = error
                logger.error("Playback candidate failed for \(video.id, privacy: .public), url=\(playbackCandidate.url.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }

        throw lastError ?? URLError(.badURL)
    }

    private func assetOptions(authorizationHeader: String?) -> [String: Any]? {
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
