//
//  File.swift
//  
//
//  Created by Adrian on 5/31/23.
//

import Foundation


fileprivate struct WeakOwnerItem<T> {
    fileprivate weak var owner: AnyObject?
    fileprivate let item: T
}

internal actor WeakOwnerList<T> {
    
    private var observers = [WeakOwnerItem<T>]()

    internal func add(weakOwner: AnyObject, _ newItem: T) async {
        observers.append(WeakOwnerItem(owner: weakOwner, item: newItem))
    }

    internal func allItems() async -> [T] {
        cleanUp()
        return observers.map { $0.item }
    }
    
    internal func removeAll(_ closure: ((T) -> (Bool))) async {
        cleanUp()
        observers.removeAll { item in
            closure(item.item)
        }
    }
    
    internal func forEach(_ closure: ((T) -> ())) async {
        cleanUp()
        observers.forEach { item in
            closure(item.item)
        }
    }
    
    
    
    private func cleanUp() {
        observers.removeAll { item in item.owner == nil }
    }
}
