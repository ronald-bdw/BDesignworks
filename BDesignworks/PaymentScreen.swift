//
//  PaymentScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 04/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

final class PaymentScreen: UITableViewController, ToggleButtonDelegate {
    
    @IBOutlet var firstToggle: ToggleButton!
    @IBOutlet var secondToggle: ToggleButton!
    @IBOutlet var thirdToggle: ToggleButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Payment information"
        
        self.firstToggle.toggleTag = 1
        self.firstToggle.setToggled(true)
        self.firstToggle.delegate = self
        self.secondToggle.toggleTag = 2
        self.secondToggle.delegate = self
        self.thirdToggle.toggleTag = 3
        self.thirdToggle.delegate = self
    }
    
    func toggleButtonWasPressed(_ on: Bool, buttonTag: Int)
    {
        self.firstToggle.setToggled(false)
        self.secondToggle.setToggled(false)
        self.thirdToggle.setToggled(false)
        
        switch buttonTag
        {
        case 1:
            self.firstToggle.setToggled(true)
        case 2:
            self.secondToggle.setToggled(true)
        case 3:
            self.thirdToggle.setToggled(true)
        default:
            return
        }
    }
}
