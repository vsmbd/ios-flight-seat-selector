//
//  ColorCompatibility.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 12/02/26.
//

import UIKit

// MARK: - Color Compatibility

/// iOS 12-compatible color palette matching iOS 13+ system colors
extension UIColor {
	/// systemGray equivalent (white: 0.56)
	static var compatibleGray: UIColor {
		if #available(iOS 13.0, *) {
			return .systemGray
		} else {
			return UIColor(white: 0.56, alpha: 1.0)
		}
	}

	/// systemGray2 equivalent (white: 0.68)
	static var compatibleGray2: UIColor {
		if #available(iOS 13.0, *) {
			return .systemGray2
		} else {
			return UIColor(white: 0.68, alpha: 1.0)
		}
	}

	/// systemGray3 equivalent (white: 0.78)
	static var compatibleGray3: UIColor {
		if #available(iOS 13.0, *) {
			return .systemGray3
		} else {
			return UIColor(white: 0.78, alpha: 1.0)
		}
	}

	/// systemGray4 equivalent (white: 0.82)
	static var compatibleGray4: UIColor {
		if #available(iOS 13.0, *) {
			return .systemGray4
		} else {
			return UIColor(white: 0.82, alpha: 1.0)
		}
	}

	/// systemGray5 equivalent (white: 0.86)
	static var compatibleGray5: UIColor {
		if #available(iOS 13.0, *) {
			return .systemGray5
		} else {
			return UIColor(white: 0.86, alpha: 1.0)
		}
	}

	/// systemGray6 equivalent (white: 0.95)
	static var compatibleGray6: UIColor {
		if #available(iOS 13.0, *) {
			return .systemGray6
		} else {
			return UIColor(white: 0.95, alpha: 1.0)
		}
	}
}
