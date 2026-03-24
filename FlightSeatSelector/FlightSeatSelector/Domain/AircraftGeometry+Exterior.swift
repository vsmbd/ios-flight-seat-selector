//
//  AircraftGeometry+Exterior.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import CoreGraphics
import Foundation

// MARK: - AircraftGeometry + Exterior

extension AircraftGeometry {
	/// Entire exterior fuselage in ratio-based coordinates. Three segments: nose, cabin, tail.
	/// Exterior width is 1.0 in AircraftPoint space (hardcoded). All stored values are ratios to that width; origin top-left.
	struct Exterior: Sendable {
		/// Exterior width in aircraft coordinate space. Fixed; not configurable.
		static let width: CGFloat = 1.0

		let nose: Nose
		let cabin: Cabin
		let tail: Tail

		/// Total exterior length (nose + cabin + tail), ratio to exterior width. Set once in init.
		let totalLength: CGFloat
		/// Longitudinal offset of cabin forward bulkhead from aircraft nose, ratio. Set once in init.
		let cabinStartOffset: CGFloat
		/// Longitudinal offset of cabin aft bulkhead from aircraft nose, ratio. Set once in init.
		let cabinEndOffset: CGFloat

		init(
			nose: Nose,
			cabin: Cabin,
			tail: Tail
		) {
			self.nose = nose
			self.cabin = cabin
			self.tail = tail
			self.totalLength = nose.length + cabin.length + tail.length
			self.cabinStartOffset = nose.length
			self.cabinEndOffset = nose.length + cabin.length
		}

		// MARK: ++ Segments

		/// Nose section (forward of cabin)
		struct Nose: Sendable {
			/// Length from nose tip to cabin forward bulkhead, ratio to exterior width
			let length: CGFloat
			/// Exterior width at interface with cabin, ratio to exterior width (typically 1)
			let widthAtCabin: CGFloat
		}

		/// Constant-section cabin (passenger compartment exterior)
		struct Cabin: Sendable {
			/// Length from forward to aft cabin bulkhead, ratio to exterior width
			let length: CGFloat
			/// Exterior width (constant over cabin), ratio to exterior width (typically 1)
			let width: CGFloat
		}

		/// Tail section (aft of cabin)
		struct Tail: Sendable {
			/// Length from cabin aft bulkhead to tail, ratio to exterior width
			let length: CGFloat
			/// Exterior width at interface with cabin, ratio to exterior width (typically 1)
			let widthAtCabin: CGFloat
			/// Exterior width at tail tip, ratio to exterior width
			let widthAtEnd: CGFloat
		}
	}
}

// MARK: - Supported

extension AircraftGeometry.Exterior {
	/// Airbus A320 family. All values as ratios to exterior width (exterior width = 100 in aircraft space).
	/// Sources: 37.57 m OAL, ~3.95 m width; cabin ~27.5 m.
	static let a320 = Self(
		nose: Nose(
			length: 1.53,
			widthAtCabin: width
		),
		cabin: Cabin(
			length: 5.264,
			width: width
		),
		tail: Tail(
			length: 1.076,
			widthAtCabin: width,
			widthAtEnd: 0.744
		)
	)
}
