//
//  UARTViewController.swift
//  Bench
//
//  Created by Bench on 11/25/22.
// all functions for this are correct

// More Details information on how each functions works can be found in SPI view controller

import UIKit
import Foundation
import CoreBluetooth
import UniformTypeIdentifiers

class UARTViewController: UIViewController, BLEDelegate {
    // Variables to replace current back button when device connects
    private var reenableSwipeBackGestureTask: DispatchWorkItem?
    private var originalBackButton: UIBarButtonItem?
    // These are text viwes
    @IBOutlet weak var tx: UITextView!
    @IBOutlet weak var rx: UITextView!
    //Variables to set up Data Selection
    @IBOutlet weak var data_type: UIButton!
    @IBOutlet weak var datatypemenu: UIMenu!
    @IBOutlet weak var binary: UICommand!
    @IBOutlet weak var ascii: UICommand!
    // Variables to set up Baud Rate Selection
    @IBOutlet weak var ratebaud: UIButton!
    @IBOutlet weak var baudmenu: UIMenu!
    @IBOutlet weak var b300: UICommand!
    @IBOutlet weak var b600: UICommand!
    @IBOutlet weak var b750: UICommand!
    @IBOutlet weak var b1200: UICommand!
    @IBOutlet weak var b2400: UICommand!
    @IBOutlet weak var b4800: UICommand!
    @IBOutlet weak var b9600: UICommand!
    @IBOutlet weak var b19200: UICommand!
    @IBOutlet weak var b38400: UICommand!
    @IBOutlet weak var b57600: UICommand!
    @IBOutlet weak var b115200: UICommand!

    // Singleton Class Setup
    var binaryString: String = ""
    var asciiString: String?
    var asciiarray: [String] = []
    
    //Used to store split data components
    var datasplit: [String] = []
    // Call Update Data Function when ascii button or binary button is selected or state is changed
    var ascii_selected = false {
        didSet{
            updateData()
        }
    }
    var binary_selected = false {
        didSet{
            updateData()
        }
    }
    // Stting all variables to empty
    var data_sent_out = ""
    var ascii_in_rx = ""
    var ascii_in_tx = ""
    var bin_in_rx = ""
    var bin_in_tx = ""

    // Parsing the data recevied
    func didReceiveData(_ data: Data) {
        if ( data.count > 0 ){
            print("Updating Data")
            // Convert the input data to an ASCII string
            asciiString = String(data: data, encoding: .utf8)
            if let asciiString = asciiString, !asciiString.isEmpty {
                if(asciiString == data_sent_out ){return}
                // Split the ASCII string into an array using the "?" delimiter
                self.datasplit = asciiString.components(separatedBy: "?")
                if(datasplit.count == 2 ){
                    if(datasplit[0] == ""){return}
                    
                    // --------------------- Batttery Update ---------------------
                    if (datasplit[0] == "C"){
                        let battery_level = Float(datasplit[1])!/100.0
                        updateBatteryLevel(CGFloat(battery_level) , for: batteryView)
                        return
                    }
                    // ------------------------------------------------------------
                    // if data contains 1 then set it to the proper variable, same thing for 2
                    // will convert to hex to already have hex values
                    if(datasplit[1] == "1"){
                        ascii_in_tx.removeAll()
                        ascii_in_tx = datasplit[0]
                        bin_in_tx.removeAll()
                        bin_in_tx = datasplit[0].utf8.map { String($0, radix:2)}.joined(separator: " ")
                        updateData()
                    }else if (datasplit[1] == "2"){
                        ascii_in_rx.removeAll()
                        bin_in_rx.removeAll()
                        ascii_in_rx = datasplit[0]
                        bin_in_rx = datasplit[0].utf8.map { String($0, radix:2)}.joined(separator: " ")
                        updateData()
                    }else{
                        print("Received Something that is not a 1 or 2")
                    }
                }
                else{
                    print("Wrong Data Count for UART or Blank Received")
                }
            } else {
                print("No valid ASCII data received")
            }
        }
    }

    // this function is called to display the data to the screen
    func updateData(){
        // if the data has not been updated then return or else it will print empty strings to the screen
        print(ascii_in_rx)
        print(ascii_in_tx)
        if(ascii_in_rx == "" && ascii_in_tx == "" ){return}
        if(ascii_selected){
            print("Ascii_selected \(ascii_selected)")
            if(ascii_in_tx != ""){
                self.tx.text = ascii_in_tx
            }
            if(ascii_in_rx != ""){
                self.rx.text = ascii_in_rx
            }
        }else if (binary_selected){
            print("binary Selection \(binary_selected)")
            if(bin_in_rx != "")
            {
                self.rx.text = bin_in_rx
            }
            if(bin_in_tx != ""){
                self.tx.text = bin_in_tx
            }
            
        }else{
            print("No Selection Made ")
        }
    }
    
    func didWriteData() {
        print("Data was written to esp32")
    }
    
    // This is what sets up the view before it appears on the screen
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UART"
        print("\nViewController: UART\n")
        // Setting up the buttons
        let ascii = UIAction(title: "ASCII"){[weak self] action in
            print("ASCII")
            self?.ascii_selected = true
            self?.binary_selected = false
            self?.data_type.setTitle("ASCII", for: .normal)
        }
        
