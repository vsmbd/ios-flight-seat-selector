//
//  AircraftGeometry.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import CoreGraphics
import Foundation

// MARK: - AircraftGeometry

/// Exterior and interior geometry with a consistent wall for 2D representation.
/// All dimensions are ratios to exterior width (exterior width = 100 in aircraft coordinate space).
struct AircraftGeometry: Sendable {
	let exterior: Exterior
	let interior: Interior
	/// Wall thickness per side, ratio to exterior width.
	let wallWidth: CGFloat

	/// Interior is derived from exterior by subtracting 2× wallWidth from every width (ratios).
	init(
		exterior: Exterior,
		wallWidth: CGFloat,
		seatWallPadding: CGFloat,
		cellGeometries: Interior.Cabin.CellGeometries
	) {
		self.exterior = exterior
		self.interior = .init(
			exterior: exterior,
			wallWidth: wallWidth,
			seatWallPadding: seatWallPadding,
			cellGeometries: cellGeometries
		)
		self.wallWidth = wallWidth
	}
}

// MARK: - Supported

extension AircraftGeometry {
	/// Airbus A320 family. Interior = exterior − wall on all sides (wall ≈ 0.12/3.95 ratio).
	static let a320 = Self(
		exterior: .a320,
		wallWidth: 0.032,
		seatWallPadding: 0.012,
		cellGeometries: .a320
	)
}
