//
//  SPIViewController.swift
//  Bench
//
//  Created by Bench on 10/5/22.
//

import UIKit
import Foundation
import CoreBluetooth
import UniformTypeIdentifiers

class SPIViewController: UIViewController, BLEDelegate{
    private var reenableSwipeBackGestureTask: DispatchWorkItem?
    private var originalBackButton: UIBarButtonItem?
    // These are the links to the Textviews on the view controller
    @IBOutlet weak var datain: UITextView!
    @IBOutlet weak var dataout: UITextView!
    // Button to select the Data Type
    @IBOutlet weak var data_type: UIButton!
    @IBOutlet weak var datatypemenu: UIMenu!
    //UICommand are the subviews to the main buttons
    @IBOutlet weak var binary: UICommand!
    @IBOutlet weak var Hex: UICommand!
    //Most of these modes were disables due to other integration issues
    @IBOutlet weak var spi_mode: UIButton!
    @IBOutlet weak var mode3: UICommand!
    @IBOutlet weak var mode2: UICommand!
    @IBOutlet weak var mode1: UICommand!
    @IBOutlet weak var mode0: UICommand!
    //Spi menu is required to set the modes as sub views
    @IBOutlet weak var spimenu: UIMenu!
    
    //Did set is used to call the updateData function whenever the
    //State of the Varaible changes
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
    
    // Singleton BLE Class Setup
    var hexString: String = ""
    var binaryString: String = ""
    var asciiString: String?
    // asciiString might need the updateData call
    var asciiarray: [String] = []
    var binaryarray: [String] = []
    var dataString = ""
    var dataChunks = [String]()
    // Timer is needed to track how long the screen is locked for
    private var timer: Timer?
    
    // This Function Does the data processing
    func didReceiveData(_ data: Data) {
        print("\nUpdating Data")
        hexString = data.hexString
        asciiString = String(data: data, encoding: .utf8)
        print(asciiString ?? "No Data Received")
        // When the user makes a selection and the selection gets sent to the ESP32, the BLE class will read back the data sent so we must make sure
        // we dont parse that data or parse the blanks setnt from the esp
        if(asciiString == "0" || asciiString == "3A" || asciiString == "" || asciiString == "3B" || asciiString == "3C" || asciiString == "3D"){
            return
        }else{
            // --------------------- Batttery Update --------------------- Updates the battery display
            if let asciiString = asciiString {
                let datasplit = asciiString.components(separatedBy: "?")
                if(datasplit.count == 2){
                    if(datasplit[0] == "C"){
                        let battery_level = Float(datasplit[1])!/100.0
                        updateBatteryLevel(CGFloat(battery_level) , for: batteryView)
                        return
                    }
                }
            }
            // ------------------------------------------------------------

            dataString = asciiString!
            // clear dataChunks so that it does not continue adding to the data already seen on the screen
            dataChunks.removeAll()
            
            while !dataString.isEmpty { // Continues to parse until there is nothing left in the data string
                let dataChunk = String(dataString.prefix(8))
                dataChunks.append(dataChunk) // Gets 8 bits and adds it to an array
                if dataString.count > 8 { // if there is still more than 8 bits left in the string then update string to remove the bits parsed
                    dataString = String(dataString[dataString.index(dataString.startIndex, offsetBy: 8)...])
                } else { // if less than 8 bits left then set string to empty because improper data was received
                    dataString = ""
                }
                if !dataString.isEmpty {
                    let statusChunk = String(dataString.prefix(1))
                    dataChunks.append(statusChunk)
                    if dataString.count > 1 {
                        dataString = String(dataString[dataString.index(dataString.startIndex, offsetBy: 1)...])
                    } else {
                        dataString = ""
                    }
                }
            }
            print("Data: \(dataChunks)")
            updateData()
        }
    }
    
    func didWriteData() {
        print("Data was written to esp32")
    }
    
