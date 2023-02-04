//
//  File.swift
//  
//
//  Created by Adrian on 2/3/23.
//

import Foundation
import CoreBluetooth

class DiscoverServicesOp: BleDeviceOp {
    
    var waitingForServices = [CBUUID]()
    
    override func status(_ device: BleDevice, _ status: BleOpStatus) {
        switch(status) {
        case .nowActive:
            if let services = device.autoDiscoverServices {
                waitingForServices = services
                device.characteristics = []
                device.peripheral.discoverServices(services.compactMap { $0 })
                waitingForServices = services.compactMap { $0 }
            }

        // TODO: finish switch options
        case .complete:
            break;
        case .deviceDisconnected:
            break;
        case .deviceFailedToConnect:
            break;
        case .bleNotEnabled:
            break;
        }
    }
    
    
    override func peripheral(_ device: BleDevice, didDiscoverServices error: Error?) -> BleOpResponse {
        for service in device.peripheral.services ?? [] {
            device.peripheral.discoverCharacteristics(nil, for: service)
        }
        return .inProgress
    }
    
    override func peripheral(_ device: BleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) -> BleOpResponse {
        for characteristic in service.characteristics ?? [] {
            device.characteristics.append(characteristic)
        }
        
        waitingForServices.removeAll { uuid in uuid.uuidString == service.uuid.uuidString }
        
        return waitingForServices.isEmpty ? .complete : .inProgress

    }
}
