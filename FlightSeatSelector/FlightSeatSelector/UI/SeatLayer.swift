//
//  SeatLayer.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 22/02/26.
//

import UIKit

// MARK: - SeatState

/// Visual state of a seat for the seat selector.
enum SeatState: Sendable {
	case available
	case selected
	case unavailable
}

// MARK: - SeatLayer

/// Renders a single seat cell as a scaling-friendly vector sprite. Bounds set by parent from SeatGeometry.
/// Two colour tones: available (selectable) and booked (occupied).
final class SeatLayer: CAShapeLayer {
	// MARK: + Private scope

	private let seat: AircraftGeometry.Interior.Cabin.SeatGeometry
	private let armrest: AircraftGeometry.Interior.Cabin.SeatArmrestGeometry

	private let valueMapper: ValueMapper
	private let pointMapper: PointMapper

	private let baseLayer: CALayer = {
		let layer = CALayer()
		return layer
	}()

	private let foldLayer: CALayer = {
		let layer = CALayer()
		return layer
	}()

	private let backrestLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		return layer
	}()

	private let headrestPlateLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		return layer
	}()

	private func initializeLayers() {
		addSublayer(baseLayer)
		addSublayer(foldLayer)
		addSublayer(backrestLayer)
		backrestLayer.addSublayer(headrestPlateLayer)
	}

	private func updateSublayers() {
		guard bounds.width > 0 else { return }

		let inset: CGFloat = 0
		let rect = bounds.insetBy(
			dx: inset,
			dy: inset
		)
		path = CGPath(
			rect: rect,
			transform: nil
		)
		fillColor = nil
		strokeColor = nil

		let seatArmrestOverlap = (seat.width - seat.baseWidth) / 2

		// Set Base's position & size
		let baseOriginX = seatArmrestOverlap
		let baseOriginY = seat.baseDepthStartOffset
		let baseOrigin = pointMapper(
			baseOriginX,
			baseOriginY,
			.red
		)
		let baseSize = CGSize(
			width: valueMapper(seat.baseWidth),
			height: valueMapper(seat.baseDepth)
		)
		baseLayer.frame = .init(
			origin: baseOrigin,
			size: baseSize
		)

		// Set Fold's position & size
		let foldOriginX = seatArmrestOverlap
		let foldOriginY = baseOriginY + seat.baseDepth
		let foldOrigin = pointMapper(
			foldOriginX,
			foldOriginY,
			.red
		)
		let foldSize = CGSize(
			width: valueMapper(seat.foldWidth),
			height: valueMapper(seat.foldDepth)
		)
		foldLayer.frame = .init(
			origin: foldOrigin,
			size: foldSize
		)

		// Set Backrest's position & size
		let backrestOriginX: CGFloat = 0
		let backrestOriginY = foldOriginY + seat.foldDepth
		let backrestOrigin = pointMapper(
			backrestOriginX,
			backrestOriginY,
			.red
		)
		let backrestSize = CGSize(
			width: valueMapper(seat.backrestHeadrestWidth),
			height: valueMapper(seat.backrestDepth)
		)
		backrestLayer.frame = CGRect(
			origin: backrestOrigin,
			size: backrestSize
		)

		// Backrest path in backrestLayer local space.
		// valueMapper(ratio) → parent (SeatLayer) space; subtract backrestOrigin → backrestLayer local.
		// y=0 in path = fold–backrest edge; headrest at opposite side (path y=backrestSize.height). Flip Y so headrest is away from SeatLayer origin.
		let backrestPath = CGMutablePath()

		func localX(_ ratio: CGFloat) -> CGFloat {
			valueMapper(ratio) - backrestOrigin.x
		}

		func localY(_ ratioY: CGFloat) -> CGFloat {
			valueMapper(ratioY) - backrestOrigin.y
		}

		let baseInset = localX(seatArmrestOverlap)
		let backrestBaseW = valueMapper(seat.baseWidth)

		let backrestHeadrestUpperY = localY(
			backrestOriginY + seat.backrestHeadrestUpperYOffsetFromBase
		)
		let backrestHeadrestLowerY = localY(
			backrestOriginY + seat.backrestHeadrestLowerYOffsetFromBase
		)

		// Fold–backrest edge (y=0 in path)
		backrestPath.move(to: CGPoint(
			x: baseInset,
			y: 0
		))
		backrestPath.addLine(to: CGPoint(
			x: baseInset + backrestBaseW,
			y: 0
		))

		// Backrest right edge: fold edge → headrest
		// AND
		// Top-right arc
		let arcTangent1RightX = localX(seat.backrestHeadrestWidth)
		let arcTangent2RightX = backrestSize.width
		- valueMapper(seat.backrestHeadrestUpperXOffset)
		backrestPath.addArc(
			tangent1End: CGPoint(
				x: arcTangent1RightX,
				y: backrestHeadrestUpperY
			),
			tangent2End: CGPoint(
				x: arcTangent2RightX,
				y: backrestHeadrestUpperY
			),
			radius: valueMapper(0.01)
		)

		// Top edge (headrest)
		let backrestHeadrestStartLeftX = localX(
			backrestOriginX + seat.backrestHeadrestUpperXOffset
		)
		backrestPath.addLine(to: CGPoint(
			x: backrestHeadrestStartLeftX,
			y: backrestHeadrestUpperY
		))

		// Top-left arc
		let arcTangent1LeftX = localX(0)
		let arcTangent2LeftX = localX(
			backrestOriginX + seat.backrestHeadrestLowerXOffset
		)
		backrestPath.addArc(
			tangent1End: CGPoint(
				x: arcTangent1LeftX,
				y: backrestHeadrestUpperY
			),
			tangent2End: CGPoint(
				x: arcTangent2LeftX,
				y: backrestHeadrestLowerY
			),
			radius: valueMapper(0.01)
		)

		// Backrest left edge: headrest → fold edge
		backrestPath.closeSubpath()

		backrestLayer.path = backrestPath

		// Headrest plate: thin band at top of backrest, rounded top corners only (square bottom).
		let plateTopY = localY(backrestOriginY + seat.backrestPlateTopOffsetYFromBase)
		let plateBottomY = localY(backrestOriginY + seat.backrestPlateTopOffsetYFromBase + seat.backrestPlateDepth)
		let plateLeftX = backrestHeadrestStartLeftX
		let plateWidth = arcTangent2RightX - backrestHeadrestStartLeftX
		let plateHeight = plateBottomY - plateTopY
		headrestPlateLayer.frame = CGRect(
			origin: CGPoint(x: plateLeftX, y: plateTopY),
			size: CGSize(width: plateWidth, height: plateHeight)
		)
		let plateRadius = min(valueMapper(0.01), plateWidth / 4, plateHeight / 2)
		let platePath = CGMutablePath()
		// Bottom-left (square) → top-left → arc → top-right → arc → bottom-right (square) → close
		platePath.move(to: CGPoint(x: 0, y: plateHeight))
		platePath.addLine(to: CGPoint(x: 0, y: plateRadius))
		platePath.addArc(
			tangent1End: CGPoint(x: 0, y: 0),
			tangent2End: CGPoint(x: plateRadius, y: 0),
			radius: plateRadius
		)
		platePath.addLine(to: CGPoint(x: plateWidth - plateRadius, y: 0))
		platePath.addArc(
			tangent1End: CGPoint(x: plateWidth, y: 0),
			tangent2End: CGPoint(x: plateWidth, y: plateRadius),
			radius: plateRadius
		)
		platePath.addLine(to: CGPoint(x: plateWidth, y: plateHeight))
		platePath.closeSubpath()
		headrestPlateLayer.path = platePath
	}

	private static var selectionGreenTint: UIColor {
		if #available(iOS 13.0, *) {
			return .systemGreen
		}
		return .green
	}

	/// How strongly the selection green is mixed into each part’s **available** base color.
	private static let selectionGreenMix: CGFloat = 0.38

	private func updateAppearance() {
		let baseColor: UIColor
		let foldColor: UIColor
		let backrestColor: UIColor

		switch state {
		case .available:
			baseColor = UIColor.Seat.Base.available
			foldColor = UIColor.Seat.Fold.available
			backrestColor = UIColor.Seat.Backrest.available

		case .selected:
			let selectionTintColor = Self.selectionGreenTint
			let selectionBlendAmount = Self.selectionGreenMix
			baseColor = UIColor.Seat.Base.available.blended(towards: selectionTintColor, amount: selectionBlendAmount)
			foldColor = UIColor.Seat.Fold.available.blended(towards: selectionTintColor, amount: selectionBlendAmount)
			backrestColor = UIColor.Seat.Backrest.available.blended(towards: selectionTintColor, amount: selectionBlendAmount)

		case .unavailable:
			baseColor = UIColor.Seat.Base.unavailable
			foldColor = UIColor.Seat.Fold.unavailable
			backrestColor = UIColor.Seat.Backrest.unavailable
		}

		baseLayer.backgroundColor = baseColor.cgColor
		foldLayer.backgroundColor = foldColor.cgColor
		backrestLayer.fillColor = backrestColor.cgColor
		headrestPlateLayer.fillColor = UIColor.Seat.HeadrestPlate.default.cgColor
	}

	// MARK: + Default scope

	typealias ValueMapper = (CGFloat) -> CGFloat
	typealias PointMapper = (CGFloat, CGFloat, UIColor) -> CGPoint

	/// Visual state; updates fill colour. Copyed in presentation layer.
	var state: SeatState = .available {
		didSet {
			updateAppearance()
		}
	}

	init(
		seat: AircraftGeometry.Interior.Cabin.SeatGeometry,
		armrest: AircraftGeometry.Interior.Cabin.SeatArmrestGeometry,
		valueMapper: @escaping ValueMapper,
		pointMapper: @escaping PointMapper
	) {
		self.seat = seat
		self.armrest = armrest
		self.valueMapper = valueMapper
		self.pointMapper = pointMapper
		super.init()
		initializeLayers()
		updateLayout()
	}

	override init(layer: Any) {
		let other = layer as! SeatLayer
		state = other.state
		seat = other.seat
		armrest = other.armrest
		self.valueMapper = other.valueMapper
		self.pointMapper = other.pointMapper
		super.init(layer: other)
		initializeLayers()
		updateLayout()
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
		updateAppearance()
	}
}
