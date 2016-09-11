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
	private let semaphore = DispatchSemaphore(value: 1)
	
	func registerCallback(_ callback: @escaping Callback) {
		semaphore.wait()
		defer { semaphore.signal() }
		callbacks.append(callback)
	}
	func fire(_ result: Bool) {
		semaphore.wait()
		defer { semaphore.signal() }
		callbacks.forEach { $0(result) }
		callbacks.removeAll()
	}
}
