//
//  File.swift
//  
//
//  Created by Adrian on 2/3/23.
//

import Foundation
import CoreBluetooth

public class ReadStringOp: BlemDeviceOp {
    
    private let uuid: CBUUID
    private let closure: (String?, String?) -> ()
    
    public init(uuid: CBUUID, _ closure: @escaping (String?, String?) -> ()) {
        self.uuid = uuid
        self.closure = closure
    }
    
    public override func start(_ device: BlemDevice) -> BlemOpResponse {
        if let char = device.characteristic(uuid) {
            device.peripheral.readValue(for: char)
            return .ok
        } else {
            return .complete
        }
    }
    
    public override func abort(_ device: BlemDevice, _ reason: BlemOpAbortReason) {
        // do nothing
    }
    
    override public func peripheral(_ device: BlemDevice, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) -> BlemOpResponse {
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
