//
//  File.swift
//  
//
//  Created by Adrian on 5/21/23.
//

import Foundation

public basicNotify() {
    // assuming a device is found and connected, subscribe to a notification
    BlemDevice device = new BlemDevice()
    
    device.notifyManager.notify(
        BlemNotifyObserver(weakOwner: self, CBUUID(string: "1234"))
        .onData { data ->
            
        }.onError { error ->
            
        }.onStopped {
            
        }
    )
}

public startNotifyAndCancelAfter5() {
    
}
