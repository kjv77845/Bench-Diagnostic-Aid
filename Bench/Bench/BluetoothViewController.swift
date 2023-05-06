//
//  BluetoothViewController.swift
//  Bench
//
//  Created by Bench on 10/22/22.
//

import Foundation
import UIKit
import CoreBluetooth
import UniformTypeIdentifiers

// ------------- This View can be Ignored, IT was used for Testing ----------------

let blemanager = BLEManager.shared
class BluetoothViewController: UIViewController, BLEDelegate{
    var hexString: String = ""
    var binaryString: String = ""
    var asciiString: String?
    var asciiarray: [String] = []
    var binaryarray: [String] = []
    let viewController = ViewController()
//    var batteryView: Battery!

    func didReceiveData(_ data: Data) {
        print("\nUpdating Data")
        hexString = data.hexString
        //print(hexString)
        asciiString = String(data: data, encoding: .utf8)
        //print(asciiString ?? "Nil String")
        binaryarray = data.map{ String($0, radix:2)}
        //print(binaryString)
        //print(data.hexString)
        //print(data.decimalString)
        binaryString = binaryarray.joined(separator: " ")
        //print(binaryString)
        //print("\nReceived data: \(hexString) / \(asciiString ?? "") (ascii)")
    }
    
    func didWriteData() {
        print("Data was written to esp32")
    }
    
    @IBAction func pressme(_ sender: Any) {
        updateBatteryLevel(0.1, for: batteryView)
        print("\nButton to Read was Pressed")
        print("Hex: \(hexString)")
        print("ASCII: \(asciiString ?? "")")
        print("Binary: \(binaryString)")
    
    }
    
    @IBAction func otherbutton(_ sender: Any) {
       // blemanager.writeOutgoingValue("16")
        // testing data parsing
        let asciiString = "61010100035810101000376101010004781010100048"
        var binaryout = ""
        var hexout = ""
        
        var startIndex = asciiString.startIndex
        while startIndex < asciiString.endIndex {
            let endIndex = asciiString.index(startIndex, offsetBy: 11, limitedBy: asciiString.endIndex) ?? asciiString.endIndex
            let dataChunk = asciiString[startIndex..<endIndex]

            let addrdataChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 0)])
            let dataaChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 1)..<dataChunk.index(dataChunk.startIndex, offsetBy: 9)])
            
            let addressChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 1)..<dataChunk.index(dataChunk.startIndex, offsetBy: 8)])
            
            let readWriteChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 8)])
            let nackAckChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 9)])
            let startstopChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 10)])

            if(addrdataChunk == "6"){
                binaryout += "\nAddress | 0" + addressChunk + " | "
                hexout += "\nAddress | " + (binaryToHexString("0" + addressChunk) ?? "Error") + " | "
                
                if (readWriteChunk == "0"){
                    binaryout += "Read "
                    hexout += "Read "
                }else{
                    binaryout += "Write | "
                    hexout += "Write | "
                }
    
            }else{
                binaryout += "Data    | " + dataaChunk +  " |      "
                hexout += "Data    | " + (binaryToHexString(dataaChunk) ?? "Error") + " |      "
            }
            
            if(nackAckChunk == "3"){
                binaryout += "| Ack"
                hexout += "| Ack"
            }else{
                binaryout += "| Nack "
                hexout += "| Nack "
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
        
        print(binaryout)
        print(hexout)
        
        
        
//        let header = Array(asciiString.prefix(11))
//        print(header)
//
//        let addrdata = String(header[0]) // 6 == addr 7 == data
//        let address = String(header[1..<9]) // data chunk
//        let readWrite = String(header[8]) // last bit of data chunk
//        let nackAck = String(header[9]) // 3 == ack 4 == nack
//        let startstop = String(header[10]) // 5 == stop 8 == continue
//
//        print("\(addrdata) \(address) \(readWrite) \(nackAck) \(startstop)")
//
//        let dataSubstring = asciiString.dropFirst(11)
//        //print(dataSubstring)
//
//        var startIndex = dataSubstring.startIndex
//        while startIndex < dataSubstring.endIndex {
//            let endIndex = dataSubstring.index(startIndex, offsetBy: 11, limitedBy: dataSubstring.endIndex) ?? dataSubstring.endIndex
//            let dataChunk = dataSubstring[startIndex..<endIndex]
//
//            let addrdataChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 0)])
//            let addressChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 1)..<dataChunk.index(dataChunk.startIndex, offsetBy: 9)])
//
//            print(binaryToHexString(addressChunk) ?? "Data could not be converted ")
//            let readWriteChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 8)])
//            let nackAckChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 9)])
//            let startstopChunk = String(dataChunk[dataChunk.index(dataChunk.startIndex, offsetBy: 10)])
//
//            print("\(addrdataChunk) \(addressChunk) \(readWriteChunk) \(nackAckChunk) \(startstopChunk)")
//
//            startIndex = endIndex
//        }
        
        
        
        
        
//        while !dataString.isEmpty {
//            let dataChunk = String(dataString.prefix(8))
//            dataChunks.append(dataChunk)
//
//            if dataString.count > 8 {
//                dataString = String(dataString[dataString.index(dataString.startIndex, offsetBy: 8)...])
//            } else {
//                dataString = ""
//            }
//
//            if !dataString.isEmpty {
//                let statusChunk = String(dataString.prefix(1))
//                dataChunks.append(statusChunk)
//
//                if dataString.count > 1 {
//                    dataString = String(dataString[dataString.index(dataString.startIndex, offsetBy: 1)...])
//                } else {
//                    dataString = ""
//                }
//            }
//        }
//
//        //for testing
//        print("Data received: \(asciiString)")
//        print("Address: \(address), RW: \(readWrite), NACK/ACK: \(nackAck), Data: \(dataChunks)")
//
//        var formattedOutput = ""
//        for index in stride(from: 0, to: dataChunks.count, by: 2) {
//            formattedOutput += binaryToHexString(dataChunks[index]) ?? "9"
//            if index + 1 < dataChunks.count {
//                let ack_nack_other = dataChunks[index + 1]
//                if (ack_nack_other == "3"){
//                    formattedOutput += " Ack\n"
//                }else if (ack_nack_other == "4"){
//                    formattedOutput += " Nack\n"
//                }else {
//                    formattedOutput += " Completed Without Error"
//                }
//            }
//        }
//        print(formattedOutput)
//
//
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Device Information"
        print("\nViewController: Device Information \n")
        //to get bluetooth working uncomment this
        //blemanager.reconnectBluetooth()
        //blemanager.delegate = self
        //NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: Notification.Name("DeviceDisconnected"), object: nil)
    

       // batteryView = Battery(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        //let batteryItem = UIBarButtonItem(customView: batteryView)
        navigationItem.rightBarButtonItem = batteryItem
        //batteryView.level = 0.0
        //batteryView.color = .systemRed


        

    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the navigation item
        navigationItem.hidesBackButton = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\nYou are about to leave Device Information Screen")
        //uncomment below to get bluetooth working
//        blemanager.stopScanning()
//        //blemanager.cancelPeripheralConnection()
//        blemanager.disconnect()
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("DeviceDisconnected"), object: nil)

        // im not sure why this is here
        let batteryView = Battery(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        batteryView.level = 0.5
        let batteryItem = UIBarButtonItem(customView: batteryView)
        navigationItem.rightBarButtonItem = batteryItem
        

    }
    
    @objc func deviceDisconnected() {
        blemanager.reconnectBluetooth()
       }
}

