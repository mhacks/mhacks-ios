//
//  CoalescedCallbacks.swift
//  MHacks
//
//  Created by Manav Gabhawala on 5/4/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import Foundation

final class CoalescedCallbacks {
	typealias Callback = Bool -> Void
	private var callbacks = [Callback]()
	
	// A lock to make this class thread safe
	private let lock = NSLock()
	
	func registerCallback(callback: Callback) {
		lock.lock()
		defer { lock.unlock() }
		callbacks.append(callback)
	}
	func fire(result: Bool) {
		lock.lock()
		defer { lock.unlock() }
		callbacks.forEach { $0(result) }
		callbacks.removeAll()
	}
}
