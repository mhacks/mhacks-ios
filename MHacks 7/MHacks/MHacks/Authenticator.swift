//
//  Authenticator.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

enum Privilege {
	case Hacker // The default privilege requires no login
	case Mentor // A mentor can do ?? TBD
	case Sponsor // A sponsor can (limited) post new announcements
	case Admin // An admin can do whatever he wants
	
	private func canPostAnnouncements() -> Bool {
		return self == .Sponsor || self == .Admin
	}
}

final class Authenticator
{
	
	// We make this private so that nobody can hard code in if privilege == 
	// That is an anti-pattern and we want to discourage it.
	private var privilege: Privilege { return .Hacker }
	
	func canPostAnnouncements() -> Bool {
		return privilege.canPostAnnouncements()
	}
	
	func loginWithUsername(username: String, password: String, completion: (Privilege) -> Void)
	{
		// Add in keychain storage of authToken once received.
	}
	
	// Returns false if it failed
	func addBearerAccessHeader(request: NSMutableURLRequest) -> Bool
	{
		let auth : String? = "" // FIXME: This is wrong
		guard let authToken = auth
		else
		{
			return false
		}
		// TODO: Ask backend for expected auth token format
		request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authentication")
		return true
	}
}

extension Authenticator : JSONCreateable
{
	convenience init?(JSON: [String : AnyObject])
	{
		// TODO: Use JSON to perform login and create the object.
		// Use semaphore to coordinate between loginWithUsername request and initializer so
		// that authenticator's initializer can fail synchronously.
		// Blocking will not be a problem because this initializer is always called on a background thread.
		self.init()
	}
}