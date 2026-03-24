//
//  AircraftGeometry+Interior.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import CoreGraphics
import Foundation

// MARK: - AircraftGeometry + Interior

extension AircraftGeometry {
	/// Entire interior in ratio-based coordinates. Three segments: nose, cabin, tail.
	/// All values are ratios to exterior width (exterior width = 100 in aircraft coordinate space).
	struct Interior: Sendable {
		let nose: Nose
		let cabin: Cabin
		let tail: Tail

		let wallWidth: CGFloat
		let seatWallPadding: CGFloat

		/// Total interior length (nose + cabin + tail), ratio to exterior width.
		let totalLength: CGFloat
		/// Longitudinal offset of cabin forward bulkhead from aircraft nose, ratio.
		let cabinStartOffset: CGFloat
		/// Longitudinal offset of cabin aft bulkhead from aircraft nose, ratio.
		let cabinEndOffset: CGFloat

		/// Interior derived from exterior by subtracting 2× wallWidth from every width (ratios).
		init(
			exterior: AircraftGeometry.Exterior,
			wallWidth: CGFloat,
			seatWallPadding: CGFloat,
			cellGeometries: Cabin.CellGeometries
		) {
			let widthReduction = 2 * wallWidth

			self.wallWidth = wallWidth

			self.seatWallPadding = seatWallPadding

			self.nose = Nose(
				length: exterior.nose.length,
				widthAtCabin: exterior.nose.widthAtCabin - widthReduction
			)
			self.cabin = Cabin(
				length: exterior.cabin.length,
				width: exterior.cabin.width - widthReduction,
				cellGeometries: cellGeometries
			)
			self.tail = Tail(
				length: exterior.tail.length - wallWidth,
				widthAtCabin: exterior.tail.widthAtCabin - widthReduction,
				widthAtEnd: exterior.tail.widthAtEnd - widthReduction
			)

			self.totalLength = nose.length + cabin.length + tail.length
			self.cabinStartOffset = nose.length
			self.cabinEndOffset = nose.length + cabin.length
		}

		// MARK: ++ Segments

		/// Nose section interior (forward of cabin, e.g. cockpit / forward galley)
		struct Nose: Sendable {
			/// Length from nose to cabin forward bulkhead, ratio to exterior width
			let length: CGFloat
			/// Interior width at interface with cabin, ratio to exterior width
			let widthAtCabin: CGFloat
		}

		/// Passenger cabin interior (constant section)
		struct Cabin: Sendable {
			// MARK: ++ SeatGeometry

			/// Physical dimensions of a seat cell as ratios to exterior width (width, depth).
			struct SeatGeometry: Sendable {
				let width: CGFloat
				let depth: CGFloat
				let baseWidth: CGFloat
				let baseDepth: CGFloat
				let baseDepthStartOffset: CGFloat
				let foldWidth: CGFloat
				let foldDepth: CGFloat
				let backrestBaseWidth: CGFloat
				let backrestDepth: CGFloat
				let backrestHeadrestLowerXOffset: CGFloat
				let backrestHeadrestLowerYOffsetFromBase: CGFloat
				let backrestHeadrestWidth: CGFloat
				let backrestHeadrestCenterBaseOffset: CGFloat
				let backrestHeadrestUpperXOffset: CGFloat
				let backrestHeadrestUpperYOffsetFromBase: CGFloat
				let backrestPlateDepth: CGFloat
				let backrestPlateArcOffsetYFromBase: CGFloat
				let backrestPlateTopOffsetYFromBase: CGFloat
			}

			struct SeatArmrestGeometry: Sendable {
				let width: CGFloat
				let depth: CGFloat
				let centerOffsetToSeatCenter: CGFloat
			}

			/// Passenger door: width (lateral) and length along cabin, ratios to exterior width.
			struct DoorGeometry: Sendable {
				let width: CGFloat
				let lengthAlongCabin: CGFloat
			}

			/// Lavatory footprint, ratios to exterior width.
			struct LavatoryGeometry: Sendable {
				let width: CGFloat
				let depth: CGFloat
			}

			/// Galley footprint, ratios to exterior width.
			struct GalleyGeometry: Sendable {
				let width: CGFloat
				let depth: CGFloat
			}

