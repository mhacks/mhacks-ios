//
//  Coalescer.swift
//  MHacks
//
//  Created by Russell Ladd on 12/15/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

class Coalescer {
    
    // MARK: Task
    
    typealias Task = (() -> Void) -> Void
    
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
            
            task { results in
                
                self.running = false
                
                self.complete()
            }
        }
    }
    
    // MARK: Completion
    
    typealias CompletionBlock = () -> Void
    
    private var completionBlocks: [CompletionBlock] = []
    
    private func addCompletionBlock(block: CompletionBlock) {
        completionBlocks.append(block)
    }
    
    private func complete() {
        
        for block in completionBlocks {
            block()
        }
        
        completionBlocks.removeAll(keepCapacity: true)
    }
}
