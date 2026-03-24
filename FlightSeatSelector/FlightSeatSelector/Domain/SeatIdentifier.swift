//
//  SeatIdentifier.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 21/03/26.
//

import Foundation

// MARK: - SeatIdentifier

/// Logical seat position on the cabin grid.
struct SeatIdentifier: Hashable,
					   Sendable {
	let row: Int
	let column: Int
}
