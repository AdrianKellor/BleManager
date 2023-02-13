# BleManager

BleManager is a library that makes CoreBluetooth code easier to read and maintain. 

While CoreBluetooth provides everything you need to interface with BLE devices, it stops
short of providing helpful structure for the handling of state and connectivity in your code
Left to you is the complicated task of managing what state your reads/writes are in, queueing 
of multiple read/write processes, state resets with unexpected disconnects, etc.

Your BleManager allows for focused classes that can assume they are the only interactions 
happening with a device. That makes your application code easier to write, read and maintain.


# Quick Start

## Initializing

Add the following code somewhere in your app startup code to initialize BleManager:

```swift
_ = Blem.instance
```

## Scanning

This code begins a 10 second scanning for devices that support YOUR_SERVICE_CBUUID.

```swift
await Blem.instance.newScanner(seconds: 10, services: [YOUR_SERVICE_CBUUID])
    .onDiscover { device in
        // use your discovered BleDevice instance
    }
    .onFinished {
        // handle scan duration completion
    }
    .onFailed {
        // handle error that occured during scanning
    }
    .start();
```                

Blem.instance.newScanner(...) returns an initialzed but unstarted scanner, it is highly recommended
that you define the onDiscover, onFinished and onFailed closures BEFORE calling the start() method
to start the BLE scanning process.

Only one scan can be active at once, if a new scan is started with the start() method a scan already in process will be halted early and it's onFinished closure will be called.

By default a device sent to onDiscover is a BleDevice instance, but BleDevice can be extended
with your own custom class if you prefer...

```swift
await Blem.instance.newScanner(seconds: 10, services: [YOUR_SERVICE_CBUUID])
    .onDiscoveryCreator { peripheral, advertisementData, rssi in
        return MyBleDeviceClass(peripheral: peripheral, advertisementData: advertisementData, rssi: rssi)
    }
    .onDiscover { device in
        // use your discovered BleDevice instance
    }
    .onFinished {
        // handle scan duration completion
    }
    .onFailed {
        // handle error that occured during scanning
    }
    .start();
```                


TODO

* Review callback closures and change any to weak references where needed.
* Implement additions to handle BLE notifications


FAQ


