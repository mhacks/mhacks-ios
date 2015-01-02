//
//  Coalescer.swift
//  MHacks
//
//  Created by Russell Ladd on 12/15/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

class Coalescer<Parameter, Result> {
    
    // MARK: Task
    
    typealias Task = (Parameter, (Result -> Void)) -> Void
    
    var task: Task!
    
    init() {
        
    }
    
    var running = false
    
    func run(parameter: Parameter, completionBlock: CompletionBlock? = nil) {
        
        if let completionBlock = completionBlock {
            addCompletionBlock(completionBlock)
        }
        
        if !running {
            
            running = true
            
            task(parameter) { result in
                
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
        
        let completionBlocks = self.completionBlocks
        self.completionBlocks.removeAll(keepCapacity: true)
        
        for block in completionBlocks {
            block(result)
        }
    }
}
