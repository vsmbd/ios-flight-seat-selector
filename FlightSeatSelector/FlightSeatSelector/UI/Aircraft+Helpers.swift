//
//  Aircraft+Helpers.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 13/02/26.
//

import Foundation

// MARK: - Aircraft helpers

extension Aircraft {
	var displayName: String {
		"\(manufacturer) \(model)"
	}
}

extension AircraftGeometry.Interior.Cabin.SeatGeometry {
	func cgSize(scaled: CGFloat) -> CGSize {
		CGSize(
			width: width * scaled,
			height: depth * scaled
		)
	}
}

extension AircraftGeometry.Interior.Cabin.SeatArmrestGeometry {
	func cgSize(scaled: CGFloat) -> CGSize {
		CGSize(
			width: width * scaled,
			height: depth * scaled
		)
	}
}
