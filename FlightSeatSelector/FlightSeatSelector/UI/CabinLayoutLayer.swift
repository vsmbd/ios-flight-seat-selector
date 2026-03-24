//
//  CabinLayoutLayer.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 22/02/26.
//

import UIKit

// MARK: - CabinLayoutLayer

/// Renders cabin content (seats, armrests, etc.). Gets the aircraft instance from its parent AircraftLayoutLayer.
final class CabinLayoutLayer: CALayer {
	// MARK: + Private scope

	private final class SeatBatch {
		let armrestLayers: [SeatArmrestLayer]
		let seatLayers: [SeatLayer]
		let columnRange: ClosedRange<Int>

		init(
			columnRange: ClosedRange<Int>,
			seat: AircraftGeometry.Interior.Cabin.SeatGeometry,
			armrest: AircraftGeometry.Interior.Cabin.SeatArmrestGeometry,
			valueMapper: @escaping ValueMapper,
			pointMapper: @escaping PointMapper
		) {
			self.columnRange = columnRange
			
			self.seatLayers = (0..<columnRange.count)
				.map {
					_ in .init(
						seat: seat,
						armrest: armrest,
						valueMapper: valueMapper,
						pointMapper: pointMapper
					)
				}

			self.armrestLayers = (0..<columnRange.count + 1)
				.map { _ in .init() }
		}
	}

	private final class Row {
		let leftBatch: SeatBatch
		let rightBatch: SeatBatch

		init(
			leftBatch: SeatBatch,
			rightBatch: SeatBatch
		) {
			self.leftBatch = leftBatch
			self.rightBatch = rightBatch
		}
	}

	private let aircraft: Aircraft
	private let valueMapper: ValueMapper
	private let pointMapper: PointMapper

	private var geometry: AircraftGeometry {
		aircraft.geometry
	}

	private var layout: AircraftLayout {
		aircraft.layout
	}

	private let rows: [Row]
	private var selectedSeatIdentifier: SeatIdentifier?

	private func seatLayer(for id: SeatIdentifier) -> SeatLayer? {
		let rowIndex = id.row - 1
		guard rows.indices.contains(rowIndex) else { return nil }

		if (1...3).contains(id.column) == true {
			let columnIndex = id.column - 1
			let layers = rows[rowIndex].leftBatch.seatLayers
			guard layers.indices.contains(columnIndex) else { return nil }
			return layers[columnIndex]
		} else if (4...6).contains(id.column) == true {
			let columnIndex = id.column - 4
			let layers = rows[rowIndex].rightBatch.seatLayers
			guard layers.indices.contains(columnIndex) else { return nil }
			return layers[columnIndex]
		}

		return nil
	}

	private func initializeLayers() {
		for row in rows {
			row.leftBatch.armrestLayers.forEach(addSublayer)
			row.leftBatch.seatLayers.forEach(addSublayer)

			row.rightBatch.armrestLayers.forEach(addSublayer)
			row.rightBatch.seatLayers.forEach(addSublayer)
		}
	}

	/// Seat bounds in this layer’s coordinate space; `nil` if the cell is not a drawable seat at this column.
	private func seatFrame(for cell: AircraftLayout.Cabin.LayoutCell) -> CGRect? {
		guard cell.kind == .seat else { return nil }
		guard bounds.width > 0 else { return nil }

		let exteriorWidth = geometry.exterior.cabin.width
		let cabin = geometry.interior.cabin
		let seat = cabin.cellGeometries.seat
		let armrest = cabin.cellGeometries.seatArmRest
		let wallWidth = geometry.wallWidth
		let seatWallPadding = geometry.interior.seatWallPadding
		let cabinStartOffset = geometry.interior.cabinStartOffset

		let seatArmrestOverlap = (seat.width - seat.baseWidth) / 2
		let seatSize = seat.cgSize(scaled: bounds.width)

		switch cell.column {
		case 1...3:
			let columnIndex = cell.column - 1
			let cellOriginX = wallWidth + seatWallPadding
				+ ((armrest.width + seat.baseWidth) * CGFloat(columnIndex))
				+ cell.rowWallOffset
			let cellOriginY = cabinStartOffset + cell.rowStartOffset
			let seatOriginX = cellOriginX + armrest.width - seatArmrestOverlap
			let seatOriginY = cellOriginY
			let seatOrigin = pointMapper(seatOriginX, seatOriginY, .blue)
			return CGRect(origin: seatOrigin, size: seatSize)

		case 4...6:
			let columnIndex = cell.column - 4
			let cellOriginX = exteriorWidth - wallWidth - seatWallPadding
				- armrest.width
				- ((armrest.width + seat.baseWidth) * CGFloat(3 - columnIndex))
				- cell.rowWallOffset
			let cellOriginY = cabinStartOffset + cell.rowStartOffset
			let seatOriginX = cellOriginX + armrest.width - seatArmrestOverlap
			let seatOriginY = cellOriginY
			let seatOrigin = pointMapper(seatOriginX, seatOriginY, .blue)
			return CGRect(origin: seatOrigin, size: seatSize)

		default:
			return nil
		}
	}

