import Foundation

extension KeyedDecodingContainer {
	nonisolated func decodeFlexibleString(forKey key: Key) -> String? {
		if let value = try? decode(String.self, forKey: key) {
			return value
		}

		if let value = try? decode(Int.self, forKey: key) {
			return String(value)
		}

		return nil
	}

	nonisolated func decodeFlexibleInt(forKey key: Key) -> Int? {
		if let value = try? decode(Int.self, forKey: key) {
			return value
		}

		if let value = try? decode(String.self, forKey: key) {
			return Int(value)
		}

		return nil
	}

	nonisolated func decodeFlexibleDouble(forKey key: Key) -> Double? {
		if let value = try? decode(Double.self, forKey: key) {
			return value
		}

		if let value = try? decode(Int.self, forKey: key) {
			return Double(value)
		}

		if let value = try? decode(String.self, forKey: key) {
			return Double(value)
		}

		return nil
	}

	nonisolated func decodeFlexibleBool(forKey key: Key) -> Bool? {
		if let value = try? decode(Bool.self, forKey: key) {
			return value
		}

		if let value = try? decode(Int.self, forKey: key) {
			return value != 0
		}

		if let value = try? decode(String.self, forKey: key) {
			if let boolValue = Bool(value) {
				return boolValue
			}

			if let intValue = Int(value) {
				return intValue != 0
			}
		}

		return nil
	}
}
