//
//  AircraftLayout+Supported.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 14/02/26.
//

import Foundation

// MARK: - Supported

extension AircraftLayout {
	private static func rowStartOffset(row: Int) -> CGFloat {
		return switch row {
		case 1:		0.132
		case 2:		0.326
		case 3:		0.52
		case 4:		0.714
		case 5:		0.908
		case 6:		1.102
		case 7:		1.296
		case 8:		1.49
		case 9:		1.682
		case 10:	1.876
		case 11:	2.096
		case 12:	2.314
		case 13:	2.498
		case 14:	2.684
		case 15:	2.868
		case 16:	3.054
		case 17:	3.238
		case 18:	3.422
		case 19:	3.608
		case 20:	3.794
		case 21:	3.978
		case 22:	4.164
		case 23:	4.348
		case 24:	4.532
		case 25:	4.718
		case 26:	4.902
		case 27:	5.088
		case 28:	5.272
		case 29:	5.458
		case 30:	5.638
		default:	0
		}
	}

	private static func rowWallOffset(row: Int) -> CGFloat {
		return switch row {
		case 29:	0.010
		case 30:	0.021
		default:	0
		}
	}

	/// Airbus A320 family.
	static let a320 = Self(
		cabin: .init(
			segments: [
				.init(
					identifier: "business",
					rowRange: 1...12,
					columnRange: 1...6
				) { row, column in
					switch (row, column) {
					default:
							.init(
								row: row,
								column: column,
								kind: .seat,
								rowStartOffset: rowStartOffset(row: row),
								rowWallOffset: rowWallOffset(row: row)
							)
					}
				},
				.init(
					identifier: "economy",
					rowRange: 13...30,
					columnRange: 1...6
				) { row, column in
					switch (row, column) {
					default:
							.init(
								row: row,
								column: column,
								kind: .seat,
								rowStartOffset: rowStartOffset(row: row),
								rowWallOffset: rowWallOffset(row: row)
							)
					}
				}
			]
		)
	)
}
