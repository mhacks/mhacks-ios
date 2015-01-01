//
//  Fetch.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

protocol Fetchable: Equatable {
    
    init?(object: PFObject)
    
    var ID: String { get }
}

extension PFQuery {
    
    func fetch<T: Fetchable>(completionHandler: ([T]?) -> Void) {
        
        findObjectsInBackgroundWithBlock { objects, error in
            
            if let objects = objects as? [PFObject] {
                
                let structures: [T] = objects.map { T(object: $0 ) }.filter { $0 != nil }.map { $0! }
                
                completionHandler(structures)
                
            } else {
                
                completionHandler(nil)
            }
        }
    }
}

enum FetchSource {
    case Local
    case Remote
}

class Fetcher<T: Fetchable> {
    
    // MARK: Initialization
    
    init(query: PFQuery, name: String) {
        
        let localQuery = query.copy() as PFQuery
        //localQuery.fromLocalDatastore()
        
        let remoteQuery = query
        
        coalescer.task = { [weak self] source, taskCompletionBlock in
            
            let query: PFQuery = {
                switch source {
                case .Local:
                    return localQuery
                case .Remote:
                    return remoteQuery
                }
            }()
            
            query.findObjectsInBackgroundWithBlock { objects, findError in
                
                if findError != nil {
                    
                    self?.fetchCompletionBlock(nil)
                    taskCompletionBlock(findError)
                    
                } else {
                    
                    let processObjects: () -> Void = {
                        
                        if let objects = objects as? [PFObject] {
                            
                            let results = objects.map { T(object: $0 ) }.filter { $0 != nil }.map { $0! }
                            self?.fetchCompletionBlock(results)
                            
                        } else {
                            
                            self?.fetchCompletionBlock(nil)
                        }
                        
                        taskCompletionBlock(nil)
                    }
                    
                    switch source {
                        
                        case .Local:
                        processObjects()
                        
                        case .Remote:
                        
                        PFObject.unpinAllObjectsInBackgroundWithName(name) { success, unpinError in
                            
                            if unpinError != nil {
                                
                                self?.fetchCompletionBlock(nil)
                                taskCompletionBlock(unpinError)
                                
                            } else {
                                
                                PFObject.pinAllInBackground(objects, withName: name) { success, pinError in
                                    
                                    if pinError != nil {
                                        
                                        self?.fetchCompletionBlock(nil)
                                        taskCompletionBlock(pinError)
                                        
                                    } else {
                                        
                                        processObjects()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Fetch
    
    private let coalescer = Coalescer<FetchSource, NSError?>()
    
    func fetch(source: FetchSource, completionBlock: (NSError? -> Void)? = nil) {
        coalescer.run(source, completionBlock)
    }
    
    var fetching: Bool {
        return coalescer.running
    }
    
    typealias FetchCompletionBlock = ([T]?) -> Void
    
    var fetchCompletionBlock: FetchCompletionBlock!
}

class FetchResultsManager<T: Fetchable> {
    
    // MARK: Initialization
    
    init(query: PFQuery, name: String) {
        
        fetcher = Fetcher(query: query, name: name)
        
        fetcher.fetchCompletionBlock = { results in
            
            if let results = results {
                self.results = results
            }
        }
    }
    
    // MARK: Fetch
    
    private let fetcher: Fetcher<T>
    
    func fetch(source: FetchSource, completionBlock: (NSError? -> Void)? = nil) {
        fetcher.fetch(source, completionBlock: completionBlock)
    }
    
    var fetching: Bool {
        return fetcher.fetching
    }
    
    private(set) var results: [T] = [] {
        didSet {
            if results != oldValue {
                observerCollection.notify(results)
            }
        }
    }
    
    // MARK: Observers
    
    var observerCollection = ObserverCollection<[T]>()
}
