import AVFoundation
import Foundation

nonisolated struct VideoAssetDownloadResult: Sendable {
    let localURL: URL
    let byteCount: Int64
}

@MainActor
final class VideoAssetDownloader: NSObject, AVAssetDownloadDelegate {
    private let fileManager = FileManager.default
    private var session: AVAssetDownloadURLSession?
    private var downloadsByTaskID: [Int: VideoAssetDownloadState] = [:]
    private var taskIDsByVideoID: [String: Int] = [:]
    
    override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "ru.sasflix.mobile.video-downloads")
        configuration.sessionSendsLaunchEvents = true
        session = AVAssetDownloadURLSession(
            configuration: configuration,
            assetDownloadDelegate: self,
            delegateQueue: .main
        )
    }
    
    func download(
        videoID: String,
        title: String,
        streamURL: URL,
        authorizationHeader: String?,
        progressHandler: @escaping @MainActor @Sendable (VideoDownloadProgress) -> Void
    ) async throws -> VideoAssetDownloadResult {
        guard let session else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        let startedAt = Date()
        let asset = AVURLAsset(url: streamURL, options: assetOptions(authorizationHeader: authorizationHeader))
        
        guard let task = session.makeAssetDownloadTask(
            asset: asset,
            assetTitle: title,
            assetArtworkData: nil,
            options: nil
        ) else {
            throw URLError(.unsupportedURL)
        }
        
        progressHandler(.pending(startedAt: startedAt))
        
        return try await withCheckedThrowingContinuation { continuation in
            let state = VideoAssetDownloadState(
                videoID: videoID,
                task: task,
                startedAt: startedAt,
                progressHandler: progressHandler,
                continuation: continuation
            )
            
            downloadsByTaskID[task.taskIdentifier] = state
            taskIDsByVideoID[videoID] = task.taskIdentifier
            task.resume()
        }
    }
    
    func cancel(videoID: String) {
        guard let taskID = taskIDsByVideoID[videoID],
              let state = downloadsByTaskID[taskID] else {
            return
        }
        
        state.task.cancel()
        complete(taskID: taskID, result: .failure(CancellationError()))
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        assetDownloadTask: AVAssetDownloadTask,
        willDownloadTo location: URL
    ) {
        Task { @MainActor [weak self] in
            self?.updateDownloadLocation(location, taskID: assetDownloadTask.taskIdentifier)
        }
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        assetDownloadTask: AVAssetDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        Task { @MainActor [weak self] in
            self?.updateDownloadLocation(location, taskID: assetDownloadTask.taskIdentifier)
        }
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        assetDownloadTask: AVAssetDownloadTask,
        didLoad timeRange: CMTimeRange,
        totalTimeRangesLoaded loadedTimeRanges: [NSValue],
        timeRangeExpectedToLoad: CMTimeRange
    ) {
        let taskID = assetDownloadTask.taskIdentifier
        let loadedSeconds = loadedTimeRanges.reduce(0) {
            $0 + $1.timeRangeValue.duration.seconds
        }
        let totalSeconds = timeRangeExpectedToLoad.duration.seconds
        
        Task { @MainActor [weak self] in
            self?.updateProgress(
                taskID: taskID,
                loadedSeconds: loadedSeconds,
                totalSeconds: totalSeconds.isFinite ? totalSeconds : nil
            )
        }
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        Task { @MainActor [weak self] in
            self?.complete(taskID: task.taskIdentifier, error: error)
        }
    }
    
    private func updateDownloadLocation(_ location: URL, taskID: Int) {
        guard var state = downloadsByTaskID[taskID] else {
            return
        }
        
        state.localURL = location
        downloadsByTaskID[taskID] = state
    }
    
    private func updateProgress(taskID: Int, loadedSeconds: Double, totalSeconds: Double?) {
        guard let state = downloadsByTaskID[taskID] else {
            return
        }
        
        let byteCount = state.localURL.map(byteCount(at:))
        state.progressHandler(
            .mediaProgress(
                loadedSeconds: loadedSeconds,
                totalSeconds: totalSeconds,
                downloadedByteCount: byteCount,
                startedAt: state.startedAt,
                updatedAt: .now
            )
        )
    }
    
    private func complete(taskID: Int, error: Error?) {
        if let error {
            complete(taskID: taskID, result: .failure(error))
            return
        }
        
        guard let state = downloadsByTaskID[taskID], let localURL = state.localURL else {
            complete(taskID: taskID, result: .failure(URLError(.cannotCreateFile)))
            return
        }
        
        complete(
            taskID: taskID,
            result: .success(
                VideoAssetDownloadResult(
                    localURL: localURL,
                    byteCount: byteCount(at: localURL)
                )
            )
        )
    }
    
    private func complete(taskID: Int, result: Result<VideoAssetDownloadResult, Error>) {
        guard let state = downloadsByTaskID.removeValue(forKey: taskID) else {
            return
        }
        
        taskIDsByVideoID[state.videoID] = nil
        
        switch result {
        case .success(let result):
            state.continuation.resume(returning: result)
        case .failure(let error):
            if let localURL = state.localURL,
               fileManager.fileExists(atPath: localURL.path(percentEncoded: false)) {
                try? fileManager.removeItem(at: localURL)
            }
            
            state.continuation.resume(throwing: error)
        }
    }
    
    private func byteCount(at url: URL) -> Int64 {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDirectory) else {
            return 0
        }
        
        if !isDirectory.boolValue {
            let attributes = try? fileManager.attributesOfItem(atPath: url.path(percentEncoded: false))
            return attributes?[.size] as? Int64 ?? 0
        }
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileAllocatedSizeKey, .totalFileAllocatedSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }
        
        return enumerator.reduce(0) {
            guard let fileURL = $1 as? URL,
                  let values = try? fileURL.resourceValues(forKeys: [.fileAllocatedSizeKey, .totalFileAllocatedSizeKey]) else {
                return $0
            }
            
            return $0 + Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
        }
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

private struct VideoAssetDownloadState {
    let videoID: String
    let task: AVAssetDownloadTask
    let startedAt: Date
    let progressHandler: @MainActor @Sendable (VideoDownloadProgress) -> Void
    let continuation: CheckedContinuation<VideoAssetDownloadResult, Error>
    var localURL: URL?
}
