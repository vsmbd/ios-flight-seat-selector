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

// MARK: - Color Reference

/*
 System Gray Color Mapping (iOS 13+):
 
 systemGray  = UIColor(white: 0.56, alpha: 1.0)  // #8E8E93
 systemGray2 = UIColor(white: 0.68, alpha: 1.0)  // #AEAEB2
 systemGray3 = UIColor(white: 0.78, alpha: 1.0)  // #C7C7CC
 systemGray4 = UIColor(white: 0.82, alpha: 1.0)  // #D1D1D6
 systemGray5 = UIColor(white: 0.86, alpha: 1.0)  // #E5E5EA
 systemGray6 = UIColor(white: 0.95, alpha: 1.0)  // #F2F2F7
 
 Usage in this app:
 - Fuselage outline: systemGray4
 - Seat borders (available): systemGray3
 - Seat backgrounds (available): systemGray6
 - Occupied seats: systemGray4 fill, systemGray3 border
 - Galley: systemGray4 fill, systemGray3 border
 - Door: systemGray2 stroke
 */
