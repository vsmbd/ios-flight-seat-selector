//
//  SeatLayer.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import UIKit
import UIKitCore

// MARK: - SeatLayer

final class SeatLayer: CAShapeLayer {
	// MARK: + Private scope

	private var seat: CabinLayout.SeatDefinition
	private var isSelected: Bool = false

	private lazy var labelLayer: CATextLayer = {
		let layer = CATextLayer()
		layer.fontSize = 14
		layer.alignmentMode = .center
		layer.contentsScale = UIScreen.main.scale
		if #available(iOS 13.0, *) {
			layer.foregroundColor = UIColor.label.cgColor
		} else {
			layer.foregroundColor = UIColor.black.cgColor
		}
		return layer
	}()

	// MARK: + Init

	init(seat: CabinLayout.SeatDefinition) {
		self.seat = seat
		super.init()
		setup()
	}

	override init(layer: Any) {
		guard let layer = layer as? Self else {
			fatalError("")
		}

		self.seat = layer.seat
		super.init(layer: layer)
		setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) not supported")
	}

	// MARK: + Setup

	private func setup() {
		// Set initial size and shape (in points, will be scaled by context)
		let seatSize = CGSize(
			width: seat.geometry.width * 100,
			height: seat.geometry.depth * 100
		)

		self.bounds = CGRect(origin: .zero, size: seatSize)

		// Create seat shape with rounded corners
		let seatPath = UIBezierPath(
			roundedRect: self.bounds,
			cornerRadius: seat.geometry.cornerRadius * 100
		)
		self.path = seatPath.cgPath

		// Apply colors based on seat type and status
		updateAppearance(animated: false)

		// Add label for seat letter
		labelLayer.frame = self.bounds
		labelLayer.string = seat.column
		addSublayer(labelLayer)

		// Add subtle shadow for depth
		self.shadowColor = UIColor.black.cgColor
		self.shadowOffset = CGSize(width: 0, height: 2)
		self.shadowRadius = 2
		self.shadowOpacity = 0.1
	}

	// MARK: + Public API

	/// Update seat position based on rendering context
	func updatePosition(context: RenderingContext) {
		let viewPoint = context.toViewCoordinates(seat.geometry.center)
		position = viewPoint

		// Scale line width based on zoom
		lineWidth = max(0.5, min(2.0, 1.0 / context.scale))

		// Scale label font
		labelLayer.fontSize = 14 * context.scale
	}

	/// Update seat data model
	func updateSeat(_ newSeat: CabinLayout.SeatDefinition) {
		seat = newSeat
		updateAppearance(animated: false)
	}

	// MARK: + Appearance

	private func updateAppearance(animated: Bool) {
		let colors = colorsForState()

		if animated {
			// Animate color changes
			let bgAnimation = CABasicAnimation(keyPath: "fillColor")
			bgAnimation.fromValue = fillColor
			bgAnimation.toValue = colors.fill
			bgAnimation.duration = 0.25
			add(bgAnimation, forKey: "fillColor")

			let strokeAnimation = CABasicAnimation(keyPath: "strokeColor")
			strokeAnimation.fromValue = strokeColor
			strokeAnimation.toValue = colors.stroke
			strokeAnimation.duration = 0.25
			add(strokeAnimation, forKey: "strokeColor")
		}

		fillColor = colors.fill
		strokeColor = colors.stroke
		lineWidth = 1.0

		labelLayer.foregroundColor = colors.text
	}

	private func colorsForState() -> (fill: CGColor, stroke: CGColor, text: CGColor) {
		if isSelected {
			return (
				UIColor.systemGreen.cgColor,
				UIColor.systemGreen.cgColor,
				UIColor.white.cgColor
			)
		}

		if !seat.isAvailable {
			if #available(iOS 13.0, *) {
				return (
					UIColor.systemGray4.cgColor,
					UIColor.systemGray3.cgColor,
					UIColor.systemGray.cgColor
				)
			} else {
				return (
					UIColor(white: 0.82, alpha: 1.0).cgColor, // systemGray4 equivalent
					UIColor(white: 0.78, alpha: 1.0).cgColor, // systemGray3 equivalent
					UIColor.darkGray.cgColor
				)
			}
		}

		// Color based on cabin section
		switch seat.sectionType {
		case .clubEurope:
			return (
				UIColor.systemBlue.withAlphaComponent(0.15).cgColor,
				UIColor.systemBlue.cgColor,
				UIColor.systemBlue.cgColor
			)

		case .exitRow:
			return (
				UIColor.systemGreen.withAlphaComponent(0.15).cgColor,
				UIColor.systemGreen.cgColor,
				UIColor.systemGreen.cgColor
			)

		case .euroTraveller:
			if #available(iOS 13.0, *) {
				return (
					UIColor.systemGray6.cgColor,
					UIColor.systemGray3.cgColor,
					UIColor.label.cgColor
				)
			} else {
				return (
					UIColor(white: 0.95, alpha: 1.0).cgColor, // systemGray6 equivalent
					UIColor(white: 0.78, alpha: 1.0).cgColor, // systemGray3 equivalent
					UIColor.black.cgColor
				)
			}
		}
	}

	// MARK: + Selection

	func setSelected(_ selected: Bool, animated: Bool, animator: ProgressAnimator) {
		guard isSelected != selected else { return }
		isSelected = selected

		if animated {
			// Animate with shared animator
			let startScale = transform.m11
			let targetScale: CGFloat = selected ? 1.1 : 1.0

			animator.start(
				timingFunction: .easeInEaseOut(0.3),
				progress: { [weak self] progress in
					guard let self = self else { return }

					// Scale animation
					let scale = startScale + (targetScale - startScale) * progress
					self.transform = CATransform3DMakeScale(scale, scale, 1.0)

					// Update colors mid-animation
					if progress > 0.5 {
						self.updateAppearance(animated: false)
					}
				},
				completion: { [weak self] in
					self?.updateAppearance(animated: false)
				}
			)
		} else {
			updateAppearance(animated: false)
			transform = selected ? CATransform3DMakeScale(1.1, 1.1, 1.0) : CATransform3DIdentity
		}
	}
}
