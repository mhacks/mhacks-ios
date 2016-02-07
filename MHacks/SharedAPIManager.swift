//
//  SharedAPIManager.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

extension APIManager
{
	// MARK: - Helpers
	func showNetworkIndicator()
	{
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
	}
	func hideNetworkIndicator()
	{
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	}
}

func bodyColorForColor(color: UIColor, desaturated: Bool) -> UIColor {
	
	var hue: CGFloat = 0.0
	var saturation: CGFloat = 0.0
	var brightness: CGFloat = 0.0
	var alpha: CGFloat = 0.0
	
	color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
	
	let desaturationFactor: CGFloat = desaturated ? 0.25 : 1.0
	let brightnessFactor: CGFloat = desaturated ? 1.5 : 1.0
	let alphaFactor: CGFloat = desaturated ? 0.75 : 0.95
	
	return UIColor(hue: hue, saturation: saturation * desaturationFactor, brightness: brightness * brightnessFactor, alpha: alpha * alphaFactor)
}
