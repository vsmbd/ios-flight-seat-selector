//
//  AircraftLayoutLayer.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 14/02/26.
//

import CoreGraphics
import UIKit

// MARK: - AircraftLayoutLayer

/// Draws the exterior fuselage silhouette: nose (cubic Bézier, blunt tip) + rectangular cabin. No tail.
/// Size = mapping.contentRect.size; gray 1 pt stroke. Coordinates: origin (0,0) = nose tip center, y toward tail.
final class AircraftLayoutLayer: CAShapeLayer {

	// MARK: + Private scope

	private var contentSize: CGSize

	private let aircraft: Aircraft

	private var geometry: AircraftGeometry {
		aircraft.geometry
	}

	private var layout: AircraftLayout {
		aircraft.layout
	}

	private var exterior: AircraftGeometry.Exterior {
		geometry.exterior
	}

	private var interior: AircraftGeometry.Interior {
		geometry.interior
	}

	/// Container for debug circles; one 4×4 red circle is added per cgPoint call.
	private let gridLayer: CALayer = {
		let layer = CALayer()
		layer.name = "debugCircles"
		return layer
	}()

	/// Fuselage path; drawn in front of debug circles.
	private let exteriorPathLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.fillColor = UIColor.wall.cgColor
		return layer
	}()

	/// Cabin path; drawn in front of debug circles.
	private let interiorPathLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.strokeColor = UIColor.black.cgColor
		layer.lineWidth = 1
		layer.fillColor = UIColor.aisle.cgColor
		return layer
	}()

	/// Cabin content (seats, armrests, etc.). Takes aircraft from this parent layer.
	private var cabinLayoutLayer: CabinLayoutLayer!

	private func configure() {
		bounds = CGRect(origin: .zero, size: contentSize)
		gridLayer.frame = bounds
		exteriorPathLayer.frame = bounds
		interiorPathLayer.frame = bounds
		cabinLayoutLayer = CabinLayoutLayer(
			aircraft: aircraft,
			valueMapper: { [weak self] in
				guard let self else { return .zero }
				return valueMapper($0)
			},
			pointMapper: { [weak self] in
				guard let self else { return .zero }
				return cgPoint($0, $1, $2)
			}
		)
		cabinLayoutLayer.frame = bounds
		insertSublayer(gridLayer, at: 0)
		insertSublayer(exteriorPathLayer, at: 1)
		insertSublayer(interiorPathLayer, at: 2)
		insertSublayer(cabinLayoutLayer, at: 3)
	}

	private func draw(
		_ point: CGPoint,
		_ color: UIColor
	) {
		return
		let circle = CAShapeLayer()
		circle.path = CGPath(
			ellipseIn: CGRect(
				x: 0,
				y: 0,
				width: 4,
				height: 4
			),
			transform: nil
		)
		circle.frame = CGRect(
			x: point.x - 2,
			y: point.y - 2,
			width: 4,
			height: 4
		)
		circle.fillColor = color.cgColor
		circle.strokeColor = nil
		gridLayer.addSublayer(circle)
	}

	private func valueMapper(_ value: CGFloat) -> CGFloat {
		guard contentSize.width > 0 else { return .zero }
		return value * contentSize.width
	}

	/// Converts (x, y) in ratio-to-exterior-width space to content-rect points. Origin top-left.
	private func cgPoint(
		_ x: CGFloat,
		_ y: CGFloat,
		_ color: UIColor = .red
	) -> CGPoint {
		guard contentSize.width > 0 else { return .zero }
		let point = CGPoint(
			x: x * contentSize.width,
			y: y * contentSize.width
		)
#if DEBUG
		draw(
			point,
			color
		)
#endif
		return point
	}

	// MARK: ++ Exterior paths

	/// Segment length ratios from ref image
	private static let noseLength: CGFloat = 765 // 765 / 640 = 1.1953125
	private static let noseTipRatioY: CGFloat = 74 / noseLength // 74 -- 74.109375
	private static let noseSecondRatioY: CGFloat = 335 / noseLength // 335 -- 334.6875
	private static let noseFirstRatioY: CGFloat = 356 / noseLength // 356 -- 356.203125

	/// Half-width ratios from ref (distance from centerline)
	private static let noseHalfWidth: CGFloat = 251
	private static let noseHalfTipRatioX: CGFloat = 96 / noseHalfWidth
	private static let noseHalfSecondRatioX: CGFloat = 127 / noseHalfWidth
	private static let noseHalfFirstRatioX: CGFloat = 28 / noseHalfWidth

	/// Appends the nose contour to `path`: left cabin–nose junction → left 2 cubics → tip quadratic → right 2 cubics → right junction (clockwise).
	private func addExteriorNose(to path: CGMutablePath) {
		let nose = exterior.nose
		let cabin = exterior.cabin

		// Ratios to exterior width
		let length = nose.length
		let width = cabin.width
		let halfWidth = width / 2

		let tipLength = length * Self.noseTipRatioY
		let secondLength = length * Self.noseSecondRatioY
		//let firstLength = length * Self.noseFirstRatioY

		let halfTipWidth = halfWidth * Self.noseHalfTipRatioX
		let halfSecondWidth = halfWidth * Self.noseHalfSecondRatioX
		let halfFirstWidth = halfWidth * Self.noseHalfFirstRatioX

		// Start left
		let leftFirstStart = cgPoint(
			0,
			length
		)
		let leftFirstEnd = cgPoint(
			halfFirstWidth,
			tipLength + secondLength
		)
		//let leftSecondStart = leftFirstEnd
		let leftSecondEnd = cgPoint(
			halfFirstWidth + halfSecondWidth,
			tipLength
		)
		let tipStart = leftSecondEnd
		// End left

		// Absolute tip of the nose
		let tip = cgPoint(
			halfWidth,
			0
		)

		// Start right
		let tipEnd = cgPoint(
			halfWidth + halfTipWidth,
			tipLength
		)
		//let rightSecondStart = tipEnd
		let rightSecondEnd = cgPoint(
			halfWidth + halfTipWidth + halfSecondWidth,
			tipLength + secondLength
		)
		//let rightFirstStart = rightSecondEnd
		let rightFirstEnd = cgPoint(
			width,
			length
		)
		// End right

		// Nose path: left first cubic → left second cubic → tip quadratic → right second cubic → right first cubic.
		path.move(to: leftFirstStart)

		path.addCurve(
			to: leftFirstEnd,
			control1: cgPoint(0.02, length * 0.71, .orange),
			control2: cgPoint(0.02, length * 0.69, .green)
		)

		path.addCurve(
			to: leftSecondEnd,
			control1: cgPoint(0.1012, 0.617, .orange),
			control2: cgPoint(0.177, 0.3825, .green)
		)

		// Quadratic control chosen so the curve passes through the tip at t = 0.5: Q(0.5) = tip ⇒ control = 2*tip - 0.5*(tipStart + tipEnd).
		let tipQuadControl = CGPoint(
			x: 2 * tip.x - 0.5 * tipStart.x - 0.5 * tipEnd.x,
			y: 2 * tip.y - 0.5 * tipStart.y - 0.5 * tipEnd.y
		)

		path.addQuadCurve(
			to: tipEnd,
			control: tipQuadControl
		)

		path.addCurve(
			to: rightSecondEnd,
			control1: cgPoint(width - 0.177, 0.3825, .orange),
			control2: cgPoint(width - 0.1012, 0.617, .green)
		)

		path.addCurve(
			to: rightFirstEnd,
			control1: cgPoint(width - 0.02, length * 0.69, .orange),
			control2: cgPoint(width - 0.02, length * 0.71, .green)
		)
	}

	/// Appends the cabin right edge to `path`: right cabin–nose junction → right cabin–tail junction (clockwise).
	/// Precondition: current point at right cabin–nose junction.
	private func addExteriorCabinRight(to path: CGMutablePath) {
		let cabin = exterior.cabin
		let cabinEndY = exterior.cabinEndOffset
		path.addLine(to: cgPoint(cabin.width, cabinEndY))
	}

	/// Appends the cabin left edge to `path`: left cabin–tail junction → left cabin–nose junction (clockwise).
	/// Precondition: current point at left cabin–tail junction.
	private func addExteriorCabinLeft(to path: CGMutablePath) {
		let nose = exterior.nose
		path.addLine(to: cgPoint(0, nose.length))
	}

	/// Appends the tail contour to `path` (clockwise from right cabin–tail to left cabin–tail).
	/// Precondition: current point at (cabin.width, cabinEndY).
	private func addExteriorTail(to path: CGMutablePath) {
		let tail = exterior.tail
		let cabin = exterior.cabin
		let cabinEndY = exterior.cabinEndOffset

		let length = tail.length
		let halfWidthAtCabin = cabin.width / 2
		let halfWidthAtEnd = tail.widthAtEnd / 2

		let tipY = cabinEndY + length

		// Right side: cabin–tail junction → tail tip right (cubic).
		let rightTip = cgPoint(halfWidthAtCabin + halfWidthAtEnd, tipY)
		path.addCurve(
			to: rightTip,
			control1: cgPoint(
				cabin.width - 0.0061,
				cabinEndY + 0.362,
				.orange
			),
			control2: cgPoint(
				cabin.width - 0.052,
				cabinEndY + 0.730,
				.green
			)
		)

		// Tail tip: right → left (line; tip is flat).
		let leftTip = cgPoint(halfWidthAtCabin - halfWidthAtEnd, tipY)
		path.addLine(to: leftTip)

		// Left side: tail tip left → left cabin–tail junction (cubic).
		path.addCurve(
			to: cgPoint(0, cabinEndY),
			control1: cgPoint(
				0.048,
				cabinEndY + 0.730,
				.orange
			),
			control2: cgPoint(
				0.0055,
				cabinEndY + 0.362,
				.green
			)
		)
	}

	// MARK: ++ Interior paths

	private func addInteriorCabinTop(to path: CGMutablePath) {
		let nose = exterior.nose
		let noseLength = nose.length
		let noseWidth = nose.widthAtCabin

		path.move(
			to: cgPoint(
				geometry.wallWidth,
				noseLength
			)
		)

		path.addLine(
			to: cgPoint(
				noseWidth - geometry.wallWidth,
				noseLength
			)
		)
	}

	private func addInteriorCabinRight(to path: CGMutablePath) {
		let nose = exterior.nose
		let noseWidth = nose.widthAtCabin

		path.addLine(
			to: cgPoint(
				noseWidth - geometry.wallWidth,
				geometry.interior.cabinEndOffset
			)
		)
	}

	private func addInteriorCabinLeft(to path: CGMutablePath) {
		path.addLine(
			to: cgPoint(
				geometry.wallWidth,
				exterior.nose.length
			)
		)
	}

	private func addInteriorTail(to path: CGMutablePath) {
		let tail = interior.tail
		let cabin = interior.cabin
		let cabinEndY = interior.cabinEndOffset

		let length = tail.length
		let halfWidthAtCabin = cabin.width / 2
		let halfWidthAtEnd = tail.widthAtEnd / 2

		let tipY = cabinEndY + length

		// Right side: cabin–tail junction → tail tip right (cubic).
		let rightTip = cgPoint(
			geometry.wallWidth + halfWidthAtCabin + halfWidthAtEnd,
			tipY
		)
		path.addCurve(
			to: rightTip,
			control1: cgPoint(
				geometry.wallWidth + cabin.width - 0.0061,
				cabinEndY + 0.362,
				.orange
			),
			control2: cgPoint(
				geometry.wallWidth + cabin.width - 0.052,
				cabinEndY + 0.730,
				.green
			)
		)

		// Tail tip: right → left (line; tip is flat).
		let leftTip = cgPoint(
			geometry.wallWidth + halfWidthAtCabin - halfWidthAtEnd,
			tipY
		)
		path.addLine(to: leftTip)

		// Left side: tail tip left → left cabin–tail junction (cubic).
		path.addCurve(
			to: cgPoint(geometry.wallWidth, cabinEndY),
			control1: cgPoint(
				0.048 + geometry.wallWidth,
				cabinEndY + 0.730,
				.orange
			),
			control2: cgPoint(
				0.0055 + geometry.wallWidth,
				cabinEndY + 0.362,
				.green
			)
		)
	}

	private func updateSublayers() {
		guard contentSize.width > 0 else {
			exteriorPathLayer.path = nil
			return
		}

		gridLayer.frame = bounds
		gridLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

		let exteriorPath = CGMutablePath()
		addExteriorNose(to: exteriorPath)
		addExteriorCabinRight(to: exteriorPath)
		addExteriorTail(to: exteriorPath)
		addExteriorCabinLeft(to: exteriorPath)
		exteriorPath.closeSubpath()

		let interiorPath = CGMutablePath()
		addInteriorCabinTop(to: interiorPath)
		addInteriorCabinRight(to: interiorPath)
		addInteriorTail(to: interiorPath)
		addInteriorCabinLeft(to: interiorPath)
		interiorPath.closeSubpath()

		exteriorPathLayer.frame = bounds
		exteriorPathLayer.path = exteriorPath

		interiorPathLayer.frame = bounds
		interiorPathLayer.path = interiorPath

		cabinLayoutLayer.frame = bounds
		//cabinLayoutLayer.updateLayout()
	}

	// MARK: + Default scope

	init(
		contentSize: CGSize,
		aircraft: Aircraft
	) {
		self.contentSize = contentSize
		self.aircraft = aircraft
		super.init()
		configure()
		updateSublayers()
	}

	override init(layer: Any) {
		let other = layer as! AircraftLayoutLayer
		self.contentSize = other.contentSize
		self.aircraft = other.aircraft
		super.init(layer: other)
		configure()
		updateSublayers()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setContentSize(_ contentSize: CGSize) {
		self.contentSize = contentSize
		bounds = CGRect(origin: .zero, size: contentSize)
		updateSublayers()
	}

	/// Point in this layer’s bounds (same space as `bounds`). Forwards into the cabin layer.
	func seatIdentifier(at point: CGPoint) -> SeatIdentifier? {
		guard bounds.contains(point) else { return nil }
		let pointInCabin = cabinLayoutLayer.convert(point, from: self)
		return cabinLayoutLayer.seatIdentifier(at: pointInCabin)
	}

	func setSelectedSeatIdentifier(_ id: SeatIdentifier?) {
		cabinLayoutLayer.setSelectedSeatIdentifier(id)
	}

	override func layoutSublayers() {
		super.layoutSublayers()
		bounds = CGRect(origin: .zero, size: contentSize)
		updateSublayers()
	}
}