extension Data {

    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    var decimalString: String {
        return map { String(format: "%d", $0) }.joined()
    }
    
    var binaryString: String {
        return map{ String($0, radix:2)}.joined()
    }

}

extension String {
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0..<min($0+n, characters.count)])
            if $0+n < characters.count {
                result += separator
            }
        }
        return result
    }
}


func stringsToHexStrings(_ strings: [String]) -> [String] {
    return strings.compactMap { string in
        if let data = string.data(using: .utf8) {
            let hexString = data.map { String(format: "%02hhx", $0) }.joined(separator: " ")
            return hexString
        }
        return nil
    }
}


func stringsToBinaryStrings(_ strings: [String]) -> [String] {
    return strings.compactMap { string in
        if let data = string.data(using: .utf8) {
            let binaryString = data.flatMap { byte -> [String] in
                var bits: [String] = []
                for i in 0..<8 {
                    let bit = (byte >> (7 - i)) & 0x01
                    bits.append(String(bit))
                }
                return bits
            }.enumerated().map { index, bit in
                if (index + 1) % 8 == 0 {
                    return bit + " "
                }
                return bit
            }.joined()
            return binaryString
        }
        return nil
    }
}

func binaryToHexString(_ binaryString: String) -> String? {
    guard binaryString.count % 4 == 0 else { return nil }
    //print("made it inside of hex")
    var hexString = ""
    var index = binaryString.startIndex
    
    while index < binaryString.endIndex {
        let endIndex = binaryString.index(index, offsetBy: 4)
        let substring = binaryString[index..<endIndex]
        
        if let intValue = UInt8(substring, radix: 2) {
            hexString += String(format: "%01X", intValue)
        } else {
            return nil
        }
        
        index = endIndex
    }
    
    return hexString
}

extension NSMutableAttributedString {
    func appendWith(color: UIColor, text: String) {
        let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color])
        self.append(attributedString)
    }
}


//func stringToHexString(_ strings: [String]) -> [String] {
//    if let data = string.data(using: .utf8){
//        let hexString = data.map{ String(format: "%02hhx", $0) }.joined(separator: " ")
//        return hexString
//    }
//    return ""
//}
