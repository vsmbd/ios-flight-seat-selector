//
//  AircraftLayout+Cabin.swift
//  FlightSeatSelector
//
//
//  Created by vsmbd on 13/02/26.
//

import Foundation

// MARK: - AircraftLayout + Cabin

extension AircraftLayout {
	// MARK: ++ Cabin

	/// Full cabin: ordered list of segments. Each segment defines a row range and marketing name.
	struct Cabin: Sendable {
		/// Segments in order from front to back. Row ranges must be contiguous and non-overlapping.
		let segments: [Segment]
		/// Total number of rows (from first segment start to last segment end). Computed once at init.
		let totalRowCount: Int

		let allCells: [LayoutCell]
		let totalCellCount: Int

		init(segments: [Segment]) {
			self.segments = segments

			if let first = segments.first,
			   let last = segments.last {
				self.totalRowCount = (last.rowRange.upperBound - first.rowRange.lowerBound) + 1
				self.totalCellCount = segments.reduce(0) {
					$0 + ($1.rowRange.count * $1.columnRange.count)
				}
			} else {
				self.totalRowCount = 0
				self.totalCellCount = 0
			}

			self.allCells = segments.flatMap(\.layoutCells)
		}

		/// Segment that contains the given global row (1-based), if any.
		func segment(containing globalRow: Int) -> Segment? {
			segments.first { $0.contains(globalRow: globalRow) }
		}

		// MARK: ++ LayoutCell

		/// A single cell in the cabin grid at [row, column] with a kind (seat, aisle, etc.).
		struct LayoutCell: Sendable {
			let row: Int
			let column: Int
			let kind: Kind
			let rowStartOffset: CGFloat
			let rowWallOffset: CGFloat

			init(
				row: Int,
				column: Int,
				kind: Kind,
				rowStartOffset: CGFloat,
				rowWallOffset: CGFloat
			) {
				self.row = row
				self.column = column
				self.kind = kind
				self.rowStartOffset = rowStartOffset
				self.rowWallOffset = rowWallOffset
			}

			/// Cell variant
			enum Kind: Sendable {
				case seat
				case aisle
				case empty
				case lavatory
				case galley
				case door
				case amenity
			}
		}

		// MARK: ++ Segment

		/// A contiguous block of rows in the cabin with a single marketing name and (later) its own layout.
		/// Row indices are global (1-based). Segments are non-overlapping and contiguous across the cabin.
		struct Segment: Sendable {
			/// Identifier for this segment; presentation layer resolves to localised marketing name.
			let identifier: String
			/// Global row indices (1-based, inclusive). Non-overlapping and contiguous across segments.
			let rowRange: ClosedRange<Int>
			/// Global column indices (inclusive). Defines which columns this segment spans (e.g. seat/aisle positions).
			let columnRange: ClosedRange<Int>
			/// Grid cells for this segment, built from the builder closure at init.
			let layoutCells: [LayoutCell]

			init(
				identifier: String,
				rowRange: ClosedRange<Int>,
				columnRange: ClosedRange<Int>,
				cellBuilder: (Int, Int) -> LayoutCell
			) {
				self.identifier = identifier
				self.rowRange = rowRange
				self.columnRange = columnRange

				var cells: [LayoutCell] = []
				cells.reserveCapacity(rowRange.count * columnRange.count)
				for rowIndex in rowRange {
					for columnIndex in columnRange {
						let cell = cellBuilder(rowIndex, columnIndex)
						cells.append(cell)
					}
				}

				self.layoutCells = cells
			}

			/// Whether the given global row index (1-based) lies in this segment.
			func contains(globalRow: Int) -> Bool {
				rowRange.contains(globalRow)
			}
		}
	}
}
