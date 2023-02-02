//
//  BleOp.swift
//
//  Created by Adrian Kellor on 2/1/2023.
//

import Foundation
import CoreBluetooth

enum BleOpStatus {
    case nowActive, complete, deviceDisconnected, deviceFailedToConnect, bleNotEnabled;
}

enum BleOpResponse {
    case inProgress, complete;
}

//class BleOp {
//    let queue = DispatchQueue(label: "BleOp", qos: .utility)
//    func handle(info: String) -> BleOpResult {
//        return .finished
//    }
//}

protocol BleDeviceOp {

    func status(_ status: BleOpStatus)
    
    func peripheralDidUpdateName(_ device: BleDevice) -> BleOpResponse

    func peripheral(_ device: BleDevice, didModifyServices invalidatedServices: [CBService]) -> BleOpResponse

    func peripheralDidUpdateRSSI(_ device: BleDevice, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didReadRSSI RSSI: NSNumber, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didDiscoverServices error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didDiscoverIncludedServicesFor service: CBService, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didWriteValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didUpdateValueFor descriptor: CBDescriptor, error: Error?) -> BleOpResponse

    func peripheral(_ device: BleDevice, didWriteValueFor descriptor: CBDescriptor, error: Error?) -> BleOpResponse

    func peripheralIsReady(_ device: BleDevice, toSendWriteWithoutResponse peripheral: CBPeripheral) -> BleOpResponse

    func peripheral(_ device: BleDevice, didOpen channel: CBL2CAPChannel?, error: Error?) -> BleOpResponse

}

extension BleDeviceOp {
    
    func peripheralDidUpdateName(_ device: BleDevice) -> BleOpResponse {
        print("default peripheralDidUpdateName called for \(device.name)")
        return .inProgress
    }
    
    func peripheral(_ device: BleDevice, didModifyServices invalidatedServices: [CBService]) -> BleOpResponse {
        print("default peripheral:didModifyServices called for \(device.name)")
        return .inProgress
    }

    func peripheralDidUpdateRSSI(_ device: BleDevice, error: Error?) -> BleOpResponse {
        print("default peripheralDidUpdateRSSI called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didReadRSSI RSSI: NSNumber, error: Error?) -> BleOpResponse {
        print("default peripheral:didReadRSSI called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didDiscoverServices error: Error?) -> BleOpResponse? {
        print("default peripheral:didDiscoverServices called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didDiscoverIncludedServicesFor service: CBService, error: Error?) -> BleOpResponse {
        print("default peripheral:didDiscoverIncludedServicesFor called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) -> BleOpResponse {
        print("default peripheral:didDiscoverCharacteristicsFor called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
        print("default peripheral:didUpdateValueFor called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didWriteValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
        print("default peripheral:didWriteValueFor called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
        print("default peripheral:didUpdateNotificationStateFor called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error:  Error?) -> BleOpResponse {
        print("default peripheral:didDiscoverDescriptorsFor called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didUpdateValueFor descriptor: CBDescriptor, error: Error?) -> BleOpResponse {
        print("default peripheral:didUpdateValueFor called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didWriteValueFor descriptor: CBDescriptor, error: Error?) -> BleOpResponse {
        print("default peripheral:didWriteValueFor called for \(device.name)")
        return .inProgress
    }

    func peripheralIsReady(_ device: BleDevice, toSendWriteWithoutResponse peripheral: CBPeripheral) -> BleOpResponse {
        print("default peripheralIsReady:toSendWriteWithoutResponse called for \(device.name)")
        return .inProgress
    }

    func peripheral(_ device: BleDevice, didOpen channel: CBL2CAPChannel?, error: Error?) -> BleOpResponse {
        print("default peripheral:didOpen called for \(device.name)")
        return .inProgress
    }

}
