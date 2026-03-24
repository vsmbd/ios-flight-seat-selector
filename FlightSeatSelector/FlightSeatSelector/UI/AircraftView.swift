//
//  AircraftView.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 14/02/26.
//

import UIKit
import UIKitCore

// MARK: - AircraftView

/// Top-level aircraft view. Topmost subview is a UIScrollView.
final class AircraftView: CheckpointedView,
						  UIScrollViewDelegate {
	// MARK: + Private scope

	struct CoordinateSpace {
		let topPadding: CGFloat
		let leadPadding: CGFloat
		let trailPadding: CGFloat
		let bottomPadding: CGFloat

		let contentRect: CGRect
		let boundsRect: CGRect

		let contentAspectRatio: CGFloat
		let contentCenter: CGPoint

		init(
			topPadding: CGFloat,
			leadPadding: CGFloat,
			trailPadding: CGFloat,
			bottomPadding: CGFloat,
			boundsWidth: CGFloat,
			boundsHeight: CGFloat
		) {
			self.topPadding = topPadding
			self.leadPadding = leadPadding
			self.trailPadding = trailPadding
			self.bottomPadding = bottomPadding

			self.boundsRect = .init(
				x: 0,
				y: 0,
				width: boundsWidth,
				height: boundsHeight
			)

			let contentWidth = boundsWidth - leadPadding - trailPadding
			let contentHeight = boundsHeight - topPadding - bottomPadding

			self.contentRect = .init(
				x: leadPadding,
				y: topPadding,
				width: contentWidth,
				height: contentHeight
			)

			contentAspectRatio = contentRect.height / contentRect.width
			contentCenter = .init(
				x: contentRect.midX,
				y: contentRect.midY
			)
		}

		init(
			topPadding: CGFloat,
			leadPadding: CGFloat,
			trailPadding: CGFloat,
			bottomPadding: CGFloat,
			contentWidth: CGFloat,
			contentHeight: CGFloat
		) {
			self.topPadding = topPadding
			self.leadPadding = leadPadding
			self.trailPadding = trailPadding
			self.bottomPadding = bottomPadding

			self.contentRect = .init(
				x: leadPadding,
				y: topPadding,
				width: contentWidth,
				height: contentHeight
			)

			let boundsWidth = contentWidth + leadPadding + trailPadding
			let boundsHeight = contentHeight + topPadding + bottomPadding

			self.boundsRect = .init(
				x: 0,
				y: 0,
				width: boundsWidth,
				height: boundsHeight
			)

			contentAspectRatio = contentRect.height / contentRect.width
			contentCenter = .init(
				x: contentRect.midX,
				y: contentRect.midY
			)
		}

		func updatedBounds(
			width: CGFloat,
			height: CGFloat
		) -> Self {
			.init(
				topPadding: topPadding,
				leadPadding: leadPadding,
				trailPadding: trailPadding,
				bottomPadding: bottomPadding,
				boundsWidth: width,
				boundsHeight: height
			)
		}

		func updatedContent(
			width: CGFloat,
			height: CGFloat
		) -> Self {
			.init(
				topPadding: topPadding,
				leadPadding: leadPadding,
				trailPadding: trailPadding,
				bottomPadding: bottomPadding,
				contentWidth: width,
				contentHeight: height
			)
		}

		func convertPoint(
			_ point: CGPoint,
			other: CoordinateSpace
		) -> CGPoint? {
			guard contentRect != .zero,
				  other.contentRect != .zero else {
				return nil
			}

			guard contentRect.contains(point) else {
				return nil
			}

			guard contentAspectRatio == other.contentAspectRatio else {
				return nil
			}

			let ux = (point.x - contentRect.minX) / contentRect.width
			let uy = (point.y - contentRect.minY) / contentRect.height

			return .init(
				x: other.contentRect.minX + ux * other.contentRect.width,
				y: other.contentRect.minY + uy * other.contentRect.height
			)
		}
	}

	private let aircraft: Aircraft

	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.isScrollEnabled = true
		scrollView.minimumZoomScale = 0.5
		scrollView.maximumZoomScale = 10.0
		scrollView.delegate = self
		return scrollView
	}()

	/// Layout values from last layout pass; used to avoid recreating layout view when width unchanged.
	private var lastLayoutBoundsSize: CGSize?

	private var ui2DSpace: CoordinateSpace = .init(
		topPadding: 120,
		leadPadding: 20,
		trailPadding: 20,
		bottomPadding: 60,
		contentWidth: 0,
		contentHeight: 0
	)

	private let ref2DSpace: CoordinateSpace = .init(
		topPadding: 58,
		leadPadding: 150,
		trailPadding: 150,
		bottomPadding: 8,
		boundsWidth: 800,
		boundsHeight: 4000
	)

	/// Created when the view is fully laid out; uses scroll view width for content size.
	private lazy var aircraftLayoutView: AircraftLayoutView = {
		let layoutView = AircraftLayoutView(
			aircraft: aircraft,
			contentRect: ui2DSpace.contentRect,
			boundsSize: ui2DSpace.boundsRect.size
		)

		//layoutView.layer.borderColor = UIColor.red.cgColor
		//layoutView.layer.borderWidth = 0.5

		layoutViewWidthConstraint = layoutView
			.width(.equal(ui2DSpace.boundsRect.size.width))
		layoutViewHeightConstraint = layoutView
			.height(.equal(ui2DSpace.boundsRect.size.height))

		return layoutView
	}()

	private let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
