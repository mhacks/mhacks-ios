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
	case PATCH
	case DELETE
}

enum Response<T>
{
	case Value(T)
	case Error(String)
}
private let manager = APIManager()
private var initializeManagerOnce = dispatch_once_t(0)

private let archiveLocation = container.URLByAppendingPathComponent("manager.plist")

final class APIManager : NSObject
{
	private static let baseURL = NSURL(string: "http://ec2-52-70-71-221.compute-1.amazonaws.com")!
	
	// MARK: - Initializers
	
	// Private so that nobody else can access this, and sharedManager is the only hook into the 
	// APIManager
	private override init() {
		super.init()
	}
	static var sharedManager: APIManager {
		dispatch_once(&initializeManagerOnce, {
			manager.initialize()
		})
		return manager
	}
	
	private var authenticator : Authenticator? // Must be set before using this class for authenticated purposes
	
	var isLoggedIn: Bool { return authenticator != nil }
	
	var loggedInUsername: String? { return authenticator?.username }
	
	// MARK: - Helpers
	
	@warn_unused_result private func createRequestForRoute(route: String, parameters: [String: AnyObject] = [String: AnyObject](), usingHTTPMethod method: HTTPMethod = .GET) -> NSURLRequest
	{
		let URL = APIManager.baseURL.URLByAppendingPathComponent(route)
		
		let mutableRequest = NSMutableURLRequest(URL: URL)
		mutableRequest.HTTPMethod = method.rawValue
		authenticator?.addAuthorizationHeader(mutableRequest)
		do {
			if method == .POST || method == .PUT || method == .PATCH
			{
				if method == .PATCH || method == .PUT
				{
					mutableRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
				}
				let formData = parameters.reduce("", combine: { $0 + "\($1.0)=\($1.1)&" })
				mutableRequest.HTTPBody = formData.substringToIndex(formData.endIndex.predecessor()).dataUsingEncoding(NSUTF8StringEncoding)
			}
			else
			{
				if parameters.count > 0
				{
					mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
				}
			}
		} catch {
			print(error)
			mutableRequest.HTTPBody = nil
		}
		return mutableRequest.copy() as! NSURLRequest
	}
	
