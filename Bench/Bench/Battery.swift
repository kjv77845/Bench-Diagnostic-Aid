//
//  Battery.swift
//  Bench
//
//  Created by Bench on 3/4/23.
//

import UIKit
//var batteryView: Battery!
var batteryView = Battery(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
let batteryItem = UIBarButtonItem(customView: batteryView)

class Battery: UIView {
    
    // Battery level value between 0 and 1 
    var level: CGFloat = -1.0 { // Set initial value to -1 to indicate no connection
        didSet {
                        if level >= 0 { // if the level received is acceptable then will display level and set color
                            levelLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * level, height: bounds.height)
                            levelLabel.textColor = UIColor.label
                            levelLabel.text = "\(Int(level * 100))%"
                        } else { // if not then it will set it to red and display NC
                            levelLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * 1, height: bounds.height)
                            levelLabel.textColor = UIColor.label
                            levelLabel.text = "-NC-"
                        }
                }
    }

    // Sets the Battery color
    var color: UIColor = .systemRed
{
        didSet {
            //stroke is the color of the outline of the battery
            batteryLayer.strokeColor = color.cgColor
            //color that fills in the battery
            levelLayer.backgroundColor = color.cgColor
        }
    }
    
    // Layers for battery outline and level indicator
    private let batteryLayer = CAShapeLayer()
    private let levelLayer = CALayer()

    // Label to display the battery level value
    private let levelLabel = UILabel()

    // Initialize the view with default values
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    // Initialize the view from Interface Builder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // Draw the battery outline, add the level indicator layer, and set up the label
    private func setup() {
        // Set up the battery layer
        batteryLayer.strokeColor = color.cgColor
        batteryLayer.lineWidth = 2
        batteryLayer.fillColor = UIColor.clear.cgColor
        batteryLayer.lineCap = .round
        batteryLayer.lineJoin = .round
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: 4)
        batteryLayer.path = path.cgPath
        layer.addSublayer(batteryLayer)

        // Set up the level indicator layer
        if(level == -1 ){
            levelLayer.frame = CGRect(x: 2, y: 2, width: bounds.width * 1 - 4, height: bounds.height - 4)
        }else{
            levelLayer.frame = CGRect(x: 2, y: 2, width: bounds.width * level - 4, height: bounds.height - 4)
        }
        //levelLayer.frame = CGRect(x: 2, y: 2, width: bounds.width * level - 4, height: bounds.height - 4)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        levelLayer.mask = maskLayer
        //levelLayer.backgroundColor = UIColor.systemGreen.cgColor
        levelLayer.backgroundColor = UIColor.systemRed.cgColor

        layer.addSublayer(levelLayer)

        // Set up the level label
        levelLabel.font = UIFont.systemFont(ofSize: 12)
        levelLabel.textColor = UIColor.label
        levelLabel.textAlignment = .center
        
        if (level == -1 ){
            levelLabel.text = "-NC-"
        }else{
            levelLabel.text = "\(Int(level * 100))%"
        }
        
        addSubview(levelLabel)
    }


    // Layout the layers and label when the view's size changes
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: 4)
        batteryLayer.path = path.cgPath
        if (level == -1){
            //let thisone = 1
            levelLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * 1, height: bounds.height)
        }else{
            levelLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * level, height: bounds.height)
        }
        levelLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    }
}


// global function to be able to change the battery level
func updateBatteryLevel(_ level: CGFloat, for batteryView: Battery) {
    batteryView.level = level
    if level <= 0.1 {
        batteryView.color = .systemRed
    } else {
        batteryView.color = .systemGreen
    }
}



// call function like this updateBatteryLevel(0.8, for: batteryView)

