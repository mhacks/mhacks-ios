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
	private static let baseURL = NSURL(string: "http://testonehack.herokuapp.com")!
	
	// Private so that nobody else can access this.
	private init() {
		// TODO: Put file path here
		// This will construct the APIManager in in the initializer.
		if let obj = NSKeyedUnarchiver.unarchiveObjectWithFile("")
		{
			// Move everything over
			print(obj)
		}
		else
		{
			// Initialize to empty, i.e. no cache exists.
		}
	}
	
	deinit {
		// TODO: Archive object to cache.
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
//		mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		if accessTokenRequired
		{
			assert(authenticator != nil, "The authenticator must be set before making a fetch or post, except for logins.")
			authenticator.addBearerAccessHeader(mutableRequest)
		}
		do
		{
			if method == .POST {
				let formData = parameters.reduce("", combine: { $0 + "\($1.0)=\($1.1)&" })
				mutableRequest.HTTPBody = formData.substringToIndex(formData.endIndex.predecessor()).dataUsingEncoding(NSUTF8StringEncoding)
			}
			else {
				mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
			}
			
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
	func postAnnouncement(announcement: Announcement, completion: (Bool) -> Void)
	{
		// TODO: Implement me
		// This function wont acquire the semaphore, but maybe do something to ask for a UI update?
		// like just call updateAnnouncements
	}
	
	// MARK: - Countdown
	private(set) var countdown = Countdown()
	private let countdownSemaphore = dispatch_semaphore_create(1)
	func updateCountdown()
	{
		updateGenerically("/v1/countdown", objectToUpdate: &countdown, notificationName: APIManager.countdownUpdateNotification, semaphoreGuard: countdownSemaphore)
	}
	
	// MARK: - Events
	private(set) var eventsOrganizer = EventOrganizer(events: [])
	private let eventsSemaphore = dispatch_semaphore_create(1)

	func updateEvents() {
		// TODO: Make sure locations are fetched already somehow
		updateGenerically("/v1/events", objectToUpdate: &eventsOrganizer, notificationName: APIManager.eventsUpdatedNotification, semaphoreGuard: eventsSemaphore)
	}
	
	// MARK: - Location
	
	private(set) var locations = [Location]()
	private let locationSemaphore = dispatch_semaphore_create(1)
	
	func updateLocations() {
		updateGenerically("/v1/locations", objectToUpdate: &locations, notificationName: APIManager.locationsUpdatedNotification, semaphoreGuard: locationSemaphore)
	}
	
	private let locationFetchSemaphore = dispatch_semaphore_create(0)
	
	func locationForID(id: String, @noescape completion: (Location?) -> Void) {
		if let location = (locations.filter { $0.ID == id }).first
		{
			completion(location)
			return
		}
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationFetchUpdated:", name: APIManager.locationsUpdatedNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationFetchUpdated:", name: APIManager.connectionFailedNotification, object: nil)
		updateLocations()
		dispatch_semaphore_wait(locationFetchSemaphore, DISPATCH_TIME_FOREVER)
		// We intentionally don't signal here again because the base value of
		// the semaphore needs to be 0
		completion(locations.filter { $0.ID == id}.first)
	}
	func locationFetchUpdated(sender: NSNotification) {
		dispatch_semaphore_signal(locationFetchSemaphore)
	}

	// TODO: Awards
	
	// MARK: - Notification Keys
	static let announcementsUpdatedNotification = "AnnouncmentsUpdatedNotification"
	static let countdownUpdateNotification = "CountdownUpdatedNotification"
	static let eventsUpdatedNotification = "EventsUpdatedNotification"
	static let locationsUpdatedNotification = "LocationsUpdatedNotification"
	static let connectionFailedNotification = "ConnectionFailure"
}

// MARK: - Authentication and User Stuff
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
	// This class should encapsulate everything about the user and save all of it
	// including whatever information the server decides to send us.
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
		
		private let authToken : String
		private var username: String
		private static let authTokenKey = "MHacksAuthenticationToken"
		private init(authToken: String) {
			self.authToken = authToken
			username = ""
		}
		
		// We make this private so that nobody can hard code in if privilege ==
		// That is an anti-pattern and we want to discourage it.
		private var privilege: Privilege { return .Hacker }
		
		class func loginWithUsername(username: String, password: String, completion: (Either<Authenticator>) -> Void)
		{
			// Add in keychain storage of authToken once received.
			APIManager.sharedManager.taskWithRoute("/v1/sessions", parameters: ["email": username, "password": password], requireAccessToken: false, usingHTTPMethod: .POST, completion: { (result: Either<Authenticator>) in
				defer { completion(result) }
				switch result {
				case .Value(let auth):
					auth.username = username
				default:
					break
				}
			})
		}
		
		// Returns false if it failed
		func addBearerAccessHeader(request: NSMutableURLRequest)
		{
			request.addValue("\(authToken)", forHTTPHeaderField: "Authentication")
		}
	}
}
extension APIManager.Authenticator : JSONCreateable, NSCoding
{
	convenience init?(JSON: [String : AnyObject])
	{
		guard let token = JSON["token"] as? String
		else
		{
			return nil
		}
		// TODO: Use JSON to perform login and create the object.
		// Also save to keychain once initialization is done.
		self.init(authToken: token)
	}
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
		SSKeychain.setPassword(authToken, forService: APIManager.Authenticator.authTokenKey, account: username)
		aCoder.encodeObject(username, forKey: APIManager.Authenticator.authTokenKey)
	}
	
	static var jsonKeys : [String] { return ["username"] }
	
	@objc convenience init?(coder aDecoder: NSCoder)
	{
		// Override default implementation to use keychain here.
		guard let username = aDecoder.valueForKey("username") as? String
		else
		{
			return nil
		}
		guard let authToken = SSKeychain.passwordForService(APIManager.Authenticator.authTokenKey, account: username)
		else {
			return nil
		}
		self.init(authToken: authToken)
		self.username = username
	}
}


// MARK: - Archiving
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