	private func taskWithRoute<Object: JSONCreateable>(route: String, parameters: [String: AnyObject] = [String: AnyObject](), usingHTTPMethod method: HTTPMethod = .GET, didRecurse: Bool = false, completion: (Response<Object>) -> Void)
	{
		let request = createRequestForRoute(route, parameters: parameters, usingHTTPMethod: method)
		showNetworkIndicator()
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
			defer { self.hideNetworkIndicator() }
			if let responseHeaders = (response as? NSHTTPURLResponse)?.allHeaderFields, let authToken = responseHeaders["access-token"] as? String, let client = responseHeaders["client"] as? String, let expiry = responseHeaders["expiry"] as? String
			{
				self.authenticator!.authToken = authToken
				self.authenticator!.client = client
				self.authenticator!.expiry = expiry
			}
			guard (response as? NSHTTPURLResponse)?.statusCode != 403
			else
			{
				let error = Response<Object>.Error("Authentication failed. Please login again.")
				guard let auth = self.authenticator
				else
				{
					completion(error)
					return
				}
				self.loginWithUsername(auth.username, password: auth.password, completion: {
					switch $0
					{
					case .Value(let authenticated):
						guard authenticated
						else
						{
							completion(error)
							return
						}
						if didRecurse
						{
							return
						}
						return self.taskWithRoute(route, parameters: parameters, usingHTTPMethod: method, didRecurse: true, completion: completion)
					case .Error(let errorMessage):
						completion(.Error(errorMessage))
					}
				})
				return
			}
			guard error == nil
			else {
				// The fetch failed because of a networking error
				completion(.Error(error!.localizedDescription))
				return
			}
			guard let obj = Object(data: data)
			else {
				guard let jsonData = data, let errorMessage = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: []))?["message"] as? String
				else {
					assertionFailure("Deserialization should never fail. We recover silently in production builds")
					completion(.Error("Deserialization failed"))
					return
				}
				// Couldn't create the object out of the data we recieved
				completion(.Error(errorMessage))
				return
			}
			completion(.Value(obj))
		}
		task.resume()
	}
	
	// This is only for get requests to update a particular object type
	private func updateGenerically<T: JSONCreateable>(route: String, notification: NotificationKey, semaphoreGuard: dispatch_semaphore_t, coalecser: CoalescedCallbacks, callback: CoalescedCallbacks.Callback?, objectToUpdate updater: (T) -> Bool)
	{
		if let call = callback {
			coalecser.registerCallback(call)
		}
		guard dispatch_semaphore_wait(semaphoreGuard, DISPATCH_TIME_NOW) == 0
		else {
			// A timeout occurred on the semaphore guard.
			return
		}
		taskWithRoute(route, completion: {(result: Response<T>) in
			var succeeded = false
			defer {
				dispatch_semaphore_signal(semaphoreGuard)
				coalecser.fire(succeeded)
			}
			switch result
			{
			case .Value(let newValue):
				guard updater(newValue)
				else
				{
					return
				}
				succeeded = true
				NSNotificationCenter.defaultCenter().post(notification, object: self)
			case .Error(let errorMessage):
				NSNotificationCenter.defaultCenter().post(.Failure, object: errorMessage)
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
	private let announcementCallbacks = CoalescedCallbacks()
	private let announcementsSemaphore = dispatch_semaphore_create(1)
	
	///	Updates the announcements and posts a notification on completion.
	func updateAnnouncements(callback: CoalescedCallbacks.Callback? = nil) {
		updateGenerically("/v1/announcements", notification: .AnnouncementsUpdated, semaphoreGuard: announcementsSemaphore, coalecser: announcementCallbacks, callback: callback) { (result: MyArray<Announcement>) in
			guard result._array != self.announcementBuffer._array
			else
			{
				NSNotificationCenter.defaultCenter().post(.AnnouncementsUpdated)
				return false
			}
			self.announcementBuffer = result
			return true
		}
	}
	
	///	Posts a new announcment from a sponsor or admin
	///
	///	- parameter completion:	The completion block, true on success, false on failure.
	func updateAnnouncement(announcement: Announcement, usingMethod method: HTTPMethod, completion: Bool -> Void)
	{
		let route = method == .PUT ? "/v1/update_announcement/\(announcement.ID)" : "/v1/announcements/"
		taskWithRoute(route, parameters: announcement.encodeForCreation(), usingHTTPMethod: .POST, completion: { (updatedAnnouncement: Response<Announcement>) in
			switch updatedAnnouncement
			{
			case .Value(_):
				completion(true)
			case .Error(let errorMessage):
				NSNotificationCenter.defaultCenter().post(.Failure, object: errorMessage)
				completion(false)
			}
		})
	}
	
	func deleteAnnouncement(announcementIndex: Int, completion: (Bool) -> Void)
	{
		let announcement = announcementBuffer._array[announcementIndex]
		taskWithRoute("/v1/announcements/\(announcement.ID)", usingHTTPMethod: .DELETE) { (deletedAnnouncement: Response<JSONWrapper>) in
			switch deletedAnnouncement
			{
			case .Value(_):
				self.announcementBuffer._array.removeAtIndex(announcementIndex)
				completion(true)
			case .Error(let errorMessage):
				NSNotificationCenter.defaultCenter().post(.Failure, object: errorMessage)
				completion(false)
			}
		}
	}
	
	// MARK: - Unapproved Announcements
	
	private(set) var unapprovedAnnouncements : [Announcement] {
		get { return unapprovedAnnouncementBuffer._array }
		set {
			unapprovedAnnouncementBuffer = MyArray(newValue)
		}
	}

	private var unapprovedAnnouncementBuffer = MyArray<Announcement>()
	
	private let unapprovedAnnouncementsSemaphore = dispatch_semaphore_create(1)
	private let unapprovedCallbacks = CoalescedCallbacks()
	
	func updateUnapprovedAnnouncements(callback: CoalescedCallbacks.Callback? = nil)
	{
		updateGenerically("/v1/all_announcements", notification: .UnapprovedAnnouncementsUpdated, semaphoreGuard: unapprovedAnnouncementsSemaphore, coalecser: unapprovedCallbacks, callback: callback) { (result: MyArray<Announcement>) in
			guard result._array != self.unapprovedAnnouncementBuffer._array
				else
			{
				NSNotificationCenter.defaultCenter().post(.UnapprovedAnnouncementsUpdated)
				return false
			}
			self.unapprovedAnnouncementBuffer = result
			return true
		}
	}
	
	func deleteUnapprovedAnnouncement(unapprovedAnnouncementIndex: Int, completion: (Bool) -> Void)
	{
		let announcement = unapprovedAnnouncementBuffer._array[unapprovedAnnouncementIndex]
		taskWithRoute("/v1/announcements/\(announcement.ID)", usingHTTPMethod: .DELETE) { (deletedAnnouncement: Response<JSONWrapper>) in
			switch deletedAnnouncement
			{
			case .Value(_):
				self.unapprovedAnnouncementBuffer._array.removeAtIndex(unapprovedAnnouncementIndex)
				completion(true)
			case .Error(let errorMessage):
				NSNotificationCenter.defaultCenter().post(.Failure, object: errorMessage)
				completion(false)
			}
		}
	}
	
	func approveAnnouncement(unapprovedAnnouncementIndex: Int, completion: (Bool) -> Void) {
		let announcement = unapprovedAnnouncementBuffer._array[unapprovedAnnouncementIndex]
		var jsonToSend = announcement.encodeForCreation()
		jsonToSend["is_approved"] = true
		taskWithRoute("/v1/update_announcement/\(announcement.ID)", parameters: jsonToSend, usingHTTPMethod: .POST) { (approvedAnnouncement: Response<Announcement>) in
			switch approvedAnnouncement
			{
			case .Value(announcement):
				guard announcement.approved
				else
				{
					assertionFailure("The server said the announcement was approved but in reality it wasn't")
					NSNotificationCenter.defaultCenter().post(.Failure, object: "Failed to approve announcement")
					completion(false)
					break
				}
				self.unapprovedAnnouncementBuffer._array.removeAtIndex(unapprovedAnnouncementIndex)
				completion(true)
			case .Error(let errorMessage):
				NSNotificationCenter.defaultCenter().post(.Failure, object: errorMessage)
				completion(false)
			default:
				completion(false)
				break
			}
		}
	}
	
	
	func updateAPNSToken(token: String, preference: Int = 63, method: HTTPMethod = .POST, completion: (Bool -> Void)?)
	{
		taskWithRoute("/v1/push_notif/\(method == .PUT ? "edit" : "")", parameters: ["token":  token, "preferences": "\(preference)", "is_gcm": false], usingHTTPMethod: .POST, completion: { (result: Response<JSONWrapper>) in
			switch result
			{
			case .Value(_):
				defaults.setInteger(preference, forKey: remoteNotificationPreferencesKey)
				defaults.setObject(token, forKey: remoteNotificationTokenKey)
				completion?(true)
			case .Error(let errorMessage):
				NSNotificationCenter.defaultCenter().post(.Failure, object: errorMessage)
			}
		})
	}
	
	// MARK: - Countdown
	private(set) var countdown = Countdown()
	private let countdownSemaphore = dispatch_semaphore_create(1)
	private let countdownCallbacks = CoalescedCallbacks()

	func updateCountdown(callback: CoalescedCallbacks.Callback? = nil)
	{
		updateGenerically("/v1/countdown", notification: .CountdownUpdated, semaphoreGuard: countdownSemaphore, coalecser: countdownCallbacks, callback: callback) { (result: Countdown) in
			guard result != self.countdown
				else
			{
				return false
			}
			self.countdown = result
			return true
		}
	}
	
	// MARK: - Events
	private(set) var eventsOrganizer = EventOrganizer(events: [])
	private let eventsSemaphore = dispatch_semaphore_create(1)
	private let eventsCallbacks = CoalescedCallbacks()

	func updateEvents(callback: CoalescedCallbacks.Callback? = nil) {
		updateLocations { succeeded in
			guard succeeded
			else { return }
			self.updateGenerically("/v1/events", notification: .EventsUpdated, semaphoreGuard: self.eventsSemaphore, coalecser: self.eventsCallbacks, callback: callback) { (result: EventOrganizer) in
				guard self.eventsOrganizer.allEvents != result.allEvents
					else
				{
					return false
				}
				self.eventsOrganizer = result
				return true
			}
		}
	}
	
	// MARK: - Location
	
	private(set) var locations : [Location] {
		get { return locationBuffer._array }
		set { locationBuffer = MyArray(newValue) }
	}
	private var locationBuffer = MyArray<Location>()
	private let locationSemaphore = dispatch_semaphore_create(1)
	private let locationCallbacks = CoalescedCallbacks()

	func updateLocations(callback: CoalescedCallbacks.Callback? = nil) {
		updateGenerically("/v1/locations", notification: .LocationsUpdated, semaphoreGuard: locationSemaphore, coalecser: locationCallbacks, callback: callback) { (result: MyArray<Location>) in
			self.locationBuffer = result
			return true
		}
	}
	
	
	// MARK: - Privilege
	
	func canPostAnnouncements() -> Bool {
		return authenticator?.privilege == .Sponsor || authenticator?.privilege == .Organizer || authenticator?.privilege == .Admin
	}
	
	func canEditAnnouncements() -> Bool {
		return authenticator?.privilege == .Admin
	}
	
	// MARK: - Map
	private(set) var map: Map? = nil
	private let mapSemaphore = dispatch_semaphore_create(1)
	private let mapCallbacks = CoalescedCallbacks()

	func updateMap(callback: CoalescedCallbacks.Callback? = nil) {
		
		updateGenerically("/v1/map", notification: .MapUpdated, semaphoreGuard: mapSemaphore, coalecser: mapCallbacks, callback: callback) {(result: JSONWrapper) in
			// FIXME: This is a redundancy mess, cleanup once backend works better
			var newJSON = result.JSON
			let completion = { () -> Bool in
				guard let map = Map(serialized: Serialized(JSON: newJSON)) where map != self.map
				else {
					return false
				}
				self.map = map
				return true
			}
			guard let URLString = result[Map.imageURLKey] as? String
			else {
				return false
			}
			guard self.map?.imageURL != URLString
			else {
				newJSON[Map.fileLocationKey] = self.map?.fileLocation
				return completion()
			}
			guard let URL = NSURL(string: URLString)
			else {
				return false
			}
			let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(URL, completionHandler: { downloadedImage, response, error in
				guard error == nil, let downloaded = downloadedImage
				else {
					guard completion()
					else {
						NSNotificationCenter.defaultCenter().post(.Failure, object: error?.localizedDescription ?? "Could not save map")
						return
					}
					NSNotificationCenter.defaultCenter().post(.MapUpdated)
					return
				}
				let fileURL = container.URLByAppendingPathComponent("map.png")
				do {
					let _ = try? NSFileManager.defaultManager().removeItemAtURL(fileURL)
					try NSFileManager.defaultManager().moveItemAtURL(downloaded, toURL: fileURL)
					newJSON[Map.fileLocationKey] = fileURL.absoluteString
					guard completion()
					else {
						return
					}
					NSNotificationCenter.defaultCenter().post(.MapUpdated, object: self)
				}
				catch {
					NSNotificationCenter.defaultCenter().post(.Failure, object: (error as NSError).localizedDescription)
				}
			})
			downloadTask.resume()
			return false
		}
	}
	
	// MARK: - Notification Keys
	enum NotificationKey : String {
		case AnnouncementsUpdated
		case UnapprovedAnnouncementsUpdated // FIXME: Refactor and remove this case once backend is stabilized
		case CountdownUpdated
		case EventsUpdated
		case LocationsUpdated
		case MapUpdated
		case Failure
	}
}

// MARK: - Authentication and User Stuff
extension APIManager {
	func loginWithUsername(username: String, password: String, completion: (Response<Bool>) -> Void) {
		guard !isLoggedIn
		else {
			completion(.Value(true))
			return
		}
		let request = createRequestForRoute("/v1/auth/sign_in", parameters: ["email": username, "password": password], usingHTTPMethod: .POST)
		showNetworkIndicator()
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			defer { self.hideNetworkIndicator() }
			guard error == nil
			else
			{
				// The fetch failed because of a networking error
				completion(.Error(error!.localizedDescription))
				return
			}
			guard let responseHeaders = (response as? NSHTTPURLResponse)?.allHeaderFields
			else {
				assertionFailure("Could not deserialize the response and its header fields? What is going on!?! If this wasn't an HTTP request what was it?")
				completion(.Error("Server did not respond"))
				return
			}
			
			guard let authToken = responseHeaders["access-token"] as? String, let client = responseHeaders["client"] as? String, let username = responseHeaders["uid"] as? String, let expiry = responseHeaders["expiry"] as? String, let tokenType = responseHeaders["token-type"] as? String
			else
			{
				completion(.Value(false))
				return
			}
			let JSON = try? NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: [])
			// FIXME: Make privilege more robust
			let privilege = (JSON?["data"] as? [String: AnyObject])?["roles"] as? Int ?? 0
			self.authenticator = Authenticator(authToken: authToken, client: client, username: username, password: password, expiry: expiry, tokenType: tokenType, privilege: privilege)
			completion(.Value(true))
		}
		task.resume()
	}
	func logout() {
		self.authenticator = nil
	}
	
	/// This class should encapsulate everything about the user and save all of it
	/// The implementation used here is pretty secure so there's noting to worry about
	@objc final private class Authenticator: NSObject, JSONCreateable
	{
		private enum Privilege: Int {
			case Hacker = 0
			case Sponsor =  1
			case Organizer = 2
			case Admin = 3
		}
		
		private let username: String
		private let password: String
		private var authToken: String
		private var expiry: String
		private let tokenType: String
		private var client: String
		private let privilege: Privilege
		
		private static let authTokenKey = "MHacksAuthenticationToken"
		private static let clientKey = "MHacksClientKey"
		private static let expiryKey = "expiry"
		private static let usernameKey = "username"
		private static let tokenTypeKey = "token-type"
		private static let privilegeKey = "privilege"
		private static let passwordKey = "password"
		
		private init(authToken: String, client: String, username: String, password: String, expiry: String, tokenType: String, privilege: Int) {
			self.authToken = authToken
			self.client = client
			self.username = username
			self.expiry = expiry
			self.privilege = Privilege(rawValue: privilege) ?? .Hacker
			self.tokenType = tokenType
			self.password = password
			super.init()
		}
		
		@objc convenience init?(serialized: Serialized)
		{
			return nil
		}
		
		private func addAuthorizationHeader(request: NSMutableURLRequest) {
			request.addValue("\(tokenType)", forHTTPHeaderField: "token-type")
			request.addValue("\(authToken)", forHTTPHeaderField: "access-token")
			request.addValue("\(expiry)", forHTTPHeaderField: "expiry")
			request.addValue("\(client)", forHTTPHeaderField: "client")
			request.addValue("\(username)", forHTTPHeaderField: "uid")
		}
		
		// MARK: Authenticator Archiving
		@objc func encodeWithCoder(aCoder: NSCoder) {
			aCoder.encode(privilege.rawValue, forKey: Authenticator.privilegeKey)
			aCoder.encode(username, forKey: Authenticator.usernameKey)
			aCoder.encode(expiry, forKey: Authenticator.expiryKey)
			aCoder.encode(tokenType, forKey: Authenticator.tokenTypeKey)
			SSKeychain.setPassword(authToken, forService: Authenticator.authTokenKey, account: username)
			SSKeychain.setPassword(client, forService: Authenticator.clientKey, account: username)
			SSKeychain.setPassword(password, forService: Authenticator.passwordKey, account: username)
		}
		
		@objc convenience init?(coder aDecoder: NSCoder) {
			// Override default implementation to use keychain here.
			let privilege = aDecoder.decodeIntegerForKey(Authenticator.privilegeKey)
			guard let username = aDecoder.decodeObjectForKey(Authenticator.usernameKey) as? String, let expiry = aDecoder.decodeObjectForKey(Authenticator.expiryKey) as? String, let tokenType = aDecoder.decodeObjectForKey(Authenticator.tokenTypeKey) as? String
			else {
				return nil
			}
			guard let authToken = SSKeychain.passwordForService(Authenticator.authTokenKey, account: username), let client = SSKeychain.passwordForService(Authenticator.clientKey, account: username), let password = SSKeychain.passwordForService(Authenticator.passwordKey, account: username)
			else {
				return nil
			}
			self.init(authToken: authToken, client: client, username: username, password: password, expiry: expiry, tokenType: tokenType, privilege: privilege)
		}
	}
}


// MARK: - Archiving
extension APIManager : NSCoding
{
	private func initialize() {
		guard let data = NSData(contentsOfURL: archiveLocation)
		else
		{
			return
		}
		if let obj = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? APIManager
		{
			// Move everything over
			self.countdown = obj.countdown
			NSNotificationCenter.defaultCenter().post(.CountdownUpdated, object: self)
			
			self.announcements = obj.announcements
			NSNotificationCenter.defaultCenter().post(.AnnouncementsUpdated, object: self)
			
			self.locations = obj.locations
			NSNotificationCenter.defaultCenter().post(.LocationsUpdated, object: self)
			
			self.eventsOrganizer = obj.eventsOrganizer
			NSNotificationCenter.defaultCenter().post(.EventsUpdated, object: self)
			
			self.map = obj.map
			NSNotificationCenter.defaultCenter().post(.MapUpdated, object: self)
			
			self.authenticator = obj.authenticator
		}
	}
	
	func archive() {
		do
		{
			if !archiveLocation.checkResourceIsReachableAndReturnError(nil)
			{
				try NSFileManager.defaultManager().createDirectoryAtURL(container, withIntermediateDirectories: true, attributes: nil)
			}
			let data = NSKeyedArchiver.archivedDataWithRootObject(self)
			try data.writeToURL(archiveLocation, options: [])
		}
		catch {
		}
	}
	private static let authenticatorKey = "authenticator"
	private static let locationsKey = "locations"
	private static let eventsOrganizerKey = "eventsOrganizer"
	private static let announcementsKey = "announcements"
	private static let countdownKey = "countdown"
	private static let mapKey = "map"
	
	@objc func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encode(authenticator, forKey: APIManager.authenticatorKey)
		aCoder.encode(locations, forKey: APIManager.locationsKey)
		aCoder.encode(eventsOrganizer, forKey: APIManager.eventsOrganizerKey)
		aCoder.encode(announcements, forKey: APIManager.announcementsKey)
		aCoder.encode(countdown, forKey: APIManager.countdownKey)
		aCoder.encode(map, forKey: APIManager.mapKey)
	}
	
	@objc convenience init?(coder aDecoder: NSCoder)
    {
		self.init()
		self.authenticator = aDecoder.decodeObjectForKey(APIManager.authenticatorKey) as? Authenticator
		self.map = aDecoder.decodeObjectForKey(APIManager.mapKey) as? Map
		self.locations = aDecoder.decodeObjectForKey(APIManager.locationsKey) as? [Location] ?? []
		manager.locations = locations
		self.announcements = aDecoder.decodeObjectForKey(APIManager.announcementsKey) as? [Announcement] ?? []
		self.countdown = aDecoder.decodeObjectForKey(APIManager.countdownKey) as? Countdown ?? Countdown()
		if let eventsOrganizer = aDecoder.decodeObjectForKey(APIManager.eventsOrganizerKey) as? EventOrganizer {
			self.eventsOrganizer = eventsOrganizer
		}
		else {
			self.eventsOrganizer = EventOrganizer(events: [])
		}
	}
}

extension Event {
	// Although this is a hack to resolve the dependency between Event and APIManager.sharedManager, we can improve the hackiness of this once Swift 3's new accessors come into effect (i.e. using fileprivate and private)
	convenience init?(ID: String, name: String, category: Category, locationIDs: [String], startDate: NSDate, endDate: NSDate, info: String) {
		let locations = locationIDs.flatMap { locID in
			manager.locations.filter { location in
				location.ID == Int(locID)
				// The conversion to Int here is stupid, but its the backend's fault that we need to do this!
			}
		}
		guard locations.count > 0 else { return nil }
		self.init(ID: ID, name: name, category: category, locations: locations, startDate: startDate, endDate: endDate, info: info)
	}
}
