import Foundation

nonisolated struct VideoDownloadProgress: Hashable, Sendable {
    let completedUnit: Double
    let totalUnit: Double?
    let downloadedByteCount: Int64?
    let startedAt: Date
    let updatedAt: Date
    
    var fractionCompleted: Double? {
        guard let totalUnit, totalUnit > 0 else {
            return nil
        }
        
        return min(completedUnit / totalUnit, 1)
    }
    
    var progressText: String {
        if let fractionCompleted {
            let percent = (fractionCompleted * 100).formatted(.number.precision(.fractionLength(0)))
            
            if let downloadedByteCount, downloadedByteCount > 0 {
                return "\(percent)% \(Self.formattedByteCount(downloadedByteCount))"
            }
            
            return "\(percent)%"
        }
        
        guard let downloadedByteCount, downloadedByteCount > 0 else {
            return "Подготовка"
        }
        
        return Self.formattedByteCount(downloadedByteCount)
    }
    
    var speedText: String {
        if let downloadedByteCount, downloadedByteCount > 0 {
            return "\(Self.formattedByteCount(Int64(byteSpeedPerSecond)))/с"
        }
        
        let speed = unitSpeedPerSecond.formatted(.number.precision(.fractionLength(1)))
        return "\(speed)x"
    }
    
    var remainingText: String {
        guard let remainingTime else {
            return "Осталось неизвестно"
        }
        
        return "Осталось \(Self.formattedDuration(remainingTime))"
    }
    
    static func pending(startedAt: Date) -> Self {
        Self(
            completedUnit: 0,
            totalUnit: nil,
            downloadedByteCount: nil,
            startedAt: startedAt,
            updatedAt: startedAt
        )
    }
    
    static func mediaProgress(
        loadedSeconds: Double,
        totalSeconds: Double?,
        downloadedByteCount: Int64?,
        startedAt: Date,
        updatedAt: Date
    ) -> Self {
        Self(
            completedUnit: max(loadedSeconds, 0),
            totalUnit: totalSeconds,
            downloadedByteCount: downloadedByteCount,
            startedAt: startedAt,
            updatedAt: updatedAt
        )
    }
    
    static func formattedByteCount(_ byteCount: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file)
    }
    
    private var byteSpeedPerSecond: Double {
        let elapsed = max(updatedAt.timeIntervalSince(startedAt), 0.1)
        return Double(downloadedByteCount ?? 0) / elapsed
    }
    
    private var unitSpeedPerSecond: Double {
        let elapsed = max(updatedAt.timeIntervalSince(startedAt), 0.1)
        return completedUnit / elapsed
    }
    
    private var remainingTime: TimeInterval? {
        guard let totalUnit, totalUnit > completedUnit, unitSpeedPerSecond > 0 else {
            return nil
        }
        
        return (totalUnit - completedUnit) / unitSpeedPerSecond
    }
    
    private static func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = max(Int(duration.rounded(.up)), 1)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours) ч \(minutes) мин"
        }
        
        if minutes > 0 {
            return "\(minutes) мин \(seconds) с"
        }
        
        return "\(seconds) с"
    }
}
