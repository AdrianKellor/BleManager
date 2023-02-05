//
//  File.swift
//  
//
//  Created by Adrian on 2/3/23.
//

import Foundation
import CoreBluetooth

class DiscoverServicesOp: BlemDeviceOp {
    
    var waitingForServices = [CBUUID]()
    
    override func start(_ device: BlemDevice) -> BlemOpResponse {
        if let services = device.autoDiscoverServices {
            waitingForServices = services
            device.characteristics = []
            device.peripheral.discoverServices(services.compactMap { $0 })
            waitingForServices = services.compactMap { $0 }
            return .ok
        } else {
            return .complete
        }
    }
    
    override func abort(_ device: BlemDevice, _ reason: BlemOpAbortReason) {
        // TODO: clear device characteristics?
    }
    
    override func peripheral(_ device: BlemDevice, didDiscoverServices error: Error?) -> BlemOpResponse {
        for service in device.peripheral.services ?? [] {
            device.peripheral.discoverCharacteristics(nil, for: service)
        }
        return .ok
    }
    
    override func peripheral(_ device: BlemDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) -> BlemOpResponse {
        for characteristic in service.characteristics ?? [] {
            device.characteristics.append(characteristic)
        }
        
        waitingForServices.removeAll { uuid in uuid.uuidString == service.uuid.uuidString }
        
        return waitingForServices.isEmpty ? .complete : .ok

    }
}
