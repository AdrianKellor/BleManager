//
//  File.swift
//  
//
//  Created by Adrian on 2/3/23.
//

import Foundation
import CoreBluetooth

public class ReadStringOp: BleDeviceOp {
    
    private let uuid: CBUUID
    private let closure: (String?, String?) -> ()
    
    public init(uuid: CBUUID, _ closure: @escaping (String?, String?) -> ()) {
        self.uuid = uuid
        self.closure = closure
    }
    
    override public func status(_ device: BleDevice, _ status: BleOpStatus) {
        switch(status) {

        case .nowActive:
            if let char = device.characteristic(uuid) {
                device.peripheral.readValue(for: char)
            }
            
        case .complete, .deviceDisconnected, .deviceFailedToConnect, .bleNotEnabled:
            break;
        }
    }
    
    override public func peripheral(_ device: BleDevice, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) -> BleOpResponse {
        guard let value = characteristic.value else {
            return .complete
        }


        if let str = String(data: value, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.controlCharacters) {
            print(str)
            closure(str, nil)
        }
        
        return .complete
    }
    
    
}
