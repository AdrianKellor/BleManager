//
//  File.swift
//  
//
//  Created by Adrian on 5/21/23.
//

import Foundation
import CoreBluetooth

public class BlemNotifyObserver {
    public let uuid: CBUUID;
    
    // TODO does this need an onStop closure?
    internal weak var owner: AnyObject?
    internal var onDataClosure: ((Data?) -> ())?
    internal var onStopped: (() -> ())?
    internal var onError: ((String) -> ())?
    
    init(weakOwner: AnyObject, _ uuid: CBUUID) {
        self.owner = weakOwner
        self.uuid = uuid
    }
    
    public func onData(closure: @escaping (Data?) -> ()) -> BlemNotifyObserver {
        onDataClosure = closure
        return self
    }
    public func onStopped(closure: @escaping () -> ()) -> BlemNotifyObserver {
        onStopped = closure
        return self
    }
    public func onError(closure: @escaping (String) -> ()) -> BlemNotifyObserver {
        onError = closure
        return self
    }
    
    // TODO callback BlemNotificationManager when onData is set?
}

class Weak<T: AnyObject> {
  weak var value : T?
  init (value: T) {
    self.value = value
  }
}

internal actor BlemNotifyManager {
    
    private let device: BlemDevice
    
    private var observers = [BlemNotifyObserver]()
    
    internal init(_ device: BlemDevice) {
        self.device = device
    }
    
    internal func notify(_ observer: BlemNotifyObserver) async {
        observers.append(observer)
    }
    
    internal func stop(_ uuid: CBUUID) async {
        
    }
    
    internal func peripheral(_ peripheral: CBPeripheral,
                             didUpdateValueFor characteristic: CBCharacteristic,
                             error: Error?) async {

        let uuid = characteristic.uuid
        
        for observer in observers {
            if observer.owner != nil, observer.uuid == uuid {
                observer.onDataClosure?(characteristic.value)
            }
        }
        
        // purge any
        observers.removeAll { observer in observer.owner == nil }
        
        checkForDisable()
    }

    // TODO
    private func checkForDisable() {
        
    }
}
