//
//  SeatArmrestLayer.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 22/02/26.
//

import UIKit

// MARK: - SeatArmrestLayer

/// Renders a single armrest cell as a scaling-friendly vector sprite. Bounds set by parent from SeatArmrestGeometry.
final class SeatArmrestLayer: CAShapeLayer {
	// MARK: + Private scope

	private func initializeLayers() {
		fillColor = UIColor.Seat.Armrest.default.cgColor
		strokeColor = nil
	}

	private func updateSublayers() {
		guard bounds.width > 0 else { return }

		let inset: CGFloat = 0
		let rect = bounds.insetBy(dx: inset, dy: inset)
		let radius = min(rect.width, rect.height) * 0.4
		path = CGPath(
			roundedRect: rect,
			cornerWidth: radius,
			cornerHeight: radius,
			transform: nil
		)
	}

	// MARK: + Default scope

	override init() {
		super.init()
		initializeLayers()
		updateSublayers()
	}

	override init(layer: Any) {
		super.init(layer: layer)
		initializeLayers()
		updateSublayers()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSublayers() {
		super.layoutSublayers()
		updateSublayers()
	}

	func updateLayout() {
		updateSublayers()
	}
}
