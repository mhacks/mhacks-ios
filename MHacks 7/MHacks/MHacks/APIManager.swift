//
//  APIManager.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod : String
{
	case GET
	case POST
	case PUT
}

private let manager = APIManager()
private let archiveLocation = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!) + "/manager.plist"

final class APIManager : NSObject
{
	// TODO: Put actual base URL here
	private static let baseURL = NSURL(string: "http://testonehack.herokuapp.com")!
	
	// MARK: - Initializers
	
	private var initialized = false
	
	// Private so that nobody else can access this.
	private override init() {
		super.init()
		// Try constructing the APIManager using the cache.
		// If that fails initialize to empty, i.e. no cache exists.
	}
	static var sharedManager: APIManager {
		if !manager.initialized
		{
			manager.initialize()
			locationForID = { ID in manager.locations.filter { $0.ID == ID }.first }
		}
		return manager
	}
	
	private var authenticator : Authenticator! // Must be set before using this class for authenticated purposes
	
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
			authenticator.addAuthorizationHeader(mutableRequest)
		}
		do
		{
			if method == .POST {
				let formData = parameters.reduce("", combine: { $0 + "\($1.0)=\($1.1)&" })
				mutableRequest.HTTPBody = formData.substringToIndex(formData.endIndex.predecessor()).dataUsingEncoding(NSUTF8StringEncoding)
			}
			else {
				if parameters.count > 0 {
					mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
				}
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
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
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
	private func updateGenerically<T: JSONCreateable>(route: String, objectToUpdate updater: (T) -> Void, notificationName: String, semaphoreGuard: dispatch_semaphore_t)
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
				updater(newValue)
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
	private(set) var announcements : [Announcement] {
		get { return announcementBuffer._array }
		set {
			announcementBuffer = MyArray(newValue)
		}
	}
	private var announcementBuffer = MyArray<Announcement>()
	
	private let announcementsSemaphore = dispatch_semaphore_create(1)
	///	Updates the announcements and posts a notification on completion.
	func updateAnnouncements()
	{
		updateGenerically("/v1/announcements", objectToUpdate: { self.announcementBuffer = $0 }, notificationName: APIManager.announcementsUpdatedNotification, semaphoreGuard: announcementsSemaphore)
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
		updateGenerically("/v1/countdown", objectToUpdate: { self.countdown = $0 }, notificationName: APIManager.countdownUpdateNotification, semaphoreGuard: countdownSemaphore)
	}
	
	// MARK: - Events
	private(set) var eventsOrganizer = EventOrganizer(events: [])
	private let eventsSemaphore = dispatch_semaphore_create(1)

	func updateEvents() {
		updateLocations()
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			dispatch_semaphore_wait(self.locationSemaphore, DISPATCH_TIME_FOREVER)
			dispatch_semaphore_signal(self.locationSemaphore)
			self.updateGenerically("/v1/events", objectToUpdate: { self.eventsOrganizer = $0 }, notificationName: APIManager.eventsUpdatedNotification, semaphoreGuard: self.eventsSemaphore)
		})
	}
	
	// MARK: - Location
	
	private(set) var locations : [Location] {
		get { return locationBuffer._array }
		set { locationBuffer = MyArray(newValue) }
	}
	private var locationBuffer = MyArray<Location>()
	private let locationSemaphore = dispatch_semaphore_create(1)
	
	func updateLocations() {
		updateGenerically("/v1/locations", objectToUpdate: { self.locationBuffer = $0 } , notificationName: APIManager.locationsUpdatedNotification, semaphoreGuard: locationSemaphore)
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
		guard !isLoggedIn
		else {
			completion(.Value(true))
			return
		}
		taskWithRoute("/v1/sessions", parameters: ["email": username, "password": password], requireAccessToken: false, usingHTTPMethod: .POST, completion: { (result: Either<Authenticator>) in
			switch result {
			case .Value(let auth):
				auth.username = username
				self.authenticator = auth
				completion(.Value(true))
			case .NetworkingError(let error):
				completion(.NetworkingError(error))
			case .UnknownError:
				completion(.Value(false))
			}
		})
	}
	
	/// This class should encapsulate everything about the user and save all of it
	/// The implementation used here is pretty secure so there's noting to worry about
	@objc private final class Authenticator: NSObject, JSONCreateable, NSCoding
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
		
		private var username: String
		private let authToken : String
		private static let authTokenKey = "MHacksAuthenticationToken"
		private static let usernameKey = "username"

		@objc private init(authToken: String) {
			self.authToken = authToken
			username = ""
			super.init()
		}
		
		// We make this private so that nobody can hard code in if privilege ==
		// That is an anti-pattern and we want to discourage it.
		private var privilege: Privilege { return .Hacker }
		
		func addAuthorizationHeader(request: NSMutableURLRequest) {
			request.addValue("\(authToken)", forHTTPHeaderField: "Authentication")
		}
		
		@objc convenience init?(serialized: Serialized)
		{
			guard let token = serialized["token"] as? String
				else
			{
				return nil
			}
			// TODO: Use JSON to perform login and create the object.
			// Also save to keychain once initialization is done.
			self.init(authToken: token)
		}
		
		
		// MARK: Authenticator Archiving
		@objc func encodeWithCoder(aCoder: NSCoder) {
			SSKeychain.setPassword(authToken, forService: Authenticator.authTokenKey, account: username)
			aCoder.encodeObject(username, forKey: Authenticator.usernameKey)
		}
		
		@objc convenience init?(coder aDecoder: NSCoder) {
			// Override default implementation to use keychain here.
			guard let username = aDecoder.decodeObjectForKey(Authenticator.usernameKey) as? String
			else {
				return nil
			}
			guard let authToken = SSKeychain.passwordForService(Authenticator.authTokenKey, account: username)
			else {
				return nil
			}
			self.init(authToken: authToken)
			self.username = username
		}
	}
}


