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
	case PATCH
	case DELETE
}

private let manager = { () -> APIManager in
	let m = APIManager()
	// Try constructing the APIManager using the cache.
	// If that fails initialize to empty, i.e. no cache exists.
	m.initialize()
	return m
}()

private let archiveLocation = container.URLByAppendingPathComponent("manager.plist")

final class APIManager : NSObject
{
	private static let baseURL = NSURL(string: "http://ec2-52-70-71-221.compute-1.amazonaws.com")!
	
	// MARK: - Initializers
	
	// Private so that nobody else can access this.
	private override init() {
		super.init()
		locationForID = { ID in self.locations.filter { $0.ID == ID }.first }

	}
	static var sharedManager: APIManager {
		return manager
	}
	
	private var authenticator : Authenticator! // Must be set before using this class for authenticated purposes
	
	var isLoggedIn: Bool { return authenticator != nil }
	
	var loggedInUsername: String? { return authenticator?.username }
	
	// MARK: - Helpers
	
	@warn_unused_result private func createRequestForRoute(route: String, parameters: [String: AnyObject] = [String: AnyObject](), usingHTTPMethod method: HTTPMethod = .GET) -> NSURLRequest
	{
		let URL = APIManager.baseURL.URLByAppendingPathComponent(route)
		
		let mutableRequest = NSMutableURLRequest(URL: URL)
		mutableRequest.HTTPMethod = method.rawValue
		authenticator?.addAuthorizationHeader(mutableRequest)
		do
		{
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
		}
		catch
		{
			print(error)
			mutableRequest.HTTPBody = nil
		}
		return mutableRequest.copy() as! NSURLRequest
	}
	
