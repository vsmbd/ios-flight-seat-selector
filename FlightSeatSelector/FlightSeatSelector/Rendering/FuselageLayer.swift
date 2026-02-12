//
//  FuselageLayer.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import UIKit

// MARK: - FuselageLayer

final class FuselageLayer: CAShapeLayer {
	// MARK: + Private scope

	private let geometry: FuselageGeometry
	private let cabinBounds: CabinBounds

	// MARK: + Init

	init(geometry: FuselageGeometry, bounds: CabinBounds) {
		self.geometry = geometry
		self.cabinBounds = bounds
		super.init()
		setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) not supported")
	}

	// MARK: + Setup

	private func setup() {
		// Visual properties
		fillColor = UIColor.systemBlue.withAlphaComponent(0.05).cgColor
		if #available(iOS 13.0, *) {
			strokeColor = UIColor.systemGray4.cgColor
		} else {
			strokeColor = UIColor(white: 0.82, alpha: 1.0).cgColor
		}
		lineWidth = 2.0
		masksToBounds = false
	}

	// MARK: + Public API

	/// Update fuselage path based on rendering context
	func updatePath(context: RenderingContext) {
		// Generate path in cabin coordinates
		let cabinPath = geometry.path(bounds: cabinBounds)

		// Transform to view coordinates
		let transform = context.makeTransform(
			fuselageWidth: geometry.width,
			fuselageLength: geometry.length
		)

		let transformedPath = CGMutablePath()
		transformedPath.addPath(cabinPath, transform: transform)

		path = transformedPath
	}
}
