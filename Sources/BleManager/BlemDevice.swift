//
//  BlemDevice.swift
//
//  Created by Adrian Kellor on 2/1/2023.
//

import Foundation
import CoreBluetooth

public enum BlemDeviceState {
    case connected, connecting, disconnected, failedToConnect, bleNotAvailable
}

public typealias BlemDeviceStateChangedBlock = ((BlemDevice, BlemDeviceState) -> ())

open class BlemDevice: NSObject, CBPeripheralDelegate {

    public let uuid: UUID
    public let name: String
    public var rssi: NSNumber
    public internal(set) var advertisementData: [String : Any]
    public var autoDiscoverServices: [CBUUID]?

    internal var characteristics = [CBCharacteristic]()
    internal let peripheral: CBPeripheral

    private let queue = BleOpQueue()
    private var onStateChangedClosure: BlemDeviceStateChangedBlock?
    
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
    
    // MARK: State / Connection
    
    public func onStateChanged(_ closure: @escaping BlemDeviceStateChangedBlock) {
        onStateChangedClosure = closure
    }
    
    internal func newState(_ newState: BlemDeviceState) async {
        switch newState {
        case .connected:
            await queue.pushOpFront(DiscoverServicesOp())
            onStateChangedClosure?(self, newState)
            await startNextOp()
        case .connecting:
            break; // do nothing
        case .disconnected:
            while await queue.count() > 0 {
                await queue.getCurrentOp()?.abort(self, .disconnected)
                _ = await queue.popCurrentOp()
            }
            onStateChangedClosure?(self, newState)
        case .failedToConnect:
            while await queue.count() > 0 {
                await queue.getCurrentOp()?.abort(self, .failedToConnect)
                _ = await queue.popCurrentOp()
            }
            onStateChangedClosure?(self, newState)
        case .bleNotAvailable:
            while await queue.count() > 0 {
                await queue.getCurrentOp()?.abort(self, .bleNotAvailable)
                _ = await queue.popCurrentOp()
            }
            onStateChangedClosure?(self, newState)
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

    // MARK: Ops
    
    private func startNextOp() async {
        while await queue.getCurrentOp()?.start(self) == .complete {
            _ = await queue.popCurrentOp()
        }
    }
    
    public func queueOp(_ op: BlemDeviceOp) async {
        await queue.pushOp(op)
        if peripheral.state != .connected {
            connect()
        } else if await queue.count() == 1 {
            await startNextOp()
        }
    }

    // MARK: peripheral input delegate methods
    
    public func readValue(for char: CBCharacteristic) {
        peripheral.readValue(for: char)
    }
    
    // MARK: peripheral output delegate methods
    
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralDidUpdateName(self), result == .complete {
                await startNextOp()
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didModifyServices: invalidatedServices), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralDidUpdateRSSI(self, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didReadRSSI: RSSI, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverServices: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverIncludedServicesFor: service, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverCharacteristicsFor: service, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateValueFor: characteristic, error: error), result == .complete {
                await startNextOp()
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didWriteValueFor: characteristic, error: error), result == .complete {
                await startNextOp()
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateNotificationStateFor: characteristic, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didDiscoverDescriptorsFor: characteristic, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didUpdateValueFor: descriptor, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didWriteValueFor: descriptor, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheralIsReady(self, toSendWriteWithoutResponse: peripheral), result == .complete {
                await startNextOp()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        Task.init {
            if let result = await queue.getCurrentOp()?.peripheral(self, didOpen: channel, error: error), result == .complete {
                await startNextOp()
            }
        }
    }
    
}


fileprivate actor BleOpQueue {
    var ops = [BlemDeviceOp]()
    
    func count() async -> Int {
        return ops.count
    }
    
    func pushOpFront(_ op: BlemDeviceOp) async {
        ops.append(op)
    }
    
    func pushOp(_ op: BlemDeviceOp) async {
        ops.append(op)
    }
    
    func getCurrentOp() async -> BlemDeviceOp? {
        ops.first
    }
    
    func popCurrentOp() async -> BlemDeviceOp? {
        if !ops.isEmpty {
            return ops.remove(at: 0)
        } else {
            return nil
        }
    }
}