	private func taskWithRoute<Object: JSONCreateable>(route: String, parameters: [String: AnyObject] = [String: AnyObject](), usingHTTPMethod method: HTTPMethod = .GET, completion: (Either<Object>) -> Void)
	{
		let request = createRequestForRoute(route, parameters: parameters, usingHTTPMethod: method)
		showNetworkIndicator()
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
			defer { self.hideNetworkIndicator() }
			guard (response as? NSHTTPURLResponse)?.statusCode != 403
			else
			{
				let myError = NSError(domain: error?.domain ?? "", code: 403, userInfo: [NSLocalizedDescriptionKey : "Authentication failed. Please login again."])
				completion(.NetworkingError(myError))
				return
			}
			if let responseHeaders = (response as? NSHTTPURLResponse)?.allHeaderFields, let authToken = responseHeaders["access-token"] as? String, let client = responseHeaders["client"] as? String, let expiry = responseHeaders["expiry"] as? String
			{
				self.authenticator.authToken = authToken
				self.authenticator.client = client
				self.authenticator.expiry = expiry
			}
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
				guard let jsonData = data, let errorMessage = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: []))?["message"] as? String
				else
				{
					completion(.UnknownError)
					return
				}
				let myError = NSError(domain: error?.domain ?? "", code: 0, userInfo: [NSLocalizedDescriptionKey : errorMessage])
				// Couldn't create the object out of the data we recieved
				completion(.NetworkingError(myError))
				return
			}
			completion(.Value(obj))
		}
		task.resume()
	}
	
	// This is only for get requests to update a particular object type
	private func updateGenerically<T: JSONCreateable>(route: String, objectToUpdate updater: (T) -> Bool, notificationName: String, semaphoreGuard: dispatch_semaphore_t)
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
				guard updater(newValue)
				else
				{
					return
				}
				NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: self)
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
			case .UnknownError:
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: nil)
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
		updateGenerically("/v1/announcements", objectToUpdate: { (result: MyArray<Announcement>) in
			guard result._array != self.announcementBuffer._array
			else
			{
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.announcementsUpdatedNotification, object: nil)
				return false
			}
			self.announcementBuffer = result
			return true
			}, notificationName: APIManager.announcementsUpdatedNotification, semaphoreGuard: announcementsSemaphore)
	}
	
	///	Posts a new announcment from a sponsor or admin
	///
	///	- parameter completion:	The completion block, true on success, false on failure.
	func updateAnnouncement(announcement: Announcement, usingMethod method: HTTPMethod, completion: Bool -> Void)
	{
		let route = method == .PUT ? "/v1/update_announcement/\(announcement.ID)" : "/v1/announcements/"
		taskWithRoute(route, parameters: announcement.encodeForCreation(), usingHTTPMethod: .POST, completion: { (updatedAnnouncement: Either<Announcement>) in
			switch updatedAnnouncement
			{
			case .Value(_):
				completion(true)
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
				completion(false)
			case .UnknownError:
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: nil)
				completion(false)
			}
		})
	}
	
	func deleteAnnouncement(announcementIndex: Int, completion: (Bool) -> Void)
	{
		let announcement = announcementBuffer._array[announcementIndex]
		taskWithRoute("/v1/announcements/\(announcement.ID)", usingHTTPMethod: .DELETE) { (deletedAnnouncement: Either<JSONWrapper>) in
			switch deletedAnnouncement
			{
			case .Value(_):
				self.announcementBuffer._array.removeAtIndex(announcementIndex)
				completion(true)
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
				completion(false)
			case .UnknownError:
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: nil)
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

	func updateUnapprovedAnnouncements()
	{
		updateGenerically("/v1/all_announcements", objectToUpdate: { (result: MyArray<Announcement>) in
			guard result._array != self.unapprovedAnnouncementBuffer._array
			else
			{
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.unapprovedAnnouncementsUpdatedNotification, object: nil)
				return false
			}
			self.unapprovedAnnouncementBuffer = result
			return true
			}, notificationName: APIManager.unapprovedAnnouncementsUpdatedNotification, semaphoreGuard: unapprovedAnnouncementsSemaphore)
	}
	
	func deleteUnapprovedAnnouncement(unapprovedAnnouncementIndex: Int, completion: (Bool) -> Void)
	{
		let announcement = unapprovedAnnouncementBuffer._array[unapprovedAnnouncementIndex]
		taskWithRoute("/v1/announcements/\(announcement.ID)", usingHTTPMethod: .DELETE) { (deletedAnnouncement: Either<JSONWrapper>) in
			switch deletedAnnouncement
			{
			case .Value(_):
				self.unapprovedAnnouncementBuffer._array.removeAtIndex(unapprovedAnnouncementIndex)
				completion(true)
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
				completion(false)
			case .UnknownError:
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: nil)
				completion(false)
			}
		}
	}
	
	func approveAnnouncement(unapprovedAnnouncementIndex: Int, completion: (Bool) -> Void)
	{
		let announcement = unapprovedAnnouncementBuffer._array[unapprovedAnnouncementIndex]
		var jsonToSend = announcement.encodeForCreation()
		jsonToSend["is_approved"] = true
		taskWithRoute("/v1/update_announcement/\(announcement.ID)", parameters: jsonToSend, usingHTTPMethod: .PUT) { (approvedAnnouncement: Either<Announcement>) in
			switch approvedAnnouncement
			{
			case .Value(announcement):
				guard announcement.approved
				else
				{
					NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: nil)
					completion(false)
					break
				}
				self.unapprovedAnnouncementBuffer._array.removeAtIndex(unapprovedAnnouncementIndex)
				completion(true)
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
				completion(false)
			case .UnknownError:
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: nil)
				completion(false)
			default:
				completion(false)
				break
			}
		}
	}
	
	
	func updateAPNSToken(token: String, preference: Int = 63, method: HTTPMethod = .POST, completion: (Bool -> Void)?)
	{
		taskWithRoute("/v1/push_notif/\(method == .PUT ? "edit" : "")", parameters: ["token":  token, "preferences": "\(preference)", "is_gcm": false], usingHTTPMethod: .POST, completion: { (result: Either<JSONWrapper>) in
			switch result
			{
			case .Value(_):
				defaults.setInteger(preference, forKey: remoteNotificationPreferencesKey)
				defaults.setObject(token, forKey: remoteNotificationTokenKey)
				completion?(true)
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
			case .UnknownError:
				completion?(false)
			}
		})
	}
	
	// MARK: - Countdown
	private(set) var countdown = Countdown()
	private let countdownSemaphore = dispatch_semaphore_create(1)
	func updateCountdown()
	{
		updateGenerically("/v1/countdown", objectToUpdate: { (result: Countdown) in
			guard result != self.countdown
			else
			{
				return false
			}
			self.countdown = result
			return true
		}, notificationName: APIManager.countdownUpdateNotification, semaphoreGuard: countdownSemaphore)
	}
	
	// MARK: - Events
	private(set) var eventsOrganizer = EventOrganizer(events: [])
	private let eventsSemaphore = dispatch_semaphore_create(1)

	func updateEvents() {
		updateLocations()
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			dispatch_semaphore_wait(self.locationSemaphore, DISPATCH_TIME_FOREVER)
			dispatch_semaphore_signal(self.locationSemaphore)
			self.updateGenerically("/v1/events", objectToUpdate: { (result: EventOrganizer) in
				guard self.eventsOrganizer.allEvents != result.allEvents
				else
				{
					return false
				}
				self.eventsOrganizer = result
				return true
			}, notificationName: APIManager.eventsUpdatedNotification, semaphoreGuard: self.eventsSemaphore)
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
		updateGenerically("/v1/locations", objectToUpdate: { (result: MyArray<Location>) in
			self.locationBuffer = result
			return true
		}, notificationName: APIManager.locationsUpdatedNotification, semaphoreGuard: locationSemaphore)
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
	
	func updateMap() {
		
		updateGenerically("/v1/map", objectToUpdate: {(result: JSONWrapper) in
			var newJSON = result.JSON
			let completion = { () -> Bool in
				guard let map = Map(serialized: Serialized(JSON: newJSON)) where map != self.map
				else
				{
					return false
				}
				self.map = map
				return true
			}
			guard let URLString = result[Map.imageURLKey] as? String
			else
			{
				return false
			}
			guard self.map?.imageURL != URLString
			else
			{
				newJSON[Map.fileLocationKey] = self.map?.fileLocation
				return completion()
			}
			guard let URL = NSURL(string: URLString)
			else
			{
				return false
			}
			let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(URL, completionHandler: { downloadedImage, response, error in
				guard let downloaded = downloadedImage, let directory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, .UserDomainMask, true).first where error == nil
				else
				{
					guard completion()
					else
					{
						NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
						return
					}
					NSNotificationCenter.defaultCenter().postNotificationName(APIManager.mapUpdatedNotification, object: error)
					return
				}
				let directoryURL = NSURL(fileURLWithPath: directory, isDirectory: true)
				let fileURL = directoryURL.URLByAppendingPathComponent("map.png")
				do
				{
					let _ = try? NSFileManager.defaultManager().removeItemAtURL(fileURL)
					try NSFileManager.defaultManager().moveItemAtURL(downloaded, toURL: fileURL)
					newJSON[Map.fileLocationKey] = fileURL.absoluteString
					guard completion()
					else
					{
						return
					}
					NSNotificationCenter.defaultCenter().postNotificationName(APIManager.mapUpdatedNotification, object: self)
				}
				catch
				{
					NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error as NSError)
				}
			})
			downloadTask.resume()
			return false
		}, notificationName: APIManager.mapUpdatedNotification, semaphoreGuard: mapSemaphore)
	}
	
	// MARK: - Notification Keys
	static let announcementsUpdatedNotification = "AnnouncmentsUpdatedNotification"
	static let unapprovedAnnouncementsUpdatedNotification = "UnapprovedAnnouncmentsUpdatedNotification"
	static let countdownUpdateNotification = "CountdownUpdatedNotification"
	static let eventsUpdatedNotification = "EventsUpdatedNotification"
	static let locationsUpdatedNotification = "LocationsUpdatedNotification"
	static let mapUpdatedNotification = "MapUpdatedNotification"
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
		let request = createRequestForRoute("/v1/auth/sign_in", parameters: ["email": username, "password": password], usingHTTPMethod: .POST)
		showNetworkIndicator()
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			defer { self.hideNetworkIndicator() }
			guard error == nil
			else
			{
				// The fetch failed because of a networking error
				completion(.NetworkingError(error!))
				return
			}
			guard let responseHeaders = (response as? NSHTTPURLResponse)?.allHeaderFields
			else {
				completion(.UnknownError)
				return
			}
			
			guard let authToken = responseHeaders["access-token"] as? String, let client = responseHeaders["client"] as? String, let username = responseHeaders["uid"] as? String, let expiry = responseHeaders["expiry"] as? String, let tokenType = responseHeaders["token-type"] as? String
			else
			{
				completion(.Value(false))
				return
			}
			let JSON = try? NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: [])
			let privilege = (JSON?["data"] as? [String: AnyObject])?["roles"] as? Int ?? 0
			self.authenticator = Authenticator(authToken: authToken, client: client, username: username, expiry: expiry, tokenType: tokenType, privilege: privilege)
			completion(.Value(true))
		}
		task.resume()
	}
	func logout()
	{
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
		private var authToken : String
		private var expiry : String
		private let tokenType: String
		private var client: String
		private let privilege: Privilege

		private static let authTokenKey = "MHacksAuthenticationToken"
		private static let clientKey = "MHacksClientKey"
		private static let expiryKey = "expiry"
		private static let usernameKey = "username"
		private static let tokenTypeKey = "token-type"
		private static let privilegeKey = "privilege"
		
		private init(authToken: String, client: String, username: String, expiry: String, tokenType: String, privilege: Int) {
			self.authToken = authToken
			self.client = client
			self.username = username
			self.expiry = expiry
			self.privilege = Privilege(rawValue: privilege) ?? .Hacker
			self.tokenType = tokenType
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
			aCoder.encodeInteger(privilege.rawValue, forKey: Authenticator.privilegeKey)
			aCoder.encodeObject(username, forKey: Authenticator.usernameKey)
			aCoder.encodeObject(expiry, forKey: Authenticator.expiryKey)
			aCoder.encodeObject(tokenType, forKey: Authenticator.tokenTypeKey)
			SSKeychain.setPassword(authToken, forService: Authenticator.authTokenKey, account: username)
			SSKeychain.setPassword(client, forService: Authenticator.clientKey, account: username)
		}
		
		@objc convenience init?(coder aDecoder: NSCoder) {
			// Override default implementation to use keychain here.
			let privilege = aDecoder.decodeIntegerForKey(Authenticator.privilegeKey)
			guard let username = aDecoder.decodeObjectForKey(Authenticator.usernameKey) as? String, let expiry = aDecoder.decodeObjectForKey(Authenticator.expiryKey) as? String, let tokenType = aDecoder.decodeObjectForKey(Authenticator.tokenTypeKey) as? String
			else {
				return nil
			}
			guard let authToken = SSKeychain.passwordForService(Authenticator.authTokenKey, account: username), let client = SSKeychain.passwordForService(Authenticator.clientKey, account: username)
			else {
				return nil
			}
			self.init(authToken: authToken, client: client, username: username, expiry: expiry, tokenType: tokenType, privilege: privilege)
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
			self.announcements = obj.announcements
			self.locations = obj.locations
			self.eventsOrganizer = obj.eventsOrganizer
			self.authenticator = obj.authenticator
			locationForID = { ID in self.locations.filter { $0.ID == ID }.first }
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
	
	@objc func encodeWithCoder(aCoder: NSCoder)
    {
		aCoder.encodeObject(authenticator, forKey: "authenticator")
		aCoder.encodeObject(locations as NSArray, forKey: "locations")
		aCoder.encodeObject(eventsOrganizer, forKey: "eventsOrganizer")
		aCoder.encodeObject(announcements as NSArray, forKey: "announcements")
		aCoder.encodeObject(countdown, forKey: "countdown")
		aCoder.encodeObject(map, forKey: "map")
	}
	
	@objc convenience init?(coder aDecoder: NSCoder)
    {
		self.init()
		self.authenticator = aDecoder.decodeObjectForKey("authenticator") as? Authenticator
		self.map = aDecoder.decodeObjectForKey("map") as? Map
		self.locations = aDecoder.decodeObjectForKey("locations") as? [Location] ?? []
		self.announcements = aDecoder.decodeObjectForKey("announcements") as? [Announcement] ?? []
		self.countdown = aDecoder.decodeObjectForKey("countdown") as? Countdown ?? Countdown()
		locationForID = { ID in self.locations.filter { loc in loc.ID == ID }.first }
		guard let eventsOrganizer = aDecoder.decodeObjectForKey("eventsOrganizer") as? EventOrganizer
		else
		{
			self.eventsOrganizer = EventOrganizer(events: [])
			return
		}
		self.eventsOrganizer = eventsOrganizer
	}
}
var locationForID : ((Int?) -> Location?)!
