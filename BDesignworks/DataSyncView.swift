//
//  DataSyncView.swift
//  BDesignworks
//
//  Created by Ellina Kuznecova on 26.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class DataSyncView: UITableViewController {
    @IBOutlet weak var healthKitSwitch: UISwitch!
    @IBOutlet weak var fitbitSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if HealthKitManager.sharedInstance.isAuthorized {
            self.healthKitSwitch.setOn(true, animated: true)
        }
        
        self.healthKitSwitch.addTarget(self, action: #selector(self.healthKitSwitchStateChanged(sender:)), for: .valueChanged)
    }
    
    func healthKitSwitchStateChanged(sender: AnyObject) {
        if self.healthKitSwitch.isOn {
            HealthKitManager.sharedInstance.authorize()
        }
        else {
            HealthKitManager.sharedInstance.stopSendingData()
        }
    }
}
