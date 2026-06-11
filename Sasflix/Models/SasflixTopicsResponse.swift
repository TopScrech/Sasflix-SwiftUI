import Foundation

nonisolated struct SasflixTopicsResponse: Decodable, Sendable {
    let rows: [SasflixTopic]
    let total: Int
}
