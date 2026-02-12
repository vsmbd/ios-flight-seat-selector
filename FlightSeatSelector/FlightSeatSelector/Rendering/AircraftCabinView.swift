//
//  AircraftCabinView.swift
//  FlightSeatSelector
//
//  Main rendering view for aircraft cabin using CA/CG.
//  Renders fuselage only (seats disabled for debugging).
//

import UIKit
import UIKitCore

// MARK: - AircraftCabinView

final class AircraftCabinView: UIView {
	// MARK: + Private scope
	
	private let layout: CabinLayout
	private let sharedAnimator = ProgressAnimator()
	private let spatialIndex = SpatialIndex()
	
	private var contentLayer: CALayer!
	private var fuselageLayer: CAShapeLayer!
	
	// Transform state
	private var currentScale: CGFloat = 1.0
	private var currentTranslation: CGPoint = .zero
	
	// Callbacks
	var onSeatSelected: ((String) -> Void)?
	
	// MARK: + Init
	
	init(layout: CabinLayout) {
		self.layout = layout
		super.init(frame: .zero)
		setupLayers()
		setupGestures()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) not supported")
	}
	
	// MARK: + Lifecycle
	
	override func layoutSubviews() {
		super.layoutSubviews()
		updateLayerTransforms()
	}
	
	// MARK: + Setup
	
	private func setupLayers() {
		// Content layer holds all cabin elements
		contentLayer = CALayer()
		contentLayer.masksToBounds = false
		layer.addSublayer(contentLayer)
		
		// Fuselage outline
		fuselageLayer = CAShapeLayer()
		fuselageLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.05).cgColor
		if #available(iOS 13.0, *) {
			fuselageLayer.strokeColor = UIColor.systemGray4.cgColor
		} else {
			fuselageLayer.strokeColor = UIColor(white: 0.82, alpha: 1.0).cgColor
		}
		fuselageLayer.lineWidth = 2.0
		contentLayer.addSublayer(fuselageLayer)
	}
	
	private func setupGestures() {
		// Tap for selection
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		addGestureRecognizer(tap)
		
		// Pan for scrolling
		let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		addGestureRecognizer(pan)
		
		// Pinch for zoom
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
		addGestureRecognizer(pinch)
	}
	
	// MARK: + Layout
	
	private func updateLayerTransforms() {
		let viewSize = bounds.size
		guard viewSize.width > 0, viewSize.height > 0 else { return }
		
		// Update fuselage path
		let fuselagePath = layout.fuselage.path(bounds: layout.bounds)
		let transformedFuselagePath = CGMutablePath()
		
		// Transform fuselage to view coordinates
		let fuselageTransform = makeTransform(forViewSize: viewSize)
		transformedFuselagePath.addPath(fuselagePath, transform: fuselageTransform)
		fuselageLayer.path = transformedFuselagePath
		
		// Update content layer transform
		contentLayer.frame = bounds
	}
	
	private func makeTransform(forViewSize viewSize: CGSize) -> CGAffineTransform {
		// Calculate scale to fit fuselage in view
		let scaleX = (viewSize.width * 0.8) / layout.fuselage.width
		let scaleY = (viewSize.height * 0.9) / layout.fuselage.length
		let baseScale = min(scaleX, scaleY)
		
		let effectiveScale = baseScale * currentScale
		
		// Center in view
		let offsetX = viewSize.width / 2 + currentTranslation.x
		let offsetY = viewSize.height * 0.05 + currentTranslation.y
		
		return CGAffineTransform(translationX: offsetX, y: offsetY)
			.scaledBy(x: effectiveScale, y: effectiveScale)
	}
	
	// MARK: + Hit Testing (disabled for now)
	
	// TODO: Re-enable when seats are added back
	
	// MARK: + Gestures
	
	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		// TODO: Re-enable seat selection when seats are added back
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
			
		case .ended:
			// Optional: Add momentum/deceleration
			break
			
		default:
			break
		}
	}
	
	@objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
		switch gesture.state {
		case .changed:
			let newScale = currentScale * gesture.scale
			currentScale = max(0.5, min(3.0, newScale)) // Clamp scale
			gesture.scale = 1.0
			setNeedsLayout()
			
		default:
			break
		}
	}
	
	// MARK: + Selection (disabled for now)
	
	// TODO: Re-enable when seats are added back
	
	// MARK: + Public API
	
	func resetView() {
		currentScale = 1.0
		currentTranslation = .zero
		setNeedsLayout()
	}
}