	private func updateSublayers() {
		guard bounds.width > 0 else { return }

		let exteriorWidth = geometry.exterior.cabin.width
		let cabin = geometry.interior.cabin
		let seat = cabin.cellGeometries.seat
		let armrest = cabin.cellGeometries.seatArmRest

		let wallWidth = geometry.wallWidth
		let seatWallPadding = geometry.interior.seatWallPadding
		let cabinStartOffset = geometry.interior.cabinStartOffset

		for cell in layout.cabin.allCells {
			let row = rows[cell.row - 1]

			switch cell.column {
			case 1...3:
				let columnIndex = cell.column - 1

				let cellOriginX = wallWidth + seatWallPadding
				+ ((armrest.width + seat.baseWidth)
					* CGFloat(columnIndex))
				+ cell.rowWallOffset
				let cellOriginY = cabinStartOffset + cell.rowStartOffset
				_ = pointMapper(
					cellOriginX,
					cellOriginY,
					.brown
				)

				if let seatRect = seatFrame(for: cell) {
					row.leftBatch.seatLayers[columnIndex].frame = seatRect
					row.leftBatch.seatLayers[columnIndex].updateLayout()
				}

				let armrestLeftOriginX = cellOriginX
				let armrestLeftOriginY = cellOriginY
				+ armrest.centerOffsetToSeatCenter
				let armrestLeftOrigin = pointMapper(
					armrestLeftOriginX,
					armrestLeftOriginY,
					.purple
				)
				let armrestSize = geometry.interior.cabin
					.cellGeometries.seatArmRest.cgSize(scaled: bounds.width)
				row.leftBatch.armrestLayers[columnIndex].frame = .init(
					origin: armrestLeftOrigin,
					size: armrestSize
				)
				row.leftBatch.armrestLayers[columnIndex].updateLayout()

				if cell.column == 3 {
					let armrestRightOriginX = cellOriginX
					+ armrest.width + seat.baseWidth
					let armrestRightOriginY = cellOriginY
					+ armrest.centerOffsetToSeatCenter
					let armrestRightOrigin = pointMapper(
						armrestRightOriginX,
						armrestRightOriginY,
						.green
					)
					row.leftBatch.armrestLayers[columnIndex + 1].frame = .init(
						origin: armrestRightOrigin,
						size: armrestSize
					)
					row.leftBatch.armrestLayers[columnIndex + 1].updateLayout()
				}

			case 4...6:
				let columnIndex = cell.column - 4

				let cellOriginX = exteriorWidth - wallWidth - seatWallPadding
				- armrest.width
				- ((armrest.width + seat.baseWidth)
					* CGFloat(3 - columnIndex))
				- cell.rowWallOffset
				let cellOriginY = cabinStartOffset + cell.rowStartOffset
				_ = pointMapper(
					cellOriginX,
					cellOriginY,
					.brown
				)

				if let seatRect = seatFrame(for: cell) {
					row.rightBatch.seatLayers[columnIndex].frame = seatRect
					row.rightBatch.seatLayers[columnIndex].updateLayout()
				}

				let armrestLeftOriginX = cellOriginX
				let armrestLeftOriginY = cellOriginY
				+ armrest.centerOffsetToSeatCenter
				let armrestLeftOrigin = pointMapper(
					armrestLeftOriginX,
					armrestLeftOriginY,
					.purple
				)
				let armrestSize = geometry.interior.cabin
					.cellGeometries.seatArmRest.cgSize(scaled: bounds.width)
				row.rightBatch.armrestLayers[columnIndex].frame = .init(
					origin: armrestLeftOrigin,
					size: armrestSize
				)
				row.rightBatch.armrestLayers[columnIndex].updateLayout()

				if cell.column == 6 {
					let armrestRightOriginX = cellOriginX
					+ armrest.width + seat.baseWidth
					let armrestRightOriginY = cellOriginY
					+ armrest.centerOffsetToSeatCenter
					let armrestRightOrigin = pointMapper(
						armrestRightOriginX,
						armrestRightOriginY,
						.green
					)
					row.rightBatch.armrestLayers[columnIndex + 1].frame = .init(
						origin: armrestRightOrigin,
						size: armrestSize
					)
					row.rightBatch.armrestLayers[columnIndex + 1].updateLayout()
				}

			default:
				break
			}
		}
	}

