//
//  APIManager+UIKit.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import PassKit

// These are separated into their own file so that we don't have a UIKit dependency
// on APIManager.swift, and we can reuse APIManager.swift for a TodayExtension,
// Watch App, Mac App or anything else you might imagine. On the other apps,
// the implementation of these functions can be just empty.
extension APIManager {
	// MARK: - Helpers
	func showNetworkIndicator() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	func hideNetworkIndicator() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
}
extension APIManager {
	func fetchPass(_ callback: @escaping (PKPass?) -> Void) {
		fetchPKPassAsData { response in
			switch response {
			case .value(let data):
				var error: NSError?
				let pass = PKPass(data: data, error: &error)
				guard error == nil
				else {
					NotificationCenter.default.post(name: APIManager.FailureNotification, object: error!.localizedDescription)
					callback(nil)
					return
				}
				callback(pass)
			case .error(let message):
				NotificationCenter.default.post(name: APIManager.FailureNotification, object: message)
				callback(nil)
			}
		}
	}
}


func bodyColorForColor(_ color: UIColor, desaturated: Bool) -> UIColor {
	
	var hue: CGFloat = 0.0
	var saturation: CGFloat = 0.0
	var brightness: CGFloat = 0.0
	var alpha: CGFloat = 0.0
	
	color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
	
	let desaturationFactor: CGFloat = desaturated ? 0.25 : 1.0
	let brightnessFactor: CGFloat = desaturated ? 1.0 / brightness : 1.0
	let alphaFactor: CGFloat = desaturated ? 0.75 : 0.95
	
	return UIColor(hue: hue, saturation: saturation * desaturationFactor, brightness: brightness * brightnessFactor, alpha: alpha * alphaFactor)
}

// MARK: Custom hit testing
extension UIView
{
	
	/// This beauty allows us to test whether a point in a view is actually transparent or not which means we can test for hit testing by what the user sees rather than the bounding box we would otherwise be restricted to
	///
	/// - Parameter point: The point in the view's space. This will get inverted during computation to convert to the view's bounds. Don't do any computation on the point you have, we do it here.
	/// - Returns: The alpha value for the view you call this function on with a bound of [0, 1.0] where 1.0 means maximum alpha.
	func alphaFromPoint(point: CGPoint) -> CGFloat {
		// Pixel information for point
		var pixel: [UInt8] = [0, 0, 0, 0]
		
		// Create an offscreen context to draw into so that we can fetch the pixel's information
		guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue)
			else {
				assertionFailure("Context should always be initializable. We return an alpha value in production builds instead of asserting")
				return 1.0
		}
		// Translation into context's space
		context.translateBy(x: -point.x, y: -point.y);
		
		// Render the view into the context so that the pixel's data gets filled
		layer.render(in: context)
		
		// Now the alpha is the last component inside pixel, the rest are rgb as you probably guessed.
		// Also, normalize alpha by dividing by 255.0
		return CGFloat(pixel[3]) / 255.0
	}
}
