//
//  UIColor+Blending.swift
//  FlightSeatSelector
//
//  Created by vsmbd on 21/03/26.
//

import UIKit

extension UIColor {
	/// Linear sRGB blend: `amount` 0 → `self`, 1 → `color`. Falls back to `self` if components are not available.
	func blended(towards color: UIColor, amount: CGFloat) -> UIColor {
		let blendAmount = min(1, max(0, amount))
		var sourceRed: CGFloat = 0
		var sourceGreen: CGFloat = 0
		var sourceBlue: CGFloat = 0
		var sourceAlpha: CGFloat = 0
		var targetRed: CGFloat = 0
		var targetGreen: CGFloat = 0
		var targetBlue: CGFloat = 0
		var targetAlpha: CGFloat = 0
		guard getRed(&sourceRed, green: &sourceGreen, blue: &sourceBlue, alpha: &sourceAlpha),
			  color.getRed(&targetRed, green: &targetGreen, blue: &targetBlue, alpha: &targetAlpha) else {
			return self
		}
		return UIColor(
			red: sourceRed + (targetRed - sourceRed) * blendAmount,
			green: sourceGreen + (targetGreen - sourceGreen) * blendAmount,
			blue: sourceBlue + (targetBlue - sourceBlue) * blendAmount,
			alpha: sourceAlpha + (targetAlpha - sourceAlpha) * blendAmount
		)
	}
}
