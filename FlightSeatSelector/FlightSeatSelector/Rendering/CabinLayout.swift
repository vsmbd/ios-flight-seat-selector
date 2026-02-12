//
//  CabinLayout.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import CoreGraphics
import Foundation

// MARK: - CabinSection

struct CabinSection: Sendable {
	enum SectionType: Sendable {
		case clubEurope    // Premium (2-2 configuration)
		case euroTraveller // Economy (3-3 configuration)
		case exitRow       // Emergency exit rows
	}

	let type: SectionType
	let startRow: Int
	let endRow: Int
	let seatConfiguration: SeatConfiguration
}

// MARK: - SeatConfiguration

struct SeatConfiguration: Sendable {
	let leftSeats: [String]
	let rightSeats: [String]
	let middleSeats: [String]

	static let clubEurope = SeatConfiguration(
		leftSeats: ["A", "C"],
		rightSeats: ["D", "F"],
		middleSeats: ["B", "E"] // Middle 2-seat pairs
	)

	static let euroTraveller = SeatConfiguration(
		leftSeats: ["A", "B", "C"],
		rightSeats: ["D", "E", "F"],
		middleSeats: []
	)

	var allColumns: [String] {
		leftSeats + middleSeats + rightSeats
	}
}

// MARK: - CabinLayout

/// Complete aircraft cabin layout with all elements
struct CabinLayout: Sendable {
	let sections: [CabinSection]
	let seats: [SeatDefinition]
	let amenities: [AmenityDefinition]
	let bounds: CabinBounds
	let fuselage: FuselageGeometry

	struct SeatDefinition: Sendable, Identifiable {
		let id: String           // e.g., "12A"
		let row: Int
		let column: String
		let geometry: SeatGeometry
		let sectionType: CabinSection.SectionType
		let isExitRow: Bool
		let isAvailable: Bool    // For demo, randomize later
	}

	struct AmenityDefinition: Sendable, Identifiable {
		let id: String
		let type: AmenityGeometry.AmenityType
		let geometry: AmenityGeometry
	}

	/// Generate complete A320 layout matching reference images
	static func a320() -> CabinLayout {
		let bounds = CabinBounds.a320
		let fuselage = FuselageGeometry.a320

		// Define sections (matching reference images)
		let sections: [CabinSection] = [
			CabinSection(
				type: .clubEurope,
				startRow: 1,
				endRow: 10,
				seatConfiguration: .clubEurope
			),
			CabinSection(
				type: .exitRow,
				startRow: 11,
				endRow: 12,
				seatConfiguration: .euroTraveller
			),
			CabinSection(
				type: .euroTraveller,
				startRow: 13,
				endRow: 30,
				seatConfiguration: .euroTraveller
			)
		]

		// Generate seats
		var seats: [SeatDefinition] = []
		var currentY: CGFloat = 2.0 // Start position from nose

		for section in sections {
			let config = section.seatConfiguration
			let seatPitch = section.type == .clubEurope ? 0.9 : 0.76

			for row in section.startRow...section.endRow {
				// Calculate positions for this row
				let rowY = currentY

				// Left seats
				for (index, column) in config.leftSeats.enumerated() {
					let seatX = -bounds.width / 2 + 0.3 + (CGFloat(index) * (bounds.seatWidth + 0.05))
					let geometry = SeatGeometry(
						center: CabinCoordinate(seatX, rowY),
						width: bounds.seatWidth,
						depth: bounds.seatDepth * 0.9,
						cornerRadius: 0.08
					)
					seats.append(SeatDefinition(
						id: "\(row)\(column)",
						row: row,
						column: column,
						geometry: geometry,
						sectionType: section.type,
						isExitRow: section.type == .exitRow,
						isAvailable: Bool.random() // TODO: Load from data
					))
				}

				// Middle seats (Club Europe only)
				if !config.middleSeats.isEmpty {
					for (index, column) in config.middleSeats.enumerated() {
						let seatX = -bounds.seatWidth - 0.025 + (CGFloat(index) * (bounds.seatWidth + 0.05))
						let geometry = SeatGeometry(
							center: CabinCoordinate(seatX, rowY),
							width: bounds.seatWidth,
							depth: bounds.seatDepth * 0.9,
							cornerRadius: 0.08
						)
						seats.append(SeatDefinition(
							id: "\(row)\(column)",
							row: row,
							column: column,
							geometry: geometry,
							sectionType: section.type,
							isExitRow: section.type == .exitRow,
							isAvailable: Bool.random()
						))
					}
				}

				// Right seats
				for (index, column) in config.rightSeats.enumerated() {
					let seatX = bounds.width / 2 - 0.3 - (CGFloat(config.rightSeats.count - 1 - index) * (bounds.seatWidth + 0.05))
					let geometry = SeatGeometry(
						center: CabinCoordinate(seatX, rowY),
						width: bounds.seatWidth,
						depth: bounds.seatDepth * 0.9,
						cornerRadius: 0.08
					)
					seats.append(SeatDefinition(
						id: "\(row)\(column)",
						row: row,
						column: column,
						geometry: geometry,
						sectionType: section.type,
						isExitRow: section.type == .exitRow,
						isAvailable: Bool.random()
					))
				}

				currentY += seatPitch
			}

			// Add spacing between sections
			currentY += 0.5
		}

		// Generate amenities (lavatories, galleys)
		let amenities = generateAmenities(bounds: bounds, seatYEnd: currentY)

		return CabinLayout(
			sections: sections,
			seats: seats,
			amenities: amenities,
			bounds: bounds,
			fuselage: fuselage
		)
	}

	private static func generateAmenities(bounds: CabinBounds, seatYEnd: CGFloat) -> [AmenityDefinition] {
		var amenities: [AmenityDefinition] = []

		// Front lavatories
		amenities.append(AmenityDefinition(
			id: "lav-front-left",
			type: .lavatory,
			geometry: AmenityGeometry(
				type: .lavatory,
				rect: CGRect(x: -bounds.width / 2 + 0.2, y: 0.5, width: 0.8, height: 1.2),
				label: "LAV"
			)
		))

		// Front galley
		amenities.append(AmenityDefinition(
			id: "galley-front-right",
			type: .galley,
			geometry: AmenityGeometry(
				type: .galley,
				rect: CGRect(x: bounds.width / 2 - 1.2, y: 0.5, width: 1.0, height: 1.5),
				label: nil
			)
		))

		// Rear lavatories
		amenities.append(AmenityDefinition(
			id: "lav-rear-left",
			type: .lavatory,
			geometry: AmenityGeometry(
				type: .lavatory,
				rect: CGRect(x: -bounds.width / 2 + 0.2, y: seatYEnd + 0.5, width: 0.8, height: 1.2),
				label: "LAV"
			)
		))

		amenities.append(AmenityDefinition(
			id: "lav-rear-right",
			type: .lavatory,
			geometry: AmenityGeometry(
				type: .lavatory,
				rect: CGRect(x: bounds.width / 2 - 1.0, y: seatYEnd + 0.5, width: 0.8, height: 1.2),
				label: "LAV"
			)
		))

		return amenities
	}
}
