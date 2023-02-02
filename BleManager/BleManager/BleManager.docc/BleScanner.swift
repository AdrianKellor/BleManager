//
//  BleScanner.swift
//
//  Created by Adrian Kellor on 2/1/2023.
//

import Foundation
import CoreBluetooth
import PromiseKit


class BleScan {
    
    typealias onDiscoverType = (BleDevice) -> ()
    typealias onStopType     = () -> ()

    internal var onDiscoverClosure: onDiscoverType?
    internal var onStop: onStopType?
    
    internal func found(device: BleDevice, advertisementData: [String: Any]) {
        onDiscoverClosure?(device)
    }
    
    internal func stopped() {
        onStop?()
    }
    
}

fileprivate enum ScanState {
    case waiting, scanning, stopped, failed;
}

typealias DeviceCreator = (CBPeripheral, [String: Any], NSNumber) -> BleDevice?

actor BleScanner: NSObject {

    private var state = ScanState.waiting
    
    private var manager: BleManager
    private let seconds: Int
    internal let services: [CBUUID]

    init(manager: BleManager, seconds: Int, services: [CBUUID]) {
        self.manager = manager
        self.seconds = seconds
        self.services = services
        super.init()
        Task {
            try? await Task.sleep(nanoseconds: UInt64(10e9))
            switch (await self.state) {
            case .waiting:
                await self.failed()
            case .scanning, .stopped, .failed:
                break;
            }
        }
    }

    // New device creation
    
    private var discoveryCreatorClosure: DeviceCreator?
    
    public func onDiscoveryCreator(_ closure: @escaping DeviceCreator) -> Self {
        discoveryCreatorClosure = closure
        return self
    }

    internal func createDevice(_ peripheral: CBPeripheral, _ advertisementData: [String : Any], _ rssi: NSNumber) -> BleDevice {
        if let newDevice = discoveryCreatorClosure?(peripheral, advertisementData, rssi) {
            return newDevice
        } else {
            return BleDevice(peripheral: peripheral, advertisementData: advertisementData, rssi: rssi)
        }
    }

    // Callbacks
    
    private var onDiscoverClosure: ((BleDevice) -> ())?
    private var onFinishedClosure: (() -> ())?
    private var onFailedClosure: (() -> ())?

    func onDiscover(_ closure: @escaping (BleDevice) -> ()) -> Self {
        onDiscoverClosure = closure
        return self
    }

    func onFinished(_ closure: @escaping () -> ()) -> Self {
        onFinishedClosure = closure
        return self
    }

    func onFailed(_ closure: @escaping () -> ()) -> Self {
        onFailedClosure = closure
        return self
    }

    
    
    // public functions
    
    func stop() async {
        switch(state) {
        case .waiting, .scanning:
            await manager.endCurrentScan(self)
        case .stopped, .failed:
            break;
        }
        state = .stopped
    }
    
    func start() async {
        await manager.startScanning(scanner: self)
    }
    
    // Callbacks for manager
    
    internal func startedScanning() async {
        state = .scanning
        Task {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            switch (self.state) {
            case .waiting, .scanning:
                await self.stop()
            case .stopped, .failed:
                break;
            }
        }
    }
    
    internal func discovered(device: BleDevice) {
        if let discoverClosure = onDiscoverClosure {
            discoverClosure(device)
        }
    }

    internal func finished() async {
        state = .stopped
        onFinishedClosure?()
    }

    private func failed() async {
        state = .failed
        await manager.endCurrentScan(self)
        onFailedClosure?()
    }
    

}

