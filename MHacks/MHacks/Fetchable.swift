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

class Fetcher<T: Fetchable> {
    
    // MARK: Initialization
    
    init(query: PFQuery) {
        
        coalescer.task = { [weak self] taskCompletionBlock in
            
            query.findObjectsInBackgroundWithBlock { objects, error in
                
                if let objects = objects as? [PFObject] {
                    
                    let results = objects.map { T(object: $0 ) }.filter { $0 != nil }.map { $0! }
                    
                    self?.fetchCompletionBlock(results)
                    
                } else {
                    
                    self?.fetchCompletionBlock(nil)
                }
                
                taskCompletionBlock(error)
            }
        }
    }
    
    // MARK: Fetch
    
    private let coalescer = Coalescer<NSError?>()
    
    func fetch(completionBlock: (NSError? -> Void)? = nil) {
        coalescer.run(completionBlock)
    }
    
    var fetching: Bool {
        return coalescer.running
    }
    
    typealias FetchCompletionBlock = ([T]?) -> Void
    
    var fetchCompletionBlock: FetchCompletionBlock!
}

class FetchResultsManager<T: Fetchable> {
    
    // MARK: Initialization
    
    init(query: PFQuery) {
        
        fetcher = Fetcher(query: query)
        
        fetcher.fetchCompletionBlock = { results in
            
            if let results = results {
                self.results = results
            }
        }
    }
    
    // MARK: Fetch
    
    private let fetcher: Fetcher<T>
    
    func fetch(completionBlock: (NSError? -> Void)? = nil) {
        fetcher.fetch(completionBlock)
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
