//
//  MainViewController.swift
//  Bench
//
//  Created by Bench on 11/9/22.
//

import UIKit

class MainViewController: UIViewController{
    
    

    //var bleSingle: BLESingle!
    //let blemanager = BLEManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n")
        //self.navigationController?.navigationBar.delegate = self
        //blemanager.delegate = self
        //bleSingle = Bench.BLESingle(serviceUUID: "86e76b8b-c71c-44b8-8b3a-3b56704cbd85", delegate: self)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension MainViewController: BLESingleDelegate{
//    func BLESingle(BLESingle: BLESingle, didReceiveValue value: Int8) {
//        print("in the weired function")
//        print(value)
//    }
//}
