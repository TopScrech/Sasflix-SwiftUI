import Foundation

struct PlaybackSpeedStore {
    private let key = "selectedPlaybackSpeedRate"
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    var rate: Float {
        let savedRate = defaults.float(forKey: key)
        
        guard savedRate.isFinite, savedRate > 0 else {
            return 1
        }
        
        return savedRate
    }
    
    func save(rate: Float) {
        guard rate.isFinite, rate > 0 else {
            return
        }
        
        defaults.set(rate, forKey: key)
    }
}
