//
//  Aircraft+Supported.swift
//  FlightSeatSelector
//
//  Created by Piyush Banerjee on 14/02/26.
//

import Foundation

// MARK: - Supported aircraft catalog

extension Aircraft {
	/// Currently supported aircraft. For now a single entry; later can be loaded from bundled JSON or open-source data.
	static let supported: [Self] = [
		.a320
	]

	static let a320 = Self(
		manufacturer: "Airbus",
		model: "A320",
		geometry: .a320,
		layout: .a320
	)
}
