//
//  CabinGeometry.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import CoreGraphics
import Foundation

// MARK: - CabinCoordinate

/// Coordinate system for cabin layout (origin at nose, Y+ toward tail)
struct CabinCoordinate: Sendable {
	let x: CGFloat // Lateral position (0 = centerline)
	let y: CGFloat // Longitudinal position (0 = nose)

	init(_ x: CGFloat, _ y: CGFloat) {
		self.x = x
		self.y = y
	}

	var cgPoint: CGPoint {
		CGPoint(x: x, y: y)
	}
}

// MARK: - CabinBounds

/// Physical dimensions and coordinate space for cabin
struct CabinBounds: Sendable {
	let width: CGFloat    // Total cabin width (meters)
	let length: CGFloat   // Total cabin length (meters)
	let aisleWidth: CGFloat
	let seatWidth: CGFloat
	let seatDepth: CGFloat
	let rowSpacing: CGFloat

	// A320 typical dimensions
	static let a320 = CabinBounds(
		width: 3.7,           // ~3.7m cabin width
		length: 27.5,         // ~27.5m passenger cabin
		aisleWidth: 0.5,      // 50cm aisle
		seatWidth: 0.46,      // 46cm seat width
		seatDepth: 0.8,       // 80cm seat pitch (economy)
		rowSpacing: 0.1       // 10cm between seat rows
	)

	/// Convert cabin coordinates to view coordinates
	func toViewCoordinates(_ cabin: CabinCoordinate, viewSize: CGSize, scale: CGFloat) -> CGPoint {
		// Center cabin in view, apply scale
		let scaleX = (viewSize.width * 0.8) / width
		let scaleY = (viewSize.height * 0.9) / length
		let effectiveScale = min(scaleX, scaleY) * scale

		let offsetX = viewSize.width / 2
		let offsetY = viewSize.height * 0.05

		return CGPoint(
			x: offsetX + (cabin.x * effectiveScale),
			y: offsetY + (cabin.y * effectiveScale)
		)
	}

	/// Convert view coordinates to cabin coordinates
	func toCabinCoordinates(_ point: CGPoint, viewSize: CGSize, scale: CGFloat) -> CabinCoordinate {
		let scaleX = (viewSize.width * 0.8) / width
		let scaleY = (viewSize.height * 0.9) / length
		let effectiveScale = min(scaleX, scaleY) * scale

		let offsetX = viewSize.width / 2
		let offsetY = viewSize.height * 0.05

		return CabinCoordinate(
			(point.x - offsetX) / effectiveScale,
			(point.y - offsetY) / effectiveScale
		)
	}
}

// MARK: - SeatGeometry

/// Geometric description of a single seat
struct SeatGeometry: Sendable {
	let center: CabinCoordinate
	let width: CGFloat
	let depth: CGFloat
	let cornerRadius: CGFloat

	/// Create rect in cabin coordinates
	var cabinRect: CGRect {
		CGRect(
			x: center.x - width / 2,
			y: center.y - depth / 2,
			width: width,
			height: depth
		)
	}

	/// Check if cabin coordinate is inside this seat
	func contains(_ coord: CabinCoordinate) -> Bool {
		cabinRect.contains(coord.cgPoint)
	}
}

// MARK: - FuselageGeometry

/// Aircraft fuselage outline geometry
struct FuselageGeometry: Sendable {
	let width: CGFloat
	let length: CGFloat
	let noseLength: CGFloat
	let tailLength: CGFloat

	static let a320 = FuselageGeometry(
		width: 3.95,    // Fuselage width
		length: 37.57,  // Overall length
		noseLength: 5.0,
		tailLength: 5.0
	)

	/// Generate CGPath for fuselage outline in cabin coordinates
	func path(bounds: CabinBounds) -> CGPath {
		let path = CGMutablePath()

		// Simplified rectangular fuselage with rounded corners
		let rect = CGRect(
			x: -width / 2,
			y: 0,
			width: width,
			height: length
		)

		path.addRoundedRect(
			in: rect,
			cornerWidth: width / 4,
			cornerHeight: noseLength
		)

		return path
	}
}

// MARK: - AmenityGeometry

/// Geometric description for lavatories, galleys, etc.
struct AmenityGeometry: Sendable {
	enum AmenityType: Sendable {
		case lavatory
		case galley
		case door
		case exitRow
	}

	let type: AmenityType
	let rect: CGRect // In cabin coordinates
	let label: String?

	func contains(_ coord: CabinCoordinate) -> Bool {
		rect.contains(coord.cgPoint)
	}
}

// MARK: - SpatialIndex

/// Simple grid-based spatial index for efficient hit testing
final class SpatialIndex {
	private let cellSize: CGFloat = 1.0 // 1 meter cells
	private var grid: [GridKey: [Int]] = [:]

	struct GridKey: Hashable {
		let x: Int
		let y: Int
	}

	func insert(seatIndex: Int, geometry: SeatGeometry) {
		let rect = geometry.cabinRect
		let minCell = cellKey(for: CabinCoordinate(rect.minX, rect.minY))
		let maxCell = cellKey(for: CabinCoordinate(rect.maxX, rect.maxY))

		for cellX in minCell.x...maxCell.x {
			for cellY in minCell.y...maxCell.y {
				let key = GridKey(x: cellX, y: cellY)
				grid[key, default: []].append(seatIndex)
			}
		}
	}

	func query(at coord: CabinCoordinate) -> [Int] {
		let key = cellKey(for: coord)
		return grid[key] ?? []
	}

	func clear() {
		grid.removeAll()
	}

	private func cellKey(for coord: CabinCoordinate) -> GridKey {
		GridKey(
			x: Int(floor(coord.x / cellSize)),
			y: Int(floor(coord.y / cellSize))
		)
	}
}
