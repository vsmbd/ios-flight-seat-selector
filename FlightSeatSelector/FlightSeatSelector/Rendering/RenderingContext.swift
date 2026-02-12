//
//  RenderingContext.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import CoreGraphics
import Foundation

// MARK: - RenderingContext

/// Minimal context shared with sublayers for coordinate transformation
struct RenderingContext: Sendable {
	let bounds: CabinBounds
	let viewSize: CGSize
	let scale: CGFloat
	let translation: CGPoint

	/// Transform cabin coordinates to view coordinates
	func toViewCoordinates(_ cabin: CabinCoordinate) -> CGPoint {
		bounds.toViewCoordinates(cabin, viewSize: viewSize, scale: scale)
	}

	/// Transform view coordinates to cabin coordinates
	func toCabinCoordinates(_ point: CGPoint) -> CabinCoordinate {
		let adjusted = CGPoint(
			x: point.x - translation.x,
			y: point.y - translation.y
		)
		return bounds.toCabinCoordinates(adjusted, viewSize: viewSize, scale: scale)
	}

	/// Create affine transform for path rendering
	func makeTransform(fuselageWidth: CGFloat, fuselageLength: CGFloat) -> CGAffineTransform {
		let scaleX = (viewSize.width * 0.8) / fuselageWidth
		let scaleY = (viewSize.height * 0.9) / fuselageLength
		let baseScale = min(scaleX, scaleY)
		let effectiveScale = baseScale * scale

		let offsetX = viewSize.width / 2 + translation.x
		let offsetY = viewSize.height * 0.05 + translation.y

		return CGAffineTransform(translationX: offsetX, y: offsetY)
			.scaledBy(x: effectiveScale, y: effectiveScale)
	}
}
