//
//  BleOp.swift
//
//  Created by Adrian Kellor on 2/1/2023.
//

import Foundation
import CoreBluetooth

public enum BlemOpResponse {
    case ok, complete;
}

public enum BlemOpAbortReason {
    case disconnected, failedToConnect, bleNotAvailable;
}

open class BlemDeviceOp {

    public init() {
        
    }
    
    open func start(_ device: BlemDevice) -> BlemOpResponse {
        fatalError("Must override BleDeviceOp.start method")
    }
    
    open func abort(_ device: BlemDevice, _ reason: BlemOpAbortReason) {
        fatalError("Must override BleDeviceOp.abort method")
    }
    
    open func peripheralDidUpdateName(_ device: BlemDevice) -> BlemOpResponse {
        print("default peripheralDidUpdateName called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didModifyServices invalidatedServices: [CBService]) -> BlemOpResponse {
        print("default peripheral:didModifyServices called for \(device.name)")
        return .complete
    }

    open func peripheralDidUpdateRSSI(_ device: BlemDevice, error: Error?) -> BlemOpResponse {
        print("default peripheralDidUpdateRSSI called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didReadRSSI RSSI: NSNumber, error: Error?) -> BlemOpResponse {
        print("default peripheral:didReadRSSI called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didDiscoverServices error: Error?) -> BlemOpResponse {
        print("default peripheral:didDiscoverServices called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didDiscoverIncludedServicesFor service: CBService, error: Error?) -> BlemOpResponse {
        print("default peripheral:didDiscoverIncludedServicesFor called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) -> BlemOpResponse {
        print("default peripheral:didDiscoverCharacteristicsFor called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) -> BlemOpResponse {
        print("default peripheral:didUpdateValueFor called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didWriteValueFor characteristic: CBCharacteristic, error: Error?) -> BlemOpResponse {
        print("default peripheral:didWriteValueFor called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) -> BlemOpResponse {
        print("default peripheral:didUpdateNotificationStateFor called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) -> BlemOpResponse {
        print("default peripheral:didDiscoverDescriptorsFor called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didUpdateValueFor descriptor: CBDescriptor, error: Error?) -> BlemOpResponse {
        print("default peripheral:didUpdateValueFor called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didWriteValueFor descriptor: CBDescriptor, error: Error?) -> BlemOpResponse {
        print("default peripheral:didWriteValueFor called for \(device.name)")
        return .complete
    }

    open func peripheralIsReady(_ device: BlemDevice, toSendWriteWithoutResponse peripheral: CBPeripheral) -> BlemOpResponse {
        print("default peripheralIsReady:toSendWriteWithoutResponse called for \(device.name)")
        return .complete
    }

    open func peripheral(_ device: BlemDevice, didOpen channel: CBL2CAPChannel?, error: Error?) -> BlemOpResponse {
        print("default peripheral:didOpen called for \(device.name)")
        return .complete
    }

}

//extension BleDeviceOp {
//
//    // TODO: can we make these methods internal again?
//
//    public func do_peripheralDidUpdateName(_ device: BleDevice) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didModifyServices invalidatedServices: [CBService]) -> BleOpResponse {
//    }
//
//    public func do_peripheralDidUpdateRSSI(_ device: BleDevice, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didReadRSSI RSSI: NSNumber, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didDiscoverServices error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didDiscoverIncludedServicesFor service: CBService, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didWriteValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error:  Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didUpdateValueFor descriptor: CBDescriptor, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didWriteValueFor descriptor: CBDescriptor, error: Error?) -> BleOpResponse {
//    }
//
//    public func do_peripheralIsReady(_ device: BleDevice, toSendWriteWithoutResponse peripheral: CBPeripheral) -> BleOpResponse {
//    }
//
//    public func do_peripheral(_ device: BleDevice, didOpen channel: CBL2CAPChannel?, error: Error?) -> BleOpResponse {
//    }
//
//}
