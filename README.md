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

## Scanning for devices

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

## Using a device

A BleDevice instance is an abstraction of a physical BLE device found during a scan. While you
probably want to read & write characteristics, in BleManager those actions are performed with
separate classes called a BleOp. The device instance itself is only directly used to control
the connection.

The following code sets up an connection event listener for the device, then the connect process is initiated. 

```swift
device.onStateChanged { device, state in
    switch (state) {
    case .connected:
        // schedule BleOp to read settings
        device.queueOp(...)
    case .failedToConnect:
        // keep trying to connect
        device.connect()
    case .disconnected:
        ...
    case .connecting:
        ...
    case .bleNotAvailable:
        ...
    }
}
device.connect()
```


## Device Operations (Ops)

BleOp classes are where the device interactions occur. Each device has it's own queue of 
BleOps that are executed in order, meaning each Op class can assume it's the only thing running
against it's device. You can create your own classes by extending BleOp.
 
The function start(_ device: BlemDevice) will be called when the instance is at the front of a device's queue and the device is connected. The function abort(_ device: BlemDevice, _ reason: BlemOpAbortReason) is called when Ops on a device have been prematurely stopped, often due to
unexpected device disconnections. The abort(...) method can be called before start(...) in some situations, for example when a device disconnects when multiple Ops have been queued.

All CBPeripheralDelegate callback methods are available as BleOp functions that can be overriden in your own classes.

```swift
public class ReadStringOp: BlemDeviceOp {
    
    private let uuid: CBUUID
    
    public init(uuid: CBUUID) {
        self.uuid = uuid
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
        // better safe than sorry
        guard let value = characteristic.value else { return .complete }

        // process the string
        if let str = String(data: value, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.controlCharacters) {
            // do something with str
        }
        
        return .complete
    }
    
    
}
```

TODO

* Review callback closures and change any to weak references where needed.
* Implement additions to handle BLE notifications
* NoOp op
* Clear/Reset Device List in Blem?
* Support background BLE mode

FAQ


