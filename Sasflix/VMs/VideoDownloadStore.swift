import Foundation
import Observation

@Observable
final class VideoDownloadStore {
    @ObservationIgnored private let fileManager: FileManager
    @ObservationIgnored private let downloader: VideoAssetDownloader
    @ObservationIgnored private var downloadTasks: [String: Task<Void, Never>] = [:]
    
    var downloads: [DownloadedVideo] = []
    var progressByVideoID: [String: VideoDownloadProgress] = [:]
    var errorsByVideoID: [String: String] = [:]
    var errorMessage: String?
    
    init(fileManager: FileManager = .default, downloader: VideoAssetDownloader = VideoAssetDownloader()) {
        self.fileManager = fileManager
        self.downloader = downloader
    }
    
    var sortedDownloads: [DownloadedVideo] {
        downloads.sorted { $0.downloadedAt > $1.downloadedAt }
    }
    
    func load() {
        do {
            try ensureDirectories()
            
            guard fileManager.fileExists(atPath: indexURL.path(percentEncoded: false)) else {
                downloads = []
                return
            }
            
            let data = try Data(contentsOf: indexURL)
            downloads = try JSONDecoder().decode([DownloadedVideo].self, from: data)
                .filter(shouldKeepDownload)
            try saveDownloads()
        } catch {
            errorMessage = "Не удалось загрузить сохраненные видео"
        }
    }
    
    func download(for video: SasflixVideo) -> DownloadedVideo? {
        downloads.first { $0.id == video.id }
    }
    
    func progress(for video: SasflixVideo) -> VideoDownloadProgress? {
        progressByVideoID[video.id]
    }
    
    func errorMessage(for video: SasflixVideo) -> String? {
        errorsByVideoID[video.id]
    }
    
    func localFileURL(for video: SasflixVideo) -> URL? {
        guard let download = download(for: video) else {
            return nil
        }
        
        return fileURL(for: download)
    }
    
    func fileURL(for download: DownloadedVideo) -> URL? {
        let url = localAssetURL(for: download)
        
        guard fileManager.fileExists(atPath: url.path(percentEncoded: false)) else {
            return nil
        }
        
        return url
    }
    
    func startDownload(item: FeedItem, video: SasflixVideo, authorizationHeader: String?) {
        guard download(for: video) == nil, progressByVideoID[video.id] == nil else {
            return
        }
        
        guard let streamURL = video.streamURL else {
            errorsByVideoID[video.id] = "Не удалось найти ссылку на видео"
            return
        }
        
        do {
            try ensureDirectories()
        } catch {
            errorsByVideoID[video.id] = "Не удалось подготовить хранилище"
            return
        }
        
        errorsByVideoID[video.id] = nil
        progressByVideoID[video.id] = .pending(startedAt: .now)
        
        downloadTasks[video.id] = Task { [weak self] in
            guard let self else {
                return
            }
            
            do {
                let result = try await downloader.download(
                    videoID: video.id,
                    title: item.title,
                    streamURL: streamURL,
                    authorizationHeader: authorizationHeader
                ) { [weak self] progress in
                    self?.progressByVideoID[video.id] = progress
                }
                
                finishDownload(
                    item: item,
                    video: video,
                    localURL: result.localURL,
                    byteCount: result.byteCount
                )
            } catch is CancellationError {
                cancelDownload(videoID: video.id)
            } catch {
                failDownload(videoID: video.id)
            }
        }
    }
    
    func cancelDownload(video: SasflixVideo) {
        guard let task = downloadTasks[video.id] else {
            return
        }
        
        task.cancel()
        downloader.cancel(videoID: video.id)
        cancelDownload(videoID: video.id)
    }
    
    func delete(_ download: DownloadedVideo) {
        do {
            let url = localAssetURL(for: download)
            
            if fileManager.fileExists(atPath: url.path(percentEncoded: false)) {
                try fileManager.removeItem(at: url)
            }
            
            downloads.removeAll { $0.id == download.id }
            try saveDownloads()
        } catch {
            errorMessage = "Не удалось удалить видео"
        }
    }
    
    func deleteAllDownloads() {
        for (videoID, task) in downloadTasks {
            task.cancel()
            downloader.cancel(videoID: videoID)
        }
        
        downloadTasks.removeAll()
        progressByVideoID.removeAll()
        errorsByVideoID.removeAll()
        
        do {
            for download in downloads {
                let url = localAssetURL(for: download)
                
                if fileManager.fileExists(atPath: url.path(percentEncoded: false)) {
                    try fileManager.removeItem(at: url)
                }
            }
            
            if fileManager.fileExists(atPath: filesDirectoryURL.path(percentEncoded: false)) {
                try fileManager.removeItem(at: filesDirectoryURL)
            }
            
            if fileManager.fileExists(atPath: tempDirectoryURL.path(percentEncoded: false)) {
                try fileManager.removeItem(at: tempDirectoryURL)
            }
            
            downloads = []
            try ensureDirectories()
            try saveDownloads()
        } catch {
            errorMessage = "Не удалось удалить загрузки"
        }
    }
    
    private func finishDownload(
        item: FeedItem,
        video: SasflixVideo,
        localURL: URL,
        byteCount: Int64
    ) {
        do {
            let download = DownloadedVideo(
                id: video.id,
                feedItem: item,
                localAssetPath: localURL.path(percentEncoded: false),
                downloadedAt: .now,
                byteCount: byteCount,
                duration: video.duration
            )
            downloads.removeAll { $0.id == video.id }
            downloads.append(download)
            try saveDownloads()
            progressByVideoID[video.id] = nil
            errorsByVideoID[video.id] = nil
            downloadTasks[video.id] = nil
        } catch {
            failDownload(videoID: video.id)
        }
    }
    
    private func cancelDownload(videoID: String) {
        progressByVideoID[videoID] = nil
        downloadTasks[videoID] = nil
    }
    
    private func failDownload(videoID: String) {
        progressByVideoID[videoID] = nil
        errorsByVideoID[videoID] = "Не удалось скачать видео"
        downloadTasks[videoID] = nil
    }
    
    private func saveDownloads() throws {
        try ensureDirectories()
        let data = try JSONEncoder().encode(downloads)
        try data.write(to: indexURL, options: .atomic)
    }
    
    private func ensureDirectories() throws {
        try fileManager.createDirectory(at: filesDirectoryURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
    }
    
    private func shouldKeepDownload(_ download: DownloadedVideo) -> Bool {
        let url = localAssetURL(for: download)
        
        guard fileManager.fileExists(atPath: url.path(percentEncoded: false)) else {
            return false
        }
        
        guard !download.localAssetPath.hasSuffix(".mp4") || download.byteCount >= 1_000_000 else {
            try? fileManager.removeItem(at: url)
            return false
        }
        
        return true
    }
    
    private func localAssetURL(for download: DownloadedVideo) -> URL {
        guard download.localAssetPath.hasPrefix("/") else {
            return filesDirectoryURL.appending(path: download.localAssetPath)
        }
        
        return URL(filePath: download.localAssetPath)
    }
    
    private var indexURL: URL {
        storageDirectoryURL.appending(path: "index.json")
    }
    
    private var filesDirectoryURL: URL {
        storageDirectoryURL.appending(path: "Files")
    }
    
    private var tempDirectoryURL: URL {
        storageDirectoryURL.appending(path: "Temporary")
    }
    
    private var storageDirectoryURL: URL {
        URL.applicationSupportDirectory.appending(path: "VideoDownloads")
    }
}