//actor BleScanSession {
//    
//    var hasActiveScanners: Bool { get {scanners.count > 0} }
//    var managerIsDiscovering = false
//    
//    private var scanners = [BleScanner]()
//    private var foundDevices = [BleDevice]()
//    private var timer: BleScanTimer?
//    private weak var bleManager: BleManager?
//
//    internal init(_ bleManager: BleManager) async {
//        self.bleManager = bleManager
//        timer = BleScanTimer(self)
//    }
//    
//    public func new(seconds: Int, services: [CBUUID]? = nil) async -> BleScanner {
//        let scanner = BleScanner(seconds: seconds, session: self, services: services)
//        scanners.append(scanner)
//        for device in foundDevices {
//            await scanner.discovered(device: device)
//        }
//        bleManager?.checkDiscoveryStatus()
//        return scanner
//    }
//    
//    internal func found(device: BleDevice, advertisementData: [String: Any]) async {
//        if device.name == "0000314" {
//            print("found")
//        }
//        if foundDevices.filter({ foundDevice in foundDevice.uuid == device.uuid}).isEmpty {
//            foundDevices.append(device)
//            device.advertisementData = advertisementData
//            for scanner in scanners {
//                await scanner.discovered(device: device)
//            }
//        }
//    }
//    
//    internal func scanningStarted() {
//        managerIsDiscovering = true
//    }
//    
//    internal func scanningStopped() async {
//        managerIsDiscovering = false
//        for scanner in scanners {
//            await scanner.finished()
//        }
//        scanners.removeAll()
//        foundDevices.removeAll()
//    }
//    
//    fileprivate func decrementAndPrune() async {
//        guard managerIsDiscovering else {
//            // If manager never starts discovering, the scanners should eventually expire somehow
//            return
//        }
//        
//        var pruned = [BleScanner]()
//        var survivors = [BleScanner]()
//        for scanner in scanners {
//            if await !scanner.isReady {
//                // TODO This could keep scanning from ever finishing if a scanner is never ready
//                survivors.append(scanner)
//            } else {
//                await scanner.decrementSeconds()
//                if await scanner.remainingSeconds <= 0 {
//                    pruned.append(scanner)
//                } else {
//                    survivors.append(scanner)
//                }
//            }
//            
//        }
//        scanners = survivors
//        for s in pruned {
//            await s.finished()
//        }
//        bleManager?.checkDiscoveryStatus()
//    }
//    
//}
//
//actor BleScanner: NSObject {
//
//    fileprivate var remainingSeconds: Int
//    fileprivate var isReady: Bool { get { onDiscoverClosure != nil || onFinished != nil } }
//    
//    private let session: BleScanSession
//    private var onDiscoverClosure: ((BleDevice) -> ())?
//    private var onFinished: (() -> ())?
//    private var timer: Timer?
//    private let services: [CBUUID]?
//    
//    fileprivate init(seconds: Int, session: BleScanSession, services: [CBUUID]?) {
//        remainingSeconds = seconds
//        self.session = session
//        self.services = services
//    }
//    
//    func onDiscover(_ closure: @escaping (BleDevice) -> ()) -> Self {
//        onDiscoverClosure = closure
//        return self
//    }
//    
//    func onFinished(_ closure: @escaping () -> ()) -> Self {
//        onFinished = closure
//        return self
//    }
//    
//    fileprivate func decrementSeconds() async {
//        remainingSeconds = remainingSeconds - 1
//    }
//    
//    fileprivate func discovered(device: BleDevice) {
//        if let closure = onDiscoverClosure,
//           let cbuuids = device.advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID],
//           let s = services,
//           !s.filter({ serviceUuid in cbuuids.contains(serviceUuid) }).isEmpty
//        {
//                closure(device)
//        }
//    }
//    
//    fileprivate func finished() {
//        onFinished?()
//    }
//    
//}
//
//fileprivate class BleScanTimer {
//
//    private var scanTimer: Timer?
//    private weak var session: BleScanSession?
//    
//    internal init(_ session: BleScanSession) {
//        self.session = session
//        DispatchQueue.main.async {
//            self.scanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//                Task {
//                    await self.session?.decrementAndPrune()
//                }
//            }
//            self.scanTimer?.tolerance = 0.2
//        }
//    }
//    
//    deinit {
//        scanTimer?.invalidate()
//    }
//}
//
