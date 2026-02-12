//
//  AircraftCabinView.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import UIKit
import UIKitCore

// MARK: - AircraftCabinView

final class AircraftCabinView: UIView {
	// MARK: + Private scope

	// Data models
	private let layout: CabinLayout

	// Shared resources
	private let sharedAnimator = ProgressAnimator()
	private let spatialIndex = SpatialIndex()

	// Layers (sublayers handle their own rendering)
	private var contentLayer: CALayer!
	private var fuselageLayer: FuselageLayer!
	private var seatLayers: [String: SeatLayer] = [:]

	// Transform state
	private var currentScale: CGFloat = 1.0
	private var currentTranslation: CGPoint = .zero

	// Selection state
	private var selectedSeatId: String?

	// Callbacks
	var onSeatSelected: ((String) -> Void)?

	// MARK: + Init

	init(layout: CabinLayout) {
		self.layout = layout
		super.init(frame: .zero)
		setupLayers()
		setupGestures()
		buildSpatialIndex()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) not supported")
	}

	// MARK: + Lifecycle

	override func layoutSubviews() {
		super.layoutSubviews()
		updateRendering()
	}

	// MARK: + Setup

	private func setupLayers() {
		// Content layer (container)
		contentLayer = CALayer()
		contentLayer.masksToBounds = false
		layer.addSublayer(contentLayer)

		// Fuselage layer (knows only about fuselage geometry)
		fuselageLayer = FuselageLayer(
			geometry: layout.fuselage,
			bounds: layout.bounds
		)
		contentLayer.addSublayer(fuselageLayer)

		// TODO: Create seat layers (disabled for debugging)
		// for seat in layout.seats {
		//     let seatLayer = SeatLayer(seat: seat, bounds: layout.bounds)
		//     seatLayers[seat.id] = seatLayer
		//     contentLayer.addSublayer(seatLayer)
		// }
	}

	private func setupGestures() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		addGestureRecognizer(tap)

		let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		addGestureRecognizer(pan)

		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
		addGestureRecognizer(pinch)
	}

	private func buildSpatialIndex() {
		spatialIndex.clear()
		for (index, seat) in layout.seats.enumerated() {
			spatialIndex.insert(seatIndex: index, geometry: seat.geometry)
		}
	}

	// MARK: + Rendering

	/// Update all sublayers with current rendering context
	private func updateRendering() {
		let viewSize = bounds.size
		guard viewSize.width > 0, viewSize.height > 0 else { return }

		// Create rendering context (shared state)
		let context = RenderingContext(
			bounds: layout.bounds,
			viewSize: viewSize,
			scale: currentScale,
			translation: currentTranslation
		)

		// Update fuselage (it handles its own rendering)
		fuselageLayer.updatePath(context: context)

		// TODO: Update seat layers
		// for (seatId, seatLayer) in seatLayers {
		//     guard let seat = layout.seats.first(where: { $0.id == seatId }) else { continue }
		//     seatLayer.updatePosition(seat: seat, context: context)
		// }

		contentLayer.frame = bounds
	}

	// MARK: + Gestures

	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		// TODO: Re-enable seat selection
		print("Tapped at: \(gesture.location(in: self))")
	}

	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self)

		switch gesture.state {
		case .changed:
			currentTranslation.x += translation.x
			currentTranslation.y += translation.y
			gesture.setTranslation(.zero, in: self)
			setNeedsLayout()

		default:
			break
		}
	}

	@objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
		switch gesture.state {
		case .changed:
			let newScale = currentScale * gesture.scale
			currentScale = max(0.5, min(3.0, newScale))
			gesture.scale = 1.0
			setNeedsLayout()

		default:
			break
		}
	}

	// MARK: + Public API

	/// Reset view to initial state
	func resetView() {
		currentScale = 1.0
		currentTranslation = .zero
		setNeedsLayout()
	}

	/// Get shared animator (for seat selection animations)
	func animator() -> ProgressAnimator {
		sharedAnimator
	}
}
