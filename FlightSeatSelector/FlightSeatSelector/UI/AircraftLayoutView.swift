//
//  AircraftLayoutView.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 14/02/26.
//

import UIKit
import SwiftCore
import UIKitCore

// MARK: - AircraftLayoutView

/// Content view for the aircraft cabin layout.
/// Sized from the geometry mapping; lives inside the scroll view.
/// Uses CheckpointedView so it participates in the checkpointed hierarchy.
final class AircraftLayoutView: CheckpointedView {
	// MARK: + Private scope

	private let aircraft: Aircraft

	private var contentRect: CGRect
	private var boundsSize: CGSize

	private let fuselageLayer: AircraftLayoutLayer

	private lazy var seatTapRecognizer: UITapGestureRecognizer = {
		let recognizer = UITapGestureRecognizer(
			target: self,
			action: #selector(handleSeatTap(_:))
		)
		return recognizer
	}()

	@objc private func handleSeatTap(_ gesture: UITapGestureRecognizer) {
		measured {
			guard gesture.state == .ended else { return }
			let location = gesture.location(in: self)
			guard contentRect.contains(location) else { return }

			let pointInFuselage = layer.convert(
				location,
				to: fuselageLayer
			)
			guard fuselageLayer.bounds.contains(pointInFuselage),
				  let seat = fuselageLayer.seatIdentifier(at: pointInFuselage) else {
				return
			}

			fuselageLayer.setSelectedSeatIdentifier(seat)
			onSeatSelection?(seat)
		}
	}

	/// Called when a tap lands inside a seat rect. Not invoked for taps outside the fuselage or on non-seat areas.
	var onSeatSelection: ((SeatIdentifier) -> Void)?

	// MARK: + Default scope

	override var intrinsicContentSize: CGSize {
		boundsSize
	}

	init(
		aircraft: Aircraft,
		contentRect: CGRect,
		boundsSize: CGSize
	) {
		self.aircraft = aircraft
		self.contentRect = contentRect
		self.boundsSize = boundsSize
		self.fuselageLayer = AircraftLayoutLayer(
			contentSize: contentRect.size,
			aircraft: aircraft
		)
		super.init()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func initialize() {
		super.initialize()
		translatesAutoresizingMaskIntoConstraints = false
		isUserInteractionEnabled = true
		fuselageLayer.frame = contentRect
		layer.addSublayer(fuselageLayer)
		addGestureRecognizer(seatTapRecognizer)
	}

	override func vwLayoutSubviews() {
		super.vwLayoutSubviews()
		fuselageLayer.frame = contentRect
	}

	func update(
		contentRect: CGRect,
		boundsSize: CGSize
	) {
		self.contentRect = contentRect
		self.boundsSize = boundsSize
		fuselageLayer.setContentSize(contentRect.size)
		invalidateIntrinsicContentSize()
		setNeedsLayout()
	}
}
