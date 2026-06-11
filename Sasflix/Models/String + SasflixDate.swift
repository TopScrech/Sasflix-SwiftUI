import Foundation

extension String {
    nonisolated var sasflixDate: Date? {
        if let date = try? Date(self, strategy: .iso8601) {
            return date
        }
        
        return try? Date(self, strategy: Self.sasflixDateTimeStrategy)
    }
    
    private nonisolated static var sasflixDateTimeStrategy: Date.ParseStrategy {
        Date.ParseStrategy(
            format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)",
            timeZone: .current
        )
    }
}
