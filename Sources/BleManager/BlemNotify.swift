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
    
    internal var onDataClosure: ((Data?) -> ())?
    internal var onStopped: (() -> ())?
    internal var onError: ((String) -> ())?
    
    init(_ uuid: CBUUID) {
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
}

public actor BlemNotifyManager {
    
    private let device: BlemDevice
    private var weakObservers = WeakOwnerList<BlemNotifyObserver>()
    
    internal init(_ device: BlemDevice) {
        self.device = device
    }
    
    public func notify(weakOwner: AnyObject, _ observer: BlemNotifyObserver) async throws {
        guard let deviceChar = device.characteristics.first(where: {char in char.uuid == observer.uuid}) else {
            throw BlemNotifyError.characteristicNotFound
        }
        
        if observer.onDataClosure == nil { throw BlemNotifyError.noOnDataDefined }
        if observer.onStopped == nil { throw BlemNotifyError.noOnStoppedDefined }
        if observer.onError == nil { throw BlemNotifyError.noOnErrorDefined }
        
        if await !weakObservers.allItems().contains(where: { $0.uuid == observer.uuid }) {
            device.peripheral.setNotifyValue(true, for: deviceChar)
        }
        
        await weakObservers.add(weakOwner: weakOwner, observer)
    }
    
    internal func stop(_ uuid: CBUUID) async {
        guard let deviceChar = device.characteristics.first(where: {char in char.uuid == uuid}) else {
            // nothing to stop, just return
            return
        }
        
        // stop notification
        device.peripheral.setNotifyValue(false, for: deviceChar)
        
        // Notify observers of this stop
        await weakObservers.forEach { observer in
            if observer.uuid == uuid {
                observer.onStopped?()
            }
        }
        
        // Remove observers for stopped uuid
        await weakObservers.removeAll { observer in observer.uuid == uuid }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral,
                             didUpdateValueFor characteristic: CBCharacteristic,
                             error: Error?) async {
        await weakObservers.forEach { observer in
            observer.onDataClosure?(characteristic.value)
        }
    }
    
}