    // THis function is responsible for further formatting the data before displaying it on the app
    func updateData(){
        print("In Update Data")
        
        if (asciiString != "0"  && asciiString != "" && asciiString != "3A" && asciiString != nil ){
            if(Hex_selected == true){ // Displays data when Hex button is presseed
                print("In HEX Selection")
                var datain_output = ""
                var dataout_output = ""
                
                for index in stride(from: 0, to: dataChunks.count, by: 2) {
                    if index + 1 < dataChunks.count {
                        if ( dataChunks[index + 1 ] == "2"){
                            datain_output += binaryToHexString(dataChunks[index]) ?? "Error"
                            datain_output += " "
                        }else{
                            dataout_output += binaryToHexString(dataChunks[index]) ?? "Error" + " "
                            dataout_output += " "

                        }
                    }
                }
            
                self.datain.text = datain_output
                self.dataout.text = dataout_output
                
            }else if (binary_selected == true){// Displays when Binarry button is selected
                print("In Binary Selection")
                var datain_output = ""
                var dataout_output = ""
                
                for index in stride(from: 0, to: dataChunks.count, by: 2) {
                    if index + 1 < dataChunks.count {
                        if ( dataChunks[index + 1 ] == "2"){
                            datain_output += dataChunks[index] + " "
                        }else{
                            dataout_output += dataChunks[index] + " "
                        }
                    }
                }
                self.datain.text = datain_output
                self.dataout.text = dataout_output
            }else{ // this is hex
                print("No selection Made in SPI")
            }
        }
    }
    
    
     override func viewDidLoad() { // This sets up the view controller, buttons, and views
         super.viewDidLoad()
         //setPopupButton()
         title = "SPI"
         print("\nViewController: SPI\n")
         blemanager.reconnectBluetooth()  // This starts searching for the bluetooth device
         blemanager.delegate = self // Thsi sets the delegate
         // Setting up the buttons
         let Hex = UIAction(title: "HEX"){[weak self] action in
             print("HEX")
             self?.Hex_selected = true
             self?.binary_selected = false
             self?.data_type.setTitle("HEX", for: .normal)
         }
         
         let binary = UIAction(title: "Binary"){ [weak self] action in
             print("Binary")
             //self?.disableSwipeBackGestureAndBackButtonForTwoSeconds()
             self?.Hex_selected = false
             self?.binary_selected = true
             self?.data_type.setTitle("Binary", for: .normal)
         }

         let datatypemenu = UIMenu(title : "Data Type", options: .displayInline,
             children: [binary,Hex])
         data_type.menu = datatypemenu
         data_type.showsMenuAsPrimaryAction = true
         // Setting a default value
         self.binary_selected = true
         
         // These are the disabled modes
         // This was changed to be sent out automatically after connnecting
         // due to the fact that there is only one mode option
//         let mode0 = UIAction(title: "CPOL = 0 & CPHA = 0"){[weak self] action in
//             blemanager.writeOutgoingValue( "3A")
//             self?.data_sent_out = "3A"
//             self?.spi_mode.setTitle( "CPOL = 0 & CPHA = 0", for: .normal)
//             print("mode0")}
         
         // These Modes do not work so they are being removed from the option slection
//         let mode1 = UIAction(title: "CPOL = 0 & CPHA = 1"){[weak self] action in
//             blemanager.writeOutgoingValue( "3B")
//             self?.data_sent_out = "3B"
//             self?.spi_mode.setTitle("CPOL = 0 & CPHA = 1", for: .normal)
//             print("mode1")}
//
//         let mode2 = UIAction(title: "CPOL = 1 & CPHA = 0"){[weak self] action in
//             blemanager.writeOutgoingValue( "3C")
//             self?.data_sent_out = "3C"
//             self?.spi_mode.setTitle("CPOL = 1 & CPHA = 0", for: .normal)
//             print("mode2")}
//
//         let mode3 = UIAction(title: "CPOL = 1 & CPHA = 1"){[weak self] action in
//             blemanager.writeOutgoingValue( "3D")
//             self?.data_sent_out = "3D"
//             self?.spi_mode.setTitle("CPOL = 1 & CPHA = 1", for: .normal)
//             print("mode3")
//         }
         
//        let spimenu = UIMenu(title : "Mode Selection", options: .displayInline, children: [mode0,mode1,mode2,mode3])
//         spi_mode.menu = spimenu
//         spi_mode.showsMenuAsPrimaryAction = true
         
         //Register for Notification if the device disconnected
         NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: Notification.Name("DeviceDisconnected"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(deviceConnected(_:)), name: Notification.Name("DeviceConnected"), object: nil)
         //This sets the battery to NC
         navigationItem.rightBarButtonItem = batteryItem
         batteryView.level = -1
         batteryView.color = .systemRed
     }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\nYou are about to leave SPI Screen")
        //Stops scanning and disconnects
        blemanager.stopScanning()
        blemanager.disconnect()
        // Unregister from the notification
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DeviceDisconnected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DeviceConnected"), object: nil)
    }
    
    // Sets the battery to red if the device disconnects
    @objc func deviceDisconnected() {
        batteryView.level = -1.0
        batteryView.color = .systemRed
        blemanager.reconnectBluetooth() // Starts trying to reconnect
       }
    
    @objc func deviceConnected(_ notification: Notification) { // When there is an update to the connected notication
        print("Device connected")
        
        // set up the battery
        batteryView.level = 1.0
        batteryView.color = .systemGreen
        // Prevents the uesr from swiping away from the screen and locks the screen
       disableSwipeBackGestureAndBackButtonForTwoSeconds()
        // Sends a 0 to the esp
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            blemanager.writeOutgoingValue("0")
        }
        
        // then will send a letter to indicate to the esp which procotocl its in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            blemanager.writeOutgoingValue("3A")
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



