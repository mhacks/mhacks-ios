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


extension Event {
	
	var notification : UILocalNotification?
	{
		return UIApplication.shared.scheduledLocalNotifications?.filter { $0.userInfo?["id"] as? String == ID }.first
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
