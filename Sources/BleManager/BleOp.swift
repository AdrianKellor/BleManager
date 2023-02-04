//
//  BleOp.swift
//
//  Created by Adrian Kellor on 2/1/2023.
//

import Foundation
import CoreBluetooth

// TODO: .complete status makes concrete classes awkward to codd
public enum BleOpStatus {
    case nowActive, complete, deviceDisconnected, deviceFailedToConnect, bleNotEnabled;
}

public enum BleOpResponse {
    case inProgress, complete;
}

open class BleDeviceOp {

    public init() {
        
    }
    
    open func status(_ device: BleDevice, _ status: BleOpStatus) {
        fatalError("Must override BleDeviceOp.status method")
    }
    
    open func peripheralDidUpdateName(_ device: BleDevice) -> BleOpResponse {
        print("default peripheralDidUpdateName called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didModifyServices invalidatedServices: [CBService]) -> BleOpResponse {
        print("default peripheral:didModifyServices called for \(device.name)")
        return .inProgress
    }

    open func peripheralDidUpdateRSSI(_ device: BleDevice, error: Error?) -> BleOpResponse {
        print("default peripheralDidUpdateRSSI called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didReadRSSI RSSI: NSNumber, error: Error?) -> BleOpResponse {
        print("default peripheral:didReadRSSI called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didDiscoverServices error: Error?) -> BleOpResponse {
        print("default peripheral:didDiscoverServices called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didDiscoverIncludedServicesFor service: CBService, error: Error?) -> BleOpResponse {
        print("default peripheral:didDiscoverIncludedServicesFor called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) -> BleOpResponse {
        print("default peripheral:didDiscoverCharacteristicsFor called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
        print("default peripheral:didUpdateValueFor called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didWriteValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
        print("default peripheral:didWriteValueFor called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
        print("default peripheral:didUpdateNotificationStateFor called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
        print("default peripheral:didDiscoverDescriptorsFor called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didUpdateValueFor descriptor: CBDescriptor, error: Error?) -> BleOpResponse {
        print("default peripheral:didUpdateValueFor called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didWriteValueFor descriptor: CBDescriptor, error: Error?) -> BleOpResponse {
        print("default peripheral:didWriteValueFor called for \(device.name)")
        return .inProgress
    }

    open func peripheralIsReady(_ device: BleDevice, toSendWriteWithoutResponse peripheral: CBPeripheral) -> BleOpResponse {
        print("default peripheralIsReady:toSendWriteWithoutResponse called for \(device.name)")
        return .inProgress
    }

    open func peripheral(_ device: BleDevice, didOpen channel: CBL2CAPChannel?, error: Error?) -> BleOpResponse {
        print("default peripheral:didOpen called for \(device.name)")
        return .inProgress
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