// MARK: - Archiving
extension APIManager : NSCoding
{
	func initialize() {
		initialized = true
		if let obj = NSKeyedUnarchiver.unarchiveObjectWithFile(archiveLocation) as? APIManager
		{
			// Move everything over
			self.countdown = obj.countdown
			self.announcements = obj.announcements
			self.locations = obj.locations
			self.eventsOrganizer = obj.eventsOrganizer
			self.authenticator = obj.authenticator
		}
	}
	
	func archive() {
		NSKeyedArchiver.archiveRootObject(self, toFile: archiveLocation)
	}
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(authenticator, forKey: "authenticator")
		aCoder.encodeObject(locations as NSArray, forKey: "locations")
		aCoder.encodeObject(eventsOrganizer, forKey: "eventsOrganizer")
		aCoder.encodeObject(announcements as NSArray, forKey: "announcements")
		aCoder.encodeObject(countdown, forKey: "countdown")
	}
	
	@objc convenience init?(coder aDecoder: NSCoder) {
		self.init()
		guard let authenticator = aDecoder.decodeObjectForKey("authenticator") as? Authenticator, let locations = aDecoder.decodeObjectForKey("locations") as? [Location], let announcements = aDecoder.decodeObjectForKey("announcements") as? [Announcement], let countdown = aDecoder.decodeObjectForKey("countdown") as? Countdown
		else {
			return nil
		}
		locationForID = { ID in locations.filter { loc in loc.ID == ID }.first }
		guard let eventsOrganizer = aDecoder.decodeObjectForKey("eventsOrganizer") as? EventOrganizer
		else { return nil }
		self.locations = locations
		self.authenticator = authenticator
		self.countdown = countdown
		self.announcements = announcements
		self.eventsOrganizer = eventsOrganizer
	}
}
var locationForID : ((String) -> Location?)!
