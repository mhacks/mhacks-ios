//
//  Authenticator.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MPowered. All rights reserved.
//

import Foundation

enum Privilege {
	case Hacker // The default privilege requires no login
	case Mentor // A mentor can do TBD
	case Sponsor // A sponsor can (limited) post new announcements
	case Admin // An admin can do whatever he wants
}

struct Authenticator
{
	var privilege: Privilege { return .Hacker }
	
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