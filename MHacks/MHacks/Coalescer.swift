//
//  Coalescer.swift
//  MHacks
//
//  Created by Russell Ladd on 12/15/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

class Coalescer<Result> {
    
    // MARK: Task
    
    typealias Task = (Result -> Void) -> Void
    
    var task: Task!
    
    init() {
        
    }
    
    var running = false
    
    func run(completionBlock: CompletionBlock? = nil) {
        
        if let completionBlock = completionBlock {
            addCompletionBlock(completionBlock)
        }
        
        if !running {
            
            running = true
            
            task { result in
                
                self.running = false
                
                self.completeWithResult(result)
            }
        }
    }
    
    // MARK: Completion
    
    typealias CompletionBlock = Result -> Void
    
    private var completionBlocks: [CompletionBlock] = []
    
    private func addCompletionBlock(block: CompletionBlock) {
        completionBlocks.append(block)
    }
    
    private func completeWithResult(result: Result) {
        
        for block in completionBlocks {
            block(result)
        }
        
        completionBlocks.removeAll(keepCapacity: true)
    }
}
