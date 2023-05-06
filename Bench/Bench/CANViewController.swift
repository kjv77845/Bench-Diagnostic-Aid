//
//  CANViewController.swift
//  Bench
//
//  Created by Bench on 10/5/22.
//
//
//import UIKit
//import Foundation
//import CoreBluetooth
//import UniformTypeIdentifiers
// ------------------- CAN NOT IMPLEMENTED ====================
//class CANViewController: UIViewController, BLEDelegate {
//    @IBOutlet weak var can_type: UIButton!
//    @IBOutlet weak var canmenu: UIMenu!
//    @IBOutlet weak var versionBB: UICommand!
//    @IBOutlet weak var versionA: UICommand!
//
//    @IBOutlet weak var data_type: UIButton!
//    @IBOutlet weak var datatypemenu: UIMenu!
//
//    @IBOutlet weak var binary: UICommand!
//    @IBOutlet weak var hex: UICommand!
//
//    @IBOutlet weak var baud_rate: UIButton!
//    @IBOutlet weak var baudmenu: UIMenu!
//    @IBOutlet weak var b125: UICommand!
//    @IBOutlet weak var b250: UICommand!
//    @IBOutlet weak var b500: UICommand!
//    @IBOutlet weak var b1000: UICommand!
//
//    @IBOutlet weak var datain: UITextView!
//
//    var typesentout = ""
//    var versiontype = ""
//    var baud = ""
//    var versionchange = ""
//
//    // Singleton Setup
//    var hexString: String = ""
//    var binaryString: String = ""
//    var asciiString: String?
//    var asciiarray: [String] = []
//    var binaryarray: [String] = []
//
//    //Used to store split components
//    var datasplit: [String] = [] {
//        didSet{
//            updateData()
//        }
//    }
//
//    var Hex_selected = false {
//        didSet{
//            updateData()
//        }
//    }
//    var binary_selected = false {
//        didSet{
//            updateData()
//        }
//    }
//
//    func updateData(){
//        print("IN Update Data")
//        print(Hex_selected)
//        print(binary_selected)
//        if (datasplit != []){
//            if(Hex_selected == true){
//                //convert entire array to hex using function
//                //let hex_array = datasplit.map { stringToHexString($0)}
//                print("Datasplit before conversion")
//                print(datasplit)
//                let hex_array = stringsToHexStrings(datasplit)
//                self.datain.text = hex_array.joined(separator: " ")
//            }else if (binary_selected == true){
//                let binary_array = stringsToBinaryStrings(datasplit)
//                self.datain.text = binary_array.joined(separator: " ")
//            }else{ // this is hex
//                print("No selection Made in CAN")
//            }
//        }
//
//    }
//
//    func didReceiveData(_ data: Data) {
//        print("\nUpdating Data")
//        hexString = data.hexString
//        asciiString = String(data: data, encoding: .utf8)
//        self.datasplit = self.asciiString!.components(separatedBy: " , ")
//    }
//
//    func didWriteData() {
//        print("Data was written to esp32")
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "CAN"
//        // Set up Bluetooth First
//        print("\nViewController: CAN\n")
//        blemanager.reconnectBluetooth()
//        blemanager.delegate = self
//        // Setting up Mode Selection Pop Up
//        let versionA = UIAction(title: "CAN: 2.0A Standard"){(action) in
//            print("Can Standard")}
//
//        let versionB = UIAction(title: "CAN: 2.0B Extended"){(action) in
//            print("Can Extended")}
//
//
//        let canmenu = UIMenu(title : "Mode Selection", options: .displayInline, children: [versionA,versionB])
//
//        can_type.menu = canmenu
//        can_type.showsMenuAsPrimaryAction = true
//
//
//        let hex = UIAction(title: "Hex"){(action) in
//            print("Hex")
//            self.Hex_selected = true
//            self.binary_selected = false
//        }
//
//        let binary = UIAction(title: "Binary"){(action) in
//            print("Binary")
//            self.Hex_selected = false
//            self.binary_selected = true
//        }
//
//
//        let datatypemenu = UIMenu(title : "Data Type", options: .displayInline,
//            children: [hex,binary])
//        data_type.menu = datatypemenu
//        data_type.showsMenuAsPrimaryAction = true
//        // Setting up Baud Rate Selection Button
//        typesentout += versiontype
//        let b125 = UIAction(title: "125 kbaud"){(action) in
//            print("125 kbaud")}
//
//        let b250 = UIAction(title: "250 kbaud"){(action) in
//            print("250 kbaud")}
//
//        let b500 = UIAction(title: "500 kbaud"){(action) in
//            print("500 kbaud")}
//
//        let b1000 = UIAction(title: "1000 kbaud"){(action) in
//            print("1000 kbaud")}
//
//        let baudmenu = UIMenu(title : "Baud Rate Selection", options: .displayInline,
//                              children: [b125,b250,b500,b1000])
//        baud_rate.menu = baudmenu
//        baud_rate.showsMenuAsPrimaryAction = true
//
//        //Register for Notification if the device disconnected
//        NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: Notification.Name("DeviceDisconnected"), object: nil)
//
//        //setting up battery
//        navigationItem.rightBarButtonItem = batteryItem
//
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        print("\nYou are about to leave CAN Screen")
//        blemanager.stopScanning()
//        //blemanager.cancelPeripheralConnection()
//        blemanager.disconnect()
//
//        // Unregister from the notification
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("DeviceDisconnected"), object: nil)
//    }
//
//    @objc func deviceDisconnected() {
//        blemanager.reconnectBluetooth()
//       }
//
//}
