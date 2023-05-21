//
//  File.swift
//  
//
//  Created by Adrian on 5/13/23.
//

import Foundation
import CoreBluetooth

simpleScan() {
    
    Blem.instance.newScanner(seconds: 15, services: [CBUUID(string: "")])
        .onDiscover { device in
            //store device
        }.onFinished {
            // show scan is finished
        }.onFailed {
            // Show error msg
        }
    
}

class CustomScanDevice: BlemDevice {
    
    init(bundle: BlemDiscoveryBundle) {
        // set custom properties
        super.init(bundle);
    }
    
}

simpleScanWithCustomDevice() {
    
    Blem.instance.newScanner(seconds: 10, services: [CBUUID(string: "")])
        .onDiscoveryCreator { (bundle) -> BlemDevice? in
            CustomScanDevice(bundle)
        }.onDiscover { device in
            // use CustomScanDevice instance
        }.onFinished {
            // show scan is finish
        }. onFailed {
            // show error msg
        }
    
}

secondInterruptingScan() {
    Blem.instance.newScanner(seconds: 60, services: [CBUUID("")])
        .onFinished {
            // this will be called before 60 seconds due to second scan below...only once scanner is allowed
        }
    
    Blem.instance.newScanner(seconds: 10, services: [CBUUID("")])
        .onFinished {
            // this will be called in roughly 10 seconds.
        }
}
