//
//  Aircraft.swift
//  FlightSeatSelector
//

import Foundation

// MARK: - Aircraft

/// A supported aircraft type. Identified by manufacturer and model; used for catalog and seat map selection.
struct Aircraft: Sendable {
	let manufacturer: String
	let model: String

	var displayName: String {
		"\(manufacturer) \(model)"
	}
}

// MARK: - Supported aircraft catalog

extension Aircraft {
	/// Currently supported aircraft. For now a single entry; later can be loaded from bundled JSON or open-source data.
	static let supported: [Aircraft] = [
		Aircraft(
			manufacturer: "Airbus",
			model: "A320"
		)
	]
}
