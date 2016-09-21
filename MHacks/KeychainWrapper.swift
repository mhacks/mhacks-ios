//
//  KeychainWrapper.swift
//  KeychainWrapper
//
//  Created by Jason Rendel on 9/23/14.
//  Copyright (c) 2014 Jason Rendel. All rights reserved.
//
//    The MIT License (MIT)
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//
//    Modified heavily by Manav Gabhawala on 9/21/16 to get rid of bloat we don't really need.


import Foundation

/// KeychainWrapper is a class to help make Keychain access in Swift more straightforward. It is designed to make accessing the Keychain services more like using NSUserDefaults, which is much more familiar to people.
final class KeychainWrapper {
	
	/// Default keychain wrapper access
	static let shared = KeychainWrapper()
	
	/// ServiceName is used for the kSecAttrService property to uniquely identify this keychain accessor. If no service name is specified, KeychainWrapper will default to using the bundleIdentifier.
	private (set) public var serviceName: String
	
	/// AccessGroup is used for the kSecAttrAccessGroup property to identify which Keychain Access Group this entry belongs to. This allows you to use the KeychainWrapper with shared keychain access between different applications.
	private (set) public var accessGroup: String?
	
	private static let defaultServiceName: String = {
		return Bundle.main.bundleIdentifier ?? "MHacks"
	}()
	
	private convenience init() {
		self.init(serviceName: KeychainWrapper.defaultServiceName)
	}
	
	/// Create a custom instance of KeychainWrapper with a custom Service Name and optional custom access group.
	///
	/// - parameter serviceName: The ServiceName for this instance. Used to uniquely identify all keys stored using this keychain wrapper instance.
	init(serviceName: String) {
		self.serviceName = serviceName
		self.accessGroup = groupName
	}
	
	// MARK:- Public Methods
	
	/// Checks if keychain data exists for a specified key.
	///
	/// - parameter forKey: The key to check for.
	/// - returns: True if a value exists for the key. False otherwise.
	func hasValue(forKey key: String) -> Bool {
		return data(forKey: key) != nil
	}
	
	// MARK: Public Getters
	
	/// Returns a string value for a specified key.
	///
	/// - parameter forKey: The key to lookup data for.
	/// - returns: The String associated with the key if it exists. If no data exists, or the data found cannot be encoded as a string, returns nil.
	func string(forKey key: String) -> String? {
		guard let keychainData = data(forKey: key)
		else {
			return nil
		}
		
		return String(data: keychainData, encoding: .utf8)
	}
	
	
	/// Returns a Data object for a specified key.
	///
	/// - parameter forKey: The key to lookup data for.
	/// - returns: The Data object associated with the key if it exists. If no data exists, returns nil.
	func data(forKey key: String) -> Data? {
		var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)
		var result: AnyObject?
		
		// Limit search results to one
		keychainQueryDictionary[KeychainWrapper.SecMatchLimit] = kSecMatchLimitOne
		
		// Specify we want Data/CFData returned
		keychainQueryDictionary[KeychainWrapper.SecReturnData] = kCFBooleanTrue
		
		// Search
		let status = withUnsafeMutablePointer(to: &result) {
			SecItemCopyMatching(keychainQueryDictionary as CFDictionary, UnsafeMutablePointer($0))
		}
		
		return status == noErr ? result as? Data : nil
	}
	
	
	// MARK: Public Setters
	
	/// Save a String value to the keychain associated with a specified key. If a String value already exists for the given key, the string will be overwritten with the new value.
	///
	/// - parameter value: The String value to save.
	/// - parameter forKey: The key to save the String under.
	/// - returns: True if the save was successful, false otherwise.
	func set(_ value: String, forKey key: String) -> Bool {
		guard let data = value.data(using: .utf8)
		else {
			return false
		}
		return set(data, forKey: key)
	}
	
	/// Save a Data object to the keychain associated with a specified key. If data already exists for the given key, the data will be overwritten with the new value.
	///
	/// - parameter value: The Data object to save.
	/// - parameter forKey: The key to save the object under.
	/// - returns: True if the save was successful, false otherwise.
	func set(_ value: Data, forKey key: String) -> Bool {
		var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)
		
		keychainQueryDictionary[KeychainWrapper.SecValueData] = value
		
			// Assign default protection - Protect the keychain entry so it's only valid when the device is unlocked
		keychainQueryDictionary[KeychainWrapper.SecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
		
		let status: OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
		
		if status == errSecSuccess {
			return true
		} else if status == errSecDuplicateItem {
			return update(value, forKey: key)
		} else {
			return false
		}
	}
	
	/// Remove an object associated with a specified key. If re-using a key but with a different accessibility, first remove the previous key value using removeObjectForKey(:withAccessibility) using the same accessibilty it was saved with.
	///
	/// - parameter forKey: The key value to remove data for.
	/// - returns: True if successful, false otherwise.
	func remove(key: String) -> Bool {
		return SecItemDelete(setupKeychainQueryDictionary(forKey: key) as CFDictionary) == errSecSuccess
	}
	
	/// Update existing data associated with a specified key name. The existing data will be overwritten by the new data
	private func update(_ value: Data, forKey key: String) -> Bool {
		let keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)
		let updateDictionary = [KeychainWrapper.SecValueData : value]
		
		// Update
		return SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary) == errSecSuccess
	}
	
	/// Setup the keychain query dictionary used to access the keychain on iOS for a specified key name. Takes into account the Service Name and Access Group if one is set.
	///
	/// - parameter forKey: The key this query is for
	/// - returns: A dictionary with all the needed properties setup to access the keychain on iOS
	private func setupKeychainQueryDictionary(forKey key: String) -> [String: Any] {
		// Setup default access as generic password (rather than a certificate, internet password, etc)
		var keychainQueryDictionary: [String: Any] = [KeychainWrapper.SecClass : kSecClassGenericPassword]
		
		// Uniquely identify this keychain accessor
		keychainQueryDictionary[KeychainWrapper.SecAttrService] = serviceName
		
		// Set the keychain access group if defined
		if let accessGroup = self.accessGroup {
			keychainQueryDictionary[KeychainWrapper.SecAttrAccessGroup] = accessGroup
		}
		
		// Uniquely identify the account who will be accessing the keychain
		let encodedIdentifier: Data? = key.data(using: .utf8)
		
		keychainQueryDictionary[KeychainWrapper.SecAttrGeneric] = encodedIdentifier
		
		keychainQueryDictionary[KeychainWrapper.SecAttrAccount] = encodedIdentifier
		
		return keychainQueryDictionary
	}
	
	private static let SecMatchLimit = kSecMatchLimit as String
	private static let SecReturnData = kSecReturnData as String
	private static let SecReturnPersistentRef = kSecReturnPersistentRef as String
	private static let SecValueData = kSecValueData as String
	private static let SecAttrAccessible = kSecAttrAccessible as String
	private static let SecClass = kSecClass as String
	private static let SecAttrService = kSecAttrService as String
	private static let SecAttrGeneric = kSecAttrGeneric as String
	private static let SecAttrAccount = kSecAttrAccount as String
	private static let SecAttrAccessGroup = kSecAttrAccessGroup as String
	private static let SecReturnAttributes = kSecReturnAttributes as String
}
