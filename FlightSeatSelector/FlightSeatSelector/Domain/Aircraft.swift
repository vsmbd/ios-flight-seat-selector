//
//  Aircraft.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 11/02/26.
//

import Foundation

// MARK: - Aircraft

/// A supported aircraft type. Identified by manufacturer and model; used for catalog and seat map selection.
struct Aircraft: Sendable {
	let manufacturer: String
	let model: String
	/// Exterior and interior geometry (ratio-based; exterior width = 100). Used for cabin rendering and layout.
	let geometry: AircraftGeometry
	let layout: AircraftLayout
}