	// MARK: + Default scope

	typealias ValueMapper = (CGFloat) -> CGFloat
	typealias PointMapper = (CGFloat, CGFloat, UIColor) -> CGPoint

	init(
		aircraft: Aircraft,
		valueMapper: @escaping ValueMapper,
		pointMapper: @escaping PointMapper
	) {
		self.aircraft = aircraft
		self.valueMapper = valueMapper
		self.pointMapper = pointMapper

		let seat = aircraft.geometry.interior.cabin
			.cellGeometries.seat
		let armrest = aircraft.geometry.interior.cabin
			.cellGeometries.seatArmRest

		let rowCount = aircraft.layout.cabin.totalRowCount
		self.rows = (0..<rowCount).map { _ in
				.init(
					leftBatch: SeatBatch(
						columnRange: 1...3,
						seat: seat,
						armrest: armrest,
						valueMapper: valueMapper,
						pointMapper: pointMapper
					),
					rightBatch: SeatBatch(
						columnRange: 4...6,
						seat: seat,
						armrest: armrest,
						valueMapper: valueMapper,
						pointMapper: pointMapper
					)
				)
		}

		super.init()
		initializeLayers()
		updateSublayers()
	}

	override init(layer: Any) {
		let other = layer as! CabinLayoutLayer
		self.aircraft = other.aircraft
		self.valueMapper = other.valueMapper
		self.pointMapper = other.pointMapper

		let seat = aircraft.geometry.interior.cabin
			.cellGeometries.seat
		let armrest = aircraft.geometry.interior.cabin
			.cellGeometries.seatArmRest

		let rowCount = aircraft.layout.cabin.totalRowCount
		self.rows = (0..<rowCount).map { _ in
				.init(
					leftBatch: SeatBatch(
						columnRange: 1...3,
						seat: seat,
						armrest: armrest,
						valueMapper: other.valueMapper,
						pointMapper: other.pointMapper
					),
					rightBatch: SeatBatch(
						columnRange: 4...6,
						seat: seat,
						armrest: armrest,
						valueMapper: other.valueMapper,
						pointMapper: other.pointMapper
					)
				)
		}

		super.init(layer: other)
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

	/// Point in this layer’s bounds. Returns the topmost seat (by sublayer order) if `point` lies inside a seat rect.
	func seatIdentifier(at point: CGPoint) -> SeatIdentifier? {
		for cell in layout.cabin.allCells.reversed() {
			guard let frame = seatFrame(for: cell), frame.contains(point) else { continue }
			return SeatIdentifier(row: cell.row, column: cell.column)
		}
		return nil
	}

	/// Single selected seat for presentation; all other seat layers show `.available`.
	func setSelectedSeatIdentifier(_ selected: SeatIdentifier?) {
		guard selected != selectedSeatIdentifier else { return }

		if let previous = selectedSeatIdentifier,
		   let previousLayer = seatLayer(for: previous) {
			previousLayer.state = .available
		}

		guard let selected,
			  let selectedLayer = seatLayer(for: selected) else {
			selectedSeatIdentifier = nil
			return
		}

		selectedLayer.state = .selected
		selectedSeatIdentifier = selected
	}
}
