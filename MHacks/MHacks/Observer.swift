//
//  Observer.swift
//  MHacks
//
//  Created by Russell Ladd on 12/15/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

class Observer<Parameters>: Equatable {
    
    typealias Callback = (Parameters -> Void)
    
    init(block: Callback) {
        self.block = block
    }
    
    var block: Callback
}

func ==<Parameters>(lhs: Observer<Parameters>, rhs: Observer<Parameters>) -> Bool {
    return lhs === rhs
}

struct ObserverCollection<Parameters> {
    
    private var observers: [Observer<Parameters>] = []
    
    mutating func addObserver(observer: Observer<Parameters>) {
        observers.append(observer)
    }
    
    mutating func removeObserver(observer: Observer<Parameters>) {
        observers.removeAtIndex(find(observers, observer)!)
    }
    
    func notify(parameters: Parameters) {
        for observer in observers {
            observer.block(parameters)
        }
    }
}
