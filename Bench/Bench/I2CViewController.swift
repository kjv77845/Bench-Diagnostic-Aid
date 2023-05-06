//
//  I2CViewController.swift
//  Bench
//
//  Created by Bench on 10/5/22.
//

import UIKit
import Foundation
import CoreBluetooth
import UniformTypeIdentifiers

class I2CViewController: UIViewController, BLEDelegate  {
    // Need this to replace button with "Initializing" When the device connects
    private var reenableSwipeBackGestureTask: DispatchWorkItem?
    private var originalBackButton: UIBarButtonItem?
    //All objects seen on the screen
    @IBOutlet weak var databits: UITextView!
    @IBOutlet weak var data_type: UIButton!
    @IBOutlet weak var datatypemenu: UIMenu!
    @IBOutlet weak var binary: UICommand!
    @IBOutlet weak var hex: UICommand!

    var asciiString: String?

    //Used to store split data components
    var datasplit: [String] = [] {
        didSet{
            updateData()
        }
    }
    
    var Hex_selected = false {
        didSet{
            updateData()
        }
    }
    var binary_selected = false {
        didSet{
            updateData()
        }
    }
    
    var dataString = ""
    var binaryout = ""
    var hexout = ""
    var first = true
    
    // All Data parsing happens here
    func didReceiveData(_ data: Data) {
        print("\nUpdating Data")
        asciiString = String(data: data, encoding: .utf8)
        if let asciiString = asciiString, !asciiString.isEmpty {
            if(asciiString == "2" || asciiString == "0"){return}
            
            // --------------------- Batttery Update ---------------------
            let check_battery = asciiString.components(separatedBy: "?")
            if(check_battery.count == 2){
                if(check_battery[0] == "C"){
                    let battery_level = Float(check_battery[1])!/100.0
                    updateBatteryLevel(CGFloat(battery_level) , for: batteryView)
                    return
                }
            }
            // ------------------------------------------------------------
            
            binaryout.removeAll()
            hexout.removeAll()
            first = true
            var startIndex = asciiString.startIndex
            while startIndex < asciiString.endIndex {
                let endIndex = asciiString.index(startIndex, offsetBy: 11, limitedBy: asciiString.endIndex) ?? asciiString.endIndex
                let dataChunk = asciiString[startIndex..<endIndex]
                let addrdataChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 0)])
                
                if dataChunk.count < 11 {
                    print("Data Set Not Correct \(dataChunk)")
                    binaryout += "Data Set Not Correct " + dataChunk
                    break
                }
                
