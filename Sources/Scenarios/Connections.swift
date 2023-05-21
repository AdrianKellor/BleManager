//
//  File.swift
//  
//
//  Created by Adrian on 5/13/23.
//

import Foundation

simpleConnectAndDisconnect() {
    
    Blem.instance.newScanner(seconds: 15, services: [CBUUID(string: "")])
        .onDiscover { device in
            device.onStateChanged { bundle in
                if bundle.newState == .connected {
                    device.disconnect()
                }
            }
            device.connect()
        }.onFinished {
            // show scan is finished
        }.onFailed {
            // Show error msg
        }
    
}

