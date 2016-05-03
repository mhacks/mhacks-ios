//
//  CoalescedCallbacks.swift
//  MHacks
//
//  Created by Manav Gabhawala on 5/4/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation

final class CoalescedCallbacks {
	typealias Callback = (Bool) -> Void
	private var callbacks = [Callback]()
	
	func registerCallback(callback: Callback) {
		callbacks.append(callback)
	}
	func fire(result: Bool) {
		callbacks.forEach { $0(result) }
		callbacks.removeAll()
	}
}