//		view.backgroundColor = .gray
		view.clipsToBounds = true
		return view
	}()

	/// So we can update size when mapping changes.
	private var layoutViewWidthConstraint: NSLayoutConstraint?
	private var layoutViewHeightConstraint: NSLayoutConstraint?

	private func updateRects() {
		let targetWidth = scrollView.bounds.width
		guard targetWidth > 0 else { return }

		let exterior = aircraft.geometry.exterior

		guard exterior.cabin.width > 0,
			  exterior.totalLength > 0 else { return }

		let contentWidth = targetWidth - (
			ui2DSpace.leadPadding + ui2DSpace.trailPadding
		)
		let contentHeight = exterior.totalLength * contentWidth

		ui2DSpace = ui2DSpace.updatedContent(
			width: contentWidth,
			height: contentHeight
		)
	}

	private func centerContentInsetIfNeeded() {
		guard scrollView.zoomScale < 1.0 else {
			scrollView.contentInset = .zero
			return
		}

		let contentW = scrollView.contentSize.width
		let contentH = scrollView.contentSize.height
		let boundsW = scrollView.bounds.width
		let boundsH = scrollView.bounds.height

		let horizontalInset = max(0, (boundsW - contentW) / 2)
		let verticalInset = max(0, (boundsH - contentH) / 2)

		scrollView.contentInset = UIEdgeInsets(
			top: verticalInset,
			left: horizontalInset,
			bottom: verticalInset,
			right: horizontalInset
		)
	}

	private func updateAircraftLayoutConstraints() {
		aircraftLayoutView.update(
			contentRect: ui2DSpace.contentRect,
			boundsSize: ui2DSpace.boundsRect.size
		)
		layoutViewWidthConstraint?.constant = ui2DSpace.boundsRect
			.size.width
		layoutViewHeightConstraint?.constant = ui2DSpace.boundsRect
			.size.height
	}

	private func updateLayout() {
		updateAircraftLayoutConstraints()
		centerContentInsetIfNeeded()
	}

	// MARK: + Default scope

	/// Forwards to `AircraftLayoutView.onSeatSelection`.
	var onSeatSelection: ((SeatIdentifier) -> Void)? {
		get { aircraftLayoutView.onSeatSelection }
		set { aircraftLayoutView.onSeatSelection = newValue }
	}

	init(aircraft: Aircraft) {
		self.aircraft = aircraft
		super.init()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func initialize() {
		super.initialize()

		if #available(iOS 13.0, *) {
			backgroundColor = .systemBackground
		} else {
			backgroundColor = .white
		}

		embed(scrollView)

		contentView.embed(aircraftLayoutView)

		scrollView.addContentView(contentView)
	}

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		contentView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		updateLayout()
	}

	override func vwLayoutSubviews() {
		super.vwLayoutSubviews()

		if lastLayoutBoundsSize?.width == scrollView.bounds.width {
			return
		}
		updateRects()
		lastLayoutBoundsSize = ui2DSpace.boundsRect.size

		updateLayout()
	}
}