        let binary = UIAction(title: "Binary") { [weak self] action in
            print("Binary")
            self?.ascii_selected = false
            self?.binary_selected = true
            // Update the button label to show that "Binary" is selected
            self?.data_type.setTitle("Binary", for: .normal)
        }
        
        let datatypemenu = UIMenu(title : "Data Type", options: .displayInline,
            children: [binary,ascii])
        data_type.menu = datatypemenu
        data_type.menu = datatypemenu
        //Setting Ascii as Default
        self.ascii_selected = true
        data_type.showsMenuAsPrimaryAction = true
        
        let b300 = UIAction(title: "300 baud"){[weak self] action  in
            blemanager.writeOutgoingValue("1A")
            self?.data_sent_out = "1A"
            self?.ratebaud.setTitle("300 baud", for: .normal)
            print("300 baud")}
        
        let b600 = UIAction(title: "600 baud"){[weak self] action  in
            blemanager.writeOutgoingValue("1B")
            self?.data_sent_out = "1B"
            self?.ratebaud.setTitle("600 baud", for: .normal)
            print("600 baud")}
        
        let b750 = UIAction(title: "750 baud"){[weak self] action  in
            blemanager.writeOutgoingValue("1C")
            self?.data_sent_out = "1C"
            self?.ratebaud.setTitle("750 baud", for: .normal)
            print("750 baud")}
        
        let b1200 = UIAction(title: "1200 baud"){[weak self] action in
            blemanager.writeOutgoingValue("1D")
            self?.data_sent_out = "1D"
            self?.ratebaud.setTitle("1200 baud", for: .normal)
            print("1200 baud")}
        
        let b2400 = UIAction(title: "2400 baud"){[weak self] action in
            blemanager.writeOutgoingValue("1E")
            self?.data_sent_out = "1E"
            self?.ratebaud.setTitle("2400 baud", for: .normal)
            print("2400 baud")}
        
        let b4800 = UIAction(title: "4800 baud"){[weak self] action in
            blemanager.writeOutgoingValue("1F")
            self?.data_sent_out = "1F"
            self?.ratebaud.setTitle("4800 baud", for: .normal)
            print("4800 baud")}
        
        let b9600 = UIAction(title: "9600 baud"){[weak self] action in
            blemanager.writeOutgoingValue("1G")
            self?.data_sent_out = "1G"
            self?.ratebaud.setTitle("9600 baud", for: .normal)
            print("9600 baud")}
        
        let b19200 = UIAction(title: "19200 baud"){[weak self] action in
            blemanager.writeOutgoingValue("1H")
            self?.data_sent_out = "1H"
            self?.ratebaud.setTitle("19200 baud", for: .normal)
            print("19200 baud")}
        
        let b38400 = UIAction(title: "38400 baud"){[weak self] action in
            blemanager.writeOutgoingValue("1I")
            self?.data_sent_out = "1I"
            self?.ratebaud.setTitle("38400 baud", for: .normal)
            print("38400 baud")}
        
        let b57600 = UIAction(title: "57600 baud"){[weak self] action in
            blemanager.writeOutgoingValue("1J")
            self?.data_sent_out = "1J"
            self?.ratebaud.setTitle("57600 baud", for: .normal)
            print("57600 baud")}
        
        let b115200 = UIAction(title: "115200 baud"){[weak self] action in
            blemanager.writeOutgoingValue("1K")
            self?.data_sent_out = "1K"
            self?.ratebaud.setTitle("115200 baud", for: .normal)
            print("115200 baud")}
        
        let baudmenu = UIMenu(title : "Baud Rate Selection", options: .displayInline,
        children: [b300,b600,b750,b1200,b2400,b4800,b9600,b19200
                  ,b38400,b57600,b115200])
        ratebaud.menu = baudmenu
        ratebaud.showsMenuAsPrimaryAction = true
        
        // Do any additional setup after loading the view.
        //Register for Notification if the device disconnected
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: Notification.Name("DeviceDisconnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnected(_:)), name: Notification.Name("DeviceConnected"), object: nil)
        // Sets the battery display to NC in RED
        navigationItem.rightBarButtonItem = batteryItem
        batteryView.level = -1
        batteryView.color = .systemRed
    }
    
    // Once the view appears the then start searching for ESP32 and delegate
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        blemanager.reconnectBluetooth() //Starting Connection
        blemanager.delegate = self
    }

    // When the user swips to the main page
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\nYou are about to leave UART Screen")
        // Disconnect Device to prevent errros
        blemanager.stopScanning()
        blemanager.disconnect()
        blemanager.newDataReceived = false
        // Unregister from the notification
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DeviceDisconnected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("DeviceConnected"), object: nil)

    }
    
    //Update how the battery looks like when the device is disconnected
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
    
        // need to test this
       disableSwipeBackGestureAndBackButtonForTwoSeconds()
        let secondsToDelay = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
        blemanager.writeOutgoingValue("0")
        }
        // need to check that this works 
        if(self.data_sent_out != "" ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                blemanager.writeOutgoingValue(self.data_sent_out)
            }
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


