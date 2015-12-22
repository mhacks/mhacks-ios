//
//  APIManager.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

enum HTTPMethod : String
{
	case GET
	case POST
	case PUT
}

private let manager = APIManager()

final class APIManager
{
	
	// TODO: Put actual base URL here
	private static let baseURL = NSURL(string: "")!
	
	// Private so that nobody else can access this.
	private init () {
		// TODO: Try to construct Authenticator from cache
		// TODO: Construct everything else from cache if possible.
	}
	
	static var sharedManager: APIManager {
		return manager
	}
	private var authenticator : Authenticator! // Must be set before using this class.
	
	var isLoggedIn: Bool { return authenticator != nil }
	
	// MARK: - Helpers
	
	@warn_unused_result private func createRequestForRoute(route: String, parameters: [String: AnyObject] = [String: AnyObject](), requireUserAccessToken accessTokenRequired: Bool = true, usingHTTPMethod method: HTTPMethod = .GET) -> NSURLRequest
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
	
	private func taskWithRoute<Object: JSONCreateable>(route: String, parameters: [String: AnyObject] = [String: AnyObject](), requireAccessToken accessTokenRequired: Bool = true, usingHTTPMethod method: HTTPMethod = .GET, completion: (Either<Object>) -> Void)
	{
		let request = createRequestForRoute(route, parameters: parameters, requireUserAccessToken: accessTokenRequired, usingHTTPMethod: method)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
			guard error == nil
			else
			{
				// The fetch failed because of a networking error
				completion(.NetworkingError(error!))
				return
			}
			guard let obj = Object(data: data)
			else
			{
				// Couldn't create the object out of the data we recieved
				completion(.UnknownError)
				return
			}
			completion(.Value(obj))
		}
		task.resume()
	}
	
	func canPostAnnouncements() -> Bool {
		return authenticator == nil ? false : authenticator.privilege.canPostAnnouncements()
	}
	
	
	// This is only for get requests to update a particular object type
	private func updateGenerically<T: JSONCreateable>(route: String, inout objectToUpdate object: T, notificationName: String, semaphoreGuard: dispatch_semaphore_t)
	{
		guard dispatch_semaphore_wait(semaphoreGuard, DISPATCH_TIME_NOW) == 0
		else
		{
			// A timeout occurred on the semaphore guard.
			return
		}
		taskWithRoute(route, completion: {(result: Either<T>) in
			defer { dispatch_semaphore_signal(semaphoreGuard) }
			switch result
			{
			case .Value(let newValue):
				object = newValue
				NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: self)
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
			case .UnknownError:
				// TODO: Handle this error differently?
				NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: self)
				break
			}
		})
	}
	
	
	// MARK: - Announcements
	private(set) var announcements = [Announcement]()
	private let announcementsSemaphore = dispatch_semaphore_create(1)
	///	Updates the announcements and posts a notification on completion.
	func updateAnnouncements()
	{
		updateGenerically("/v1/announcements", objectToUpdate: &announcements, notificationName: APIManager.announcementsUpdatedNotification, semaphoreGuard: announcementsSemaphore)
	}
	
	///	Posts a new announcment from a sponsor or admin
	///
	///	- parameter completion:	The completion block, true on success, false on failure.
	func postAnnouncement(completion: (Bool) -> Void)
	{
		// TODO: Implement me
	}
	
	// MARK: - Countdown
	
	private(set) var countdown = Countdown()
	private let countdownSemaphore = dispatch_semaphore_create(1)
	func updateCountdown()
	{
		updateGenerically("/v1/countdown", objectToUpdate: &countdown, notificationName: APIManager.countdownUpdateNotification, semaphoreGuard: countdownSemaphore)
	}
}

// Authentication and user stuff
extension APIManager
{
	func loginWithUsername(username: String, password: String, completion: (Either<Bool>) -> Void)
	{
		Authenticator.loginWithUsername(username, password: password) {
			switch $0
			{
			case .Value(let user):
				self.authenticator = user
				completion(.Value(true))
			case .NetworkingError(let error):
				completion(.NetworkingError(error))
			case .UnknownError:
				completion(.UnknownError)
			}
		}
	}
	final class Authenticator
	{
		private enum Privilege {
			case Hacker // The default privilege requires no login
			case Mentor // A mentor can do ?? TBD
			case Sponsor // A sponsor can (limited) post new announcements
			case Admin // An admin can do whatever he wants
			
			func canPostAnnouncements() -> Bool {
				return self == .Sponsor || self == .Admin
			}
		}
		
		// We make this private so that nobody can hard code in if privilege ==
		// That is an anti-pattern and we want to discourage it.
		private var privilege: Privilege { return .Hacker }
		
		class func loginWithUsername(username: String, password: String, completion: (Either<Authenticator>) -> Void)
		{
			// Add in keychain storage of authToken once received.
			APIManager.sharedManager.taskWithRoute("/v1/sessions", parameters: ["username": username, "password": password], requireAccessToken: false, usingHTTPMethod: .POST, completion: completion)
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
}
extension APIManager.Authenticator : JSONCreateable
{
	convenience init?(JSON: [String : AnyObject])
	{
		// TODO: Use JSON to perform login and create the object.
		self.init()
	}
	func encodeWithCoder(aCoder: NSCoder)
	{
		// TODO: Implement me
	}
	static var jsonKeys : [String] { return [] }
}

extension APIManager
{
	// MARK: - Notification Keys
	static var announcementsUpdatedNotification : String { return "AnnouncmentsUpdatedNotification" }
	static var eventsUpdatedNotification : String { return "EventsUpdatedNotification" }
	static var countdownUpdateNotification: String { return "CountdownUpdatedNotification" }
	static var connectionFailedNotification: String { return  "ConnectionFailure" }
}
extension APIManager : NSCoding
{
	@objc func encodeWithCoder(aCoder: NSCoder) {
		// TODO: Implement me
	}
	
	@objc convenience init?(coder aDecoder: NSCoder) {
		// TODO: Implement me
		self.init()
	}
}
