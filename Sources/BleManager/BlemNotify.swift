//
//  File.swift
//  
//
//  Created by Adrian on 5/21/23.
//

import Foundation
import CoreBluetooth

enum BlemNotifyError: Error {
    case characteristicNotFound
    case noOnDataDefined
    case noOnStoppedDefined
    case noOnErrorDefined
    // case unexpected(code: Int)
}

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

public actor BlemNotifyManager {
    
    private let device: BlemDevice
    private var observers = [BlemNotifyObserver]()
    private var activeUuids = [CBUUID]()
    
    internal init(_ device: BlemDevice) {
        self.device = device
    }
    
    public func notify(_ observer: BlemNotifyObserver) async throws {
        guard let deviceChar = device.characteristics.first(where: {char in char.uuid == observer.uuid}) else {
            throw BlemNotifyError.characteristicNotFound
        }
        
        if observer.onDataClosure == nil { throw BlemNotifyError.noOnDataDefined }
        if observer.onStopped == nil { throw BlemNotifyError.noOnStoppedDefined }
        if observer.onError == nil { throw BlemNotifyError.noOnErrorDefined }
        
        if !activeUuids.contains(where: {cbuuid in cbuuid == observer.uuid}) {
            device.peripheral.setNotifyValue(true, for: deviceChar)
            activeUuids.append(observer.uuid)
        }
        
        observers.append(observer)
    }
    
    internal func stop(_ uuid: CBUUID) async {
        guard let deviceChar = device.characteristics.first(where: {char in char.uuid == uuid}) else {
            // nothing to stop, just return
            return
        }
        
        // stop notification
        device.peripheral.setNotifyValue(false, for: deviceChar)
        
        // remove char from active list
        activeUuids.removeAll(where: { cbuuid in cbuuid == uuid } )
        
        // Notify observers of this stop
        for observer in observers {
            if observer.owner != nil, observer.uuid == uuid {
                observer.onStopped?()
            }
        }
        
        // Remove observers for stopped uuid
        observers.removeAll { observer in observer.uuid == uuid }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral,
                             didUpdateValueFor characteristic: CBCharacteristic,
                             error: Error?) async {

        var cleanupObservers = false
        for observer in observers {
            if observer.owner == nil {
                cleanupObservers = true
            } else if observer.uuid == characteristic.uuid {
                observer.onDataClosure?(characteristic.value)
            }
        }
        
        if cleanupObservers {
            observers.removeAll { observer in observer.owner == nil }
        }

        for activeUuid in activeUuids {
            if observers.contains(where: { observer in observer.uuid == activeUuid }) {
                
            }
                
        }
    }

//    private func cleanupUnused() {
//
//        // first
//
//        // Notify observers of this stop
//        for observer in observers {
//            if observer.owner != nil, !uuidIsActive(observer.uuid) {
//
//                observer.onStopped?()
//            }
//        }
//
//        // Remove observers for stopped uuid
//        observers.removeAll { observer in !uuidIsActive(observer.uuid) }
//
//    }
//
//    private func uuidIsActive(_ uuid: CBUUID) -> Bool {
//        activeUuids.contains(where: {activeUuid in activeUuid == uuid})
//    }
    
}
