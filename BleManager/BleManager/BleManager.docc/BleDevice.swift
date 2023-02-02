//
//  BleDevice.swift
//
//  Created by Adrian Kellor on 2/1/2023.
//

import Foundation
import CoreBluetooth
import PromiseKit

enum BleDeviceState {
    case connected, connecting, disconnected, failedToConnect, bleNotAvailable
}

typealias BleDeviceStateChangedBlock = ((BleDevice, BleDeviceState) -> ())

class BleDevice: NSObject, CBPeripheralDelegate {

    let uuid: UUID
    let name: String
    var rssi: NSNumber
    internal(set) var advertisementData: [String : Any]
    
    internal let peripheral: CBPeripheral

    private let queue = BleOpQueue()
    private var onStateChangedBlock: BleDeviceStateChangedBlock?
    
    required internal init(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.name = peripheral.name ?? "Unknown"
        self.advertisementData = advertisementData
        self.rssi = rssi
        uuid = UUID(uuidString: peripheral.identifier.uuidString)!
    }
    
    internal func newState(_ newState: BleDeviceState) {
        Task.init {
            onStateChangedBlock?(self, newState)
            switch newState {
            case .connected: await queue.getCurrentOp()?.status(.nowActive)
            case .connecting: break; // do nothing
            case .disconnected: await queue.getCurrentOp()?.status(.deviceDisconnected)
            case .failedToConnect: await queue.getCurrentOp()?.status(.deviceFailedToConnect)
            case .bleNotAvailable: await queue.getCurrentOp()?.status(.bleNotEnabled)
            }
            
        }
    }
    
    func onStateChanged(_ closure: @escaping BleDeviceStateChangedBlock) {
        onStateChangedBlock = closure
    }
    
    func queueOp(_ op: BleDeviceOp) {
        Task.init {
            await queue.pushOp(op)
            connect()
        }
    }

    func connect() {
        if peripheral.state != .connected {
            BleManager.instance.connect(self)
        }
    }
    
    func disconnect() {
        
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralDidUpdateName(self), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didModifyServices: invalidatedServices), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralDidUpdateRSSI(self, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didReadRSSI: RSSI, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverServices: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverIncludedServicesFor: service, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverCharacteristicsFor: service, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateValueFor: characteristic, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didWriteValueFor: characteristic, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateNotificationStateFor: characteristic, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverDescriptorsFor: characteristic, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateValueFor: descriptor, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didWriteValueFor: descriptor, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralIsReady(self, toSendWriteWithoutResponse: peripheral), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didOpen: channel, error: error), result == .complete {
                await queue.popCurrentOp()?.status(.complete)
            }
        }
    }
    
}


fileprivate actor BleOpQueue {
    var ops = [BleDeviceOp]()
    
    func pushOp(_ op: BleDeviceOp) async {
        ops.append(op)
    }
    
    func getCurrentOp() async -> BleDeviceOp? {
        ops.first
    }
    
    func popCurrentOp() async -> BleDeviceOp? {
        if !ops.isEmpty {
            return ops.remove(at: 0)
        } else {
            return nil
        }
    }
}