                // Obtaining data from dataChunk received
                let dataaChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 1)..<dataChunk.index(dataChunk.startIndex, offsetBy: 9)])
                let addressChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 1)..<dataChunk.index(dataChunk.startIndex, offsetBy: 8)])
                let readWriteChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 8)])
                let nackAckChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 9)])
                let startstopChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 10)])
                
                // Eeach if statement checks a bit to see the data received and adds the interpreted results to the corresponding variable
                if(addrdataChunk == "6"){
                    if (first){
                        binaryout += "Address | " + addressChunk + " | "
                        hexout += "Address | " + (binaryToHexString("0" + addressChunk) ?? "Error") + " | "
                        first = false
                    }else{
                        binaryout += "\nAddress | " + addressChunk + " | "
                        hexout += "\nAddress | " + (binaryToHexString("0" + addressChunk) ?? "Error") + " | "
                    }
                    
                    if (readWriteChunk == "1"){
                        binaryout += "Read "
                        hexout += "Read "
                    }else{
                        binaryout += "Write "
                        hexout += "Write "
                    }
                }else{
                    binaryout += "Data       | " + dataaChunk + " "
                    hexout += "Data       | " + (binaryToHexString(dataaChunk) ?? "Error") + " "
                }
                
                if(nackAckChunk == "3"){
                    binaryout += "| Ack"
                    hexout += "| Ack"
                }else{
                    binaryout += "| Nack"
                    hexout += "| Nack"
                }
                
                if(startstopChunk == "5"){
                    binaryout += " | STOP \n"
                    hexout += " | STOP \n"
                }else{
                    binaryout += "\n"
                    hexout += "\n"
                }
                
                print("\(addrdataChunk) \(addressChunk) \(readWriteChunk) \(nackAckChunk) \(startstopChunk)")
                
                startIndex = endIndex
            }
            
            datasplit = ["Completed"]
        }
    }
    
    func didWriteData() {
        print("Data was written to esp32")
    }
    
    // Display the data to the screen when the function is called
    func updateData(){
        print("IN Update Data")
//        print(Hex_selected)
//        print(binary_selected)
//        print(binaryout.count)
        
        if (binaryout.count != 0){
            if(Hex_selected == true){
                print("Inside of Hex")
                self.databits.text = hexout
                
            }else if (binary_selected == true){
                print("Inside of Binary")
                self.databits.text = binaryout
            }else{
                print("No selection Made in I2C")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "I2C"
        print("\nViewController: I2C\n")
        blemanager.reconnectBluetooth()
        blemanager.delegate = self
        
        let hex = UIAction(title: "HEX"){[weak self] action in
            print("Hex")
            self?.Hex_selected = true
            self?.binary_selected = false
            self?.data_type.setTitle("HEX", for: .normal)
        }
        
        let binary = UIAction(title: "Binary"){[weak self] action in
            print("Binary")
            self?.Hex_selected = false
            self?.binary_selected = true
            self?.data_type.setTitle("Binary", for: .normal)
        }
        
        let datatypemenu = UIMenu(title : "Data Type", options: .displayInline, children: [binary,hex])
        data_type.menu = datatypemenu
        //Setting binary as default
        self.binary_selected = true
        data_type.showsMenuAsPrimaryAction = true
        
        //Register for Notification if the device disconnected
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: Notification.Name("DeviceDisconnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnected(_:)), name: Notification.Name("DeviceConnected"), object: nil)
        
        // Setting up the Battery
        navigationItem.rightBarButtonItem = batteryItem
        batteryView.level = -1
        batteryView.color = .systemRed
    }
    
    //Disconnect the device when the user goes into main screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\nYou are about to leave I2C Screen")
        blemanager.stopScanning()
        blemanager.disconnect()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DeviceDisconnected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DeviceConnected"), object: nil)
    }
    
    // Update the battery view when the device is disconnected
    @objc func deviceDisconnected() {
        batteryView.level = -1.0
        batteryView.color = .systemRed
        blemanager.reconnectBluetooth()
    }
    
    // notificatinons object can be used when data is attached to it
    @objc func deviceConnected(_ notification: Notification) {
        // Perform desired action when the device is connected
        print("Device connected")
        // set up the battery
        batteryView.level = 1.0
        batteryView.color = .systemGreen
        
        // Lock the screen for 2 seconds to prevent the device from going into an unrechable state
        disableSwipeBackGestureAndBackButtonForTwoSeconds()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            blemanager.writeOutgoingValue("0")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            blemanager.writeOutgoingValue("2")
        }
        
    }
    
    func disableSwipeBackGestureAndBackButtonForTwoSeconds() {
        // Cancel any existing DispatchWorkItem
        reenableSwipeBackGestureTask?.cancel()
        
        // Disable the interactive pop gesture recognizer
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // Store the original back button and replace it with a disabled custom button
        originalBackButton = navigationItem.leftBarButtonItem
        
        let backButtonTitle = navigationController?.navigationBar.topItem?.backBarButtonItem?.title ?? "Initializing"
        let disabledBackButton = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
        disabledBackButton.isEnabled = false
        navigationItem.leftBarButtonItem = disabledBackButton
        
        // Create a new DispatchWorkItem to re-enable the interactive pop gesture recognizer and show the back button after 2 seconds
        reenableSwipeBackGestureTask = DispatchWorkItem { [weak self] in
            print("Should have finished connecting")
            self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            
            // Restore the original back button
            self?.navigationItem.leftBarButtonItem = self?.originalBackButton
        }
        
        // Execute the DispatchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: reenableSwipeBackGestureTask!)
    }
    
}
