//
//  Blem.swift
//
//  Created by Adrian Kellor on 2/1/2023.
//

import Foundation
import CoreBluetooth

public class Blem: NSObject {
    
    public static let instance = Blem()
    
    private var manager: CBCentralManager!
    private var managerIsStarting = false
    
    private let deviceList = BleDeviceList()
    
    fileprivate override init() {
        super.init()
        
        self.managerIsStarting = true
        self.manager = CBCentralManager(delegate: self,
                                        queue: nil)
        
    }
    
    // Correct syntax for read only property?
    public var currentBleState: CBManagerState {
        get {
            manager.state
        }
    }
    
    // TODO: Add observer list for CBManager state changes
    
    var activeScanner: BlemScanner?
    
    public func newScanner(seconds: Int, services: [CBUUID]) -> BlemScanner {
        return BlemScanner(manager: self, seconds: seconds, services: services)
    }
    
    internal func startScanning(scanner: BlemScanner) async {
        // stop current scan
        manager?.stopScan()
        await activeScanner?.finished()
        activeScanner = scanner

        // since there's no callback for stopping a scan, wait for 1 second for scanning to finish
        try? await Task.sleep(nanoseconds: UInt64(1e9))
        
        // begin new scan
        manager?.scanForPeripherals(withServices: scanner.services, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)
        ])
        await activeScanner?.startedScanning()
    }
    
    internal func endScanner(_ scanner: BlemScanner) async {
        // TODO, add a safety to shutdown scanning if running too long
        if let active = activeScanner, active === scanner {
            await activeScanner?.finished()
            activeScanner = nil
            manager?.stopScan()
        }
    }

    public func endActiveScanner() async {
        if let scanner = activeScanner {
            await self.endScanner(scanner)
        }
    }
    
    fileprivate let stateChangeListeners = WeakOwnerList<((CBManagerState) -> ())>();
    
    public func addStateChangeListener(weakOwner: AnyObject, _ closure: @escaping ((CBManagerState) -> ())) {
        Task.init {
            await stateChangeListeners.add(weakOwner: weakOwner, closure)
        }
    }
}


extension Blem: CBCentralManagerDelegate {

    // manager
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // TODO: needs to handle active scanner
        managerIsStarting = false
        Task.init {
            await stateChangeListeners.forEach { closure in closure(central.state) }
        }
    }

    // Scanning

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        Task {
            if let scanner = activeScanner {
                let bleDevice = await deviceList.findOrAdd(peripheral: peripheral,
                                                           advertisementData: advertisementData,
                                                           rssi: RSSI,
                                                           scanner: scanner)
                await scanner.discovered(device: bleDevice)
            }
        }
    }

    internal func connect(_ device: BlemDevice) {
        Task.init {
            if managerIsStarting {
                await device.newState(.bleNotAvailable)
                return
            }
            
            if device.peripheral.state == .disconnected {
                manager.connect(device.peripheral)
                await device.newState(.connecting)
            }
        }
    }
    
    internal func disconnect(_ device: BlemDevice) {
        Task.init {
            if managerIsStarting {
                await device.newState(.bleNotAvailable)
                return
            }
            
            if device.peripheral.state == .connected {
                manager.cancelPeripheralConnection(device.peripheral)
            }
        }
    }
    
    // Connections


    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task.init {
            await deviceList.find(uuid: peripheral.identifier.uuidString)?.newState(.connected)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Task.init {
            await deviceList.find(uuid: peripheral.identifier.uuidString)?.newState(.disconnected)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Task.init {
            await deviceList.find(uuid: peripheral.identifier.uuidString)?.newState(.failedToConnect)
        }
    }
    
    
    
}

fileprivate actor BleDeviceList {
    
    private let queue = DispatchQueue(label: UUID().uuidString, qos: .utility)
    private var devices = [BlemDevice]()
    
    func findOrAdd(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber, scanner: BlemScanner) async -> BlemDevice {
        if let found = self.devices.first(where: { device in
            device.uuid.uuidString.lowercased() == peripheral.identifier.uuidString.lowercased()
        } ) {
            return found
        } else {
            let scanBundle = BlemDiscoveryBundle(peripheral: peripheral, advertisementData: advertisementData, rssi: rssi)
            let newDevice = await scanner.createDevice(scanBundle)
            self.devices.append(newDevice)
            return newDevice
        }
    }
    
    func find(uuid: String) async -> BlemDevice? {
        if let found = self.devices.first(where: { device in device.uuid.uuidString.lowercased() == uuid.lowercased() } ) {
            return found
        } else {
            return nil
        }
    }
    
}

//fileprivate actor BleScannerList {
//
//    let queue = DispatchQueue(label: UUID().uuidString, qos: .utility)
//    var scanners = [BleScanner]()
//
//    func count() async -> Promise<Int> {
//        return Promise() { seal in
//            seal.fulfill(scanners.count)
//        }
//    }
//
//    func add(scanner: BleScanner) async -> BleScanner {
//        scanners.append(scanner)
//        return scanner
//    }
//
//    func all() async -> [BleScanner] {
//        let copy = scanners
//        return copy
//    }
//
//}
