//
//  BLESingle.swift
//  Bench
//
//  Created by Bench on 1/15/23.
//final bluetooth class

import UIKit
import CoreBluetooth
import Foundation

protocol BLEDelegate: AnyObject{
    func didReceiveData(_ data: Data)
    func didWriteData()
}

class BLEManager: NSObject {
    //Shared Singleton Instance
    var startTime: DispatchTime? // This one is used to see how much time it takes for the BLE to connect
    // The rest of these are used to set up the Bluetooth class
    var device_connected = false
    var PreviouslyConnected = false
    var esp32Peripheral: CBPeripheral!
    var newDataReceived = false

    static let shared = BLEManager()
    private var centralManager: CBCentralManager!
    private var readCharactersistic: CBCharacteristic!
    private var writeCharactersistic: CBCharacteristic!
    private var receivedData: Data?
    private var connectedPeripheral: CBPeripheral?

    //This is the UUIDs used for testing on my ESP32
    //private var esp32UUID = CBUUID(string:"86e76b8b-c71c-44b8-8b3a-3b56704cbd85")
    //private let readCharacteristicUUID = CBUUID(string: "08e05570-7e07-486f-8a70-bc5198eff88b")
    //private let writeCharacteristicUUID = CBUUID(string: "08e05570-7e07-486f-8a70-bc5198eff88b")
    
    // These are the UUID for the ESP32 that is integrated in the system
   private var esp32UUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
   private var readCharacteristicUUID = CBUUID(string: "6E400003-B5A2-F393-E0A9-E50E24DCCA9E") // this is actually to write
   private var writeCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

    // These Variables are used for Data Processing
    private var characteristicReadValue = ""
    private var datasplit: [String] = []
    weak var delegate: BLEDelegate?
    
    //Since its a shared singleton class, this is to set the delegate of the view controller
    private override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Functions after this are declared to be able to be called within the view controllers
    func startScanning(){
      centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Scanning")
        // Uncomment this one when you are using the UUID to find the ESP32 instead of its name
        //centralManager.scanForPeripherals(withServices: [esp32UUID])
    }
    
    func stopScanning(){
        centralManager.stopScan()
    }

    //This function reads the value that is being read
    func readPeripherialValue() {
        if !newDataReceived {
            return
        }
        if esp32Peripheral != nil{
            print("In Reading Function")
            esp32Peripheral.readValue(for: readCharactersistic)
        } else {
            print("Error: Cannot read - Device Not Connected")
        }
        newDataReceived = false
    }

    // This function is used to reconnect for the first time and to reconnect if the connection is lost
    func reconnectBluetooth() {
        print("In reconnect BLuetootn ")
        startTime = DispatchTime.now() // This starts the timer
        if centralManager.state == .poweredOn{  //It will only .poweredOn after the ESP has connected at least once
            print("CentralManger is PoweredON")
            // Retrieve peripherals that were previously connected
            if( esp32Peripheral != nil){
                print("ESP32 is not NIL") // The print statements are used to track where in the connecting process the BLE is
                let connectedPeripherals = centralManager.retrievePeripherals(withIdentifiers: [esp32Peripheral.identifier])
                print("Made it past connect peripherals \(connectedPeripherals)")
                if let peripheral = connectedPeripherals.first { //if let makes rue that the last thing in the array is a Peripheral
                    print("Inside the Connect first \(String(describing: connectedPeripherals.first)) ") // This is the last item that was conneted
                    esp32Peripheral = peripheral
                    esp32Peripheral.delegate = self
                    centralManager.connect(esp32Peripheral, options:nil)  // this connects the device
                }
                print("Made it past first Peripherals")
            } else { // If no decice was previosuly connected then it will start scanning for a ble device
                print("Should Start Scanning")
                startScanning()
            }
        } else { // setting up the BLE for the first time
            centralManager.delegate = self
        }
    }
    
    // This writes to the BLE
    func writeOutgoingValue(_ value: String){
        print("In Writing Function")
        guard let data = value.data(using: .utf8) else { // Guard makes sure that the data being sent out is the correct format
            return
        }
        // error catching:  if not connected then dont write anything
        if let connectedPeripheral = connectedPeripheral, let writeCharactersistic = writeCharactersistic {
            connectedPeripheral.writeValue(data, for: writeCharactersistic, type: .withResponse)
            readPeripherialValue()
        } else {
            print("Error: Cannot write - Device Not Connected or Characteristic Not Initialized")
        }
    }
    
    // Used for disconnect process
    func cancelPeripheralConnection(){
        centralManager.cancelPeripheralConnection(esp32Peripheral)
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
        }
    }
    
}

// Checks to see what state the device is at
extension BLEManager: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            startScanning() // looking for esp32
        @unknown default:
            print("Bluetooth is not Available")
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("In Singleton Class Discovery")
        startTime = DispatchTime.now()
        print("Discovered Device: \(peripheral.name ?? "Unknown") (\(peripheral.identifier))")
        //Aaron's ESP31
        if ( peripheral.name == "Aaron's ESP32"){
            //uncomment below, all items correct Aaron's
            esp32Peripheral = peripheral
            esp32Peripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(esp32Peripheral, options:nil)

        }
        //This Should be used instead of the code section above if you are trying to find an esp by its uuid and not the name
//        esp32Peripheral = peripheral
//        esp32Peripheral.delegate = self
//        centralManager.stopScan()
//        centralManager.connect(esp32Peripheral, options:nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        // This Prints the time it took for it to connect
        if let startTime = startTime {
            // Use the startTime property here
            print(startTime)
            let currentTime = DispatchTime.now()
            print(currentTime)
            let timeElapsed = currentTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let timeElapsedInSeconds = Double(timeElapsed) / 1_000_000_000
            print("Time elapsed: \(timeElapsedInSeconds) seconds")
        } else {
            print("Timer was not started")
        }
        
        // Notification will let the View Controller know that the device has connected
        NotificationCenter.default.post(name: Notification.Name("DeviceConnected"), object: nil)
        device_connected = true
        connectedPeripheral = peripheral
        PreviouslyConnected = true
        // will only show esp32 services
        peripheral.delegate = self
        esp32Peripheral.discoverServices([esp32UUID])
        
    }
 
    //This is to notify that the view controller that the device has disconnected
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        NotificationCenter.default.post(name: Notification.Name("DeviceDisconnected"), object: nil) //notify the view controller
    }
}


extension BLEManager: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        print("In Discover Services")
        for service in services {
            print(service)
            if service.uuid == esp32UUID {
                //discovery of characteristics
                peripheral.discoverCharacteristics([readCharacteristicUUID, writeCharacteristicUUID], for: service)
                return
            }
        }
    }
    
    // need to fix issue with this function
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let data = characteristic.value else {return}
            let asciiString = String(data: data, encoding: .utf8)
                    if let asciiString = asciiString {
                        newDataReceived = true
                        print("Received ASCII data: \(asciiString)")  // This prints the data that was received
                        datasplit = asciiString.components(separatedBy: "?")
                        print("Datasplit: \(datasplit)\n")
                        delegate?.didReceiveData(data) // Notify the delegate that new data was received
                    }
        esp32Peripheral.setNotifyValue(true, for: characteristic) // Notify the toher functions that new data was received
    }


    //This is to update values
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        delegate?.didWriteData()
    }
    
    // Lets the function know when a characteristic was discovered 
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            print("Did not find services")
            return }
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
                // original is message
                writeCharactersistic = characteristic
            }
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                readCharactersistic = characteristic
                esp32Peripheral.setNotifyValue(true, for: characteristic)
                esp32Peripheral.readValue(for: characteristic)
            }
        }
    }
}
