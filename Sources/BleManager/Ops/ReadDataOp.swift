//
//  File.swift
//  
//
//  Created by Adrian on 5/16/23.
//

import Foundation
import CoreBluetooth

public class ReadDataOp: BlemDeviceOp {
    
    
    private let uuid: CBUUID
    private let closure: (Data?, String?) -> ()
    
    public init(uuid: CBUUID, _ closure: @escaping (Data?, String?) -> ()) {
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
        
        closure(characteristic.value, error?.localizedDescription)

        return .complete

    }
    
 
    
}
