//
//  APIManagerToday+UIKit.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation
import UIKit

extension APIManager
{
	func showNetworkIndicator()
	{
	}
	func hideNetworkIndicator()
	{
	}
}

func bodyColorForColor(_ color: UIColor, desaturated: Bool) -> UIColor {
	
	var hue: CGFloat = 0.0
	var saturation: CGFloat = 0.0
	var brightness: CGFloat = 0.0
	var alpha: CGFloat = 0.0
	
	color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
	
	let desaturationFactor: CGFloat = desaturated ? 0.75 : 1.0
	let brightnessFactor: CGFloat = desaturated ? 1.25 : 1.0
	let alphaFactor: CGFloat = desaturated ? 0.65 : 0.95
	
	return UIColor(hue: hue, saturation: saturation * desaturationFactor, brightness: brightness * brightnessFactor, alpha: alpha * alphaFactor)
}
