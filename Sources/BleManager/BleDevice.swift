//
//  BleDevice.swift
//
//  Created by Adrian Kellor on 2/1/2023.
//

import Foundation
import CoreBluetooth

public enum BleDeviceState {
    case connected, connecting, disconnected, failedToConnect, bleNotAvailable
}

public typealias BleDeviceStateChangedBlock = ((BleDevice, BleDeviceState) -> ())

open class BleDevice: NSObject, CBPeripheralDelegate {

    public let uuid: UUID
    public let name: String
    public var rssi: NSNumber
    public internal(set) var advertisementData: [String : Any]
    
    public var autoDiscoverServices: [CBUUID]?

    internal var characteristics = [CBCharacteristic]()
    internal let peripheral: CBPeripheral

    private let queue = BleOpQueue()
    private var onStateChangedBlock: BleDeviceStateChangedBlock?
    
    public init(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.name = peripheral.name ?? "Unknown"
        self.advertisementData = advertisementData
        self.rssi = rssi
        uuid = UUID(uuidString: peripheral.identifier.uuidString)!
        super.init()
        peripheral.delegate = self
    }
    
    public func characteristic(_ uuid: CBUUID) -> CBCharacteristic? {
        return characteristics.filter { char in char.uuid == uuid }.first
    }
    
    internal func newState(_ newState: BleDeviceState) async {
        switch newState {
        case .connected:
            await queue.pushOpFront(DiscoverServicesOp())
            onStateChangedBlock?(self, newState)
            await startNextOp()
        case .connecting:
            break; // do nothing
        case .disconnected:
            await queue.getCurrentOp()?.status(self, .deviceDisconnected)
            onStateChangedBlock?(self, newState)
        case .failedToConnect:
            await queue.getCurrentOp()?.status(self, .deviceFailedToConnect)
            onStateChangedBlock?(self, newState)
        case .bleNotAvailable:
            await queue.getCurrentOp()?.status(self, .bleNotEnabled)
            onStateChangedBlock?(self, newState)
        }
    }
    
    public func readValue(for char: CBCharacteristic) {
        peripheral.readValue(for: char)
    }
    
    public func onStateChanged(_ closure: @escaping BleDeviceStateChangedBlock) {
        onStateChangedBlock = closure
    }
    
    public func queueOp(_ op: BleDeviceOp) async {
        await queue.pushOp(op)
        if peripheral.state != .connected {
            connect()
        } else if await queue.count() == 1 {
            await startNextOp()
        }
    }

    public func connect() {
        if peripheral.state != .connected {
            Blem.instance.connect(self)
        }
    }
    
    public func disconnect() {
        if peripheral.state != .disconnected {
            Blem.instance.disconnect(self)
        }
    }
    
    private func startNextOp() async {
        await queue.getCurrentOp()?.status(self, .nowActive)
    }
    
    // TODO: move delegate methods into a separate class to keep these methods internal
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralDidUpdateName(self), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didModifyServices: invalidatedServices), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralDidUpdateRSSI(self, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didReadRSSI: RSSI, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverServices: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverIncludedServicesFor: service, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverCharacteristicsFor: service, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateValueFor: characteristic, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didWriteValueFor: characteristic, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateNotificationStateFor: characteristic, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverDescriptorsFor: characteristic, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateValueFor: descriptor, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didWriteValueFor: descriptor, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralIsReady(self, toSendWriteWithoutResponse: peripheral), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didOpen: channel, error: error), result == .complete {
                await queue.popCurrentOp()?.status(self, .complete)
                await startNextOp()
            }
        }
    }
    
}


fileprivate actor BleOpQueue {
    var ops = [BleDeviceOp]()
    
    func count() async -> Int {
        return ops.count
    }
    
    func pushOpFront(_ op: BleDeviceOp) async {
        ops.append(op)
    }
    
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