			/// Empty / structural cell, ratios to exterior width. May be zero.
			struct EmptyGeometry: Sendable {
				let width: CGFloat
				let depth: CGFloat
			}

			/// Generic amenity footprint, ratios to exterior width.
			struct AmenityGeometry: Sendable {
				let width: CGFloat
				let depth: CGFloat
			}

			/// Default geometries per cabin cell kind. Seat is required; others optional.
			struct CellGeometries: Sendable {
				let seat: SeatGeometry
				let seatArmRest: SeatArmrestGeometry
				let door: DoorGeometry?
				let lavatory: LavatoryGeometry?
				let galley: GalleyGeometry?
				let empty: EmptyGeometry?
				let amenity: AmenityGeometry?

				init(
					seat: SeatGeometry,
					seatArmRest: SeatArmrestGeometry,
					door: DoorGeometry? = nil,
					lavatory: LavatoryGeometry? = nil,
					galley: GalleyGeometry? = nil,
					empty: EmptyGeometry? = nil,
					amenity: AmenityGeometry? = nil
				) {
					self.seat = seat
					self.seatArmRest = seatArmRest
					self.door = door
					self.lavatory = lavatory
					self.galley = galley
					self.empty = empty
					self.amenity = amenity
				}
			}

			/// Length from forward to aft cabin bulkhead, ratio to exterior width
			let length: CGFloat
			/// Interior width (constant over cabin), ratio to exterior width
			let width: CGFloat
			/// Default geometries per cabin cell kind. Part of the aircraft data model.
			let cellGeometries: CellGeometries
		}

		/// Tail section interior (aft of cabin, e.g. rear galley / vestibule)
		struct Tail: Sendable {
			/// Length from cabin aft bulkhead to tail, ratio to exterior width
			let length: CGFloat
			/// Interior width at interface with cabin, ratio to exterior width
			let widthAtCabin: CGFloat
			/// Interior width at tail tip, ratio to exterior width
			let widthAtEnd: CGFloat
		}
	}
}

// MARK: - Supported

extension AircraftGeometry.Interior {
	/// Airbus A320 family. Interior = exterior − wall on all sides (ratios).
	static let a320 = Self(
		exterior: .a320,
		wallWidth: 0.032,
		seatWallPadding: 0.014,
		cellGeometries: .a320
	)
}

extension AircraftGeometry.Interior.Cabin.SeatGeometry {
	/// Values as ratios to exterior width.
	static let a320 = Self(
		width: 0.128,
		depth: 0.17,
		baseWidth: 0.118,
		baseDepth: 0.106,
		baseDepthStartOffset: 0.002,
		foldWidth: 0.118,
		foldDepth: 0.002,
		backrestBaseWidth: 0.118,
		backrestDepth: 0.054,
		backrestHeadrestLowerXOffset: 0.002,
		backrestHeadrestLowerYOffsetFromBase: 0.02,
		backrestHeadrestWidth: 0.128,
		backrestHeadrestCenterBaseOffset: 0.032,
		backrestHeadrestUpperXOffset: 0.016,
		backrestHeadrestUpperYOffsetFromBase: 0.054,
		backrestPlateDepth: 0.004,
		backrestPlateArcOffsetYFromBase: 0.038,
		backrestPlateTopOffsetYFromBase: 0.048
	)
}

extension AircraftGeometry.Interior.Cabin.SeatArmrestGeometry {
	/// Values as ratios to exterior width.
	static let a320 = Self(
		width: 0.01,
		depth: 0.104,
		centerOffsetToSeatCenter: 0.012
	)
}

extension AircraftGeometry.Interior.Cabin.DoorGeometry {
	/// Ratios to exterior width.
	static let a320 = Self(
		width: 0.032,
		lengthAlongCabin: 0.196
	)
}

extension AircraftGeometry.Interior.Cabin.CellGeometries {
	/// Airbus A320: seat, aisle, door; others nil or nominal.
	static let a320 = Self(
		seat: .a320,
		seatArmRest: .a320,
		door: .a320,
		lavatory: nil,
		galley: nil,
		empty: nil,
		amenity: nil
	)
}
