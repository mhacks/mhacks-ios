//
//  APIManager.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MPowered. All rights reserved.
//

import Foundation

private enum HTTPMethod : String
{
	case GET
	case POST
}

private let manager = APIManager()

struct APIManager
{
	// TODO: Put actual base URL here
	private static let baseURL = NSURL(string: "")!
	
	private init () {} // So that nobody else can access this.
	
	var sharedManager: APIManager {
		return manager
	}
	var authenticator : Authenticator! // Must be set before using this class.
	
	
	private func createRequestForRoute(route: String, parameters: [String: AnyObject] = [String: AnyObject](), requireUserAccessToken accessTokenRequired: Bool = true, usingHTTPMethod method: HTTPMethod = .GET) -> NSURLRequest
	{
		let URL = APIManager.baseURL.URLByAppendingPathComponent(route)
		
		let mutableRequest = NSMutableURLRequest(URL: URL)
		mutableRequest.HTTPMethod = method.rawValue
		mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		if accessTokenRequired
		{
			assert(authenticator != nil, "The authenticator must be set before making a fetch or post, except for logins.")
			guard authenticator.addBearerAccessHeader(mutableRequest)
			else
			{
				assertionFailure("Could not add bearer access header even though it is required")
				return mutableRequest
			}
		}
		// If we couldn't add the user access header
		do
		{
			mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
		}
		catch
		{
			print(error)
			mutableRequest.HTTPBody = nil
		}
		return mutableRequest.copy() as! NSURLRequest
	}

	
	func fetch<Object: JSONCreateable>(route: String, parameters: [String: AnyObject] = [String: AnyObject](), completion: (Either<Object>) -> Void)
	{
		let request = createRequestForRoute(route, parameters: parameters)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
			// TODO: Processing
		}
		task.resume()
	}
	
	// This should actually be factored into the function above but swift's protocol extensions/generics aren't powerful enough (yet... maybe Swift 3 =) )
	func fetch<Object: JSONCreateable>(route: String, parameters: [String: AnyObject] = [String: AnyObject](), completion: (Either<[Object]>) -> Void)
	{
		let request = createRequestForRoute(route, parameters: parameters)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
			// TODO: Processing
		}
		task.resume()
	}
	
	func post(route: String, parameters: [String: AnyObject], isLoginMethod: Bool = false, completion: (Either<[String: AnyObject]>) -> Void)
	{
		let request = createRequestForRoute(route, parameters: parameters, requireUserAccessToken: !isLoginMethod, usingHTTPMethod: .POST)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
			// TODO: Processing
		}
		task.resume()
	}
}