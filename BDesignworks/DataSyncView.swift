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
        
        if UserDefaults.standard.bool(forKey: FSUserDefaultsKey.FitbitRegistered) {
            self.fitbitSwitch.setOn(true, animated: true)
        }
        
        self.healthKitSwitch.addTarget(self, action: #selector(self.healthKitSwitchStateChanged(sender:)), for: .valueChanged)
        self.fitbitSwitch.addTarget(self, action: #selector(self.fitbitSwitchStateChanged(sender:)), for: .valueChanged)
    }
    
    func healthKitSwitchStateChanged(sender: AnyObject) {
        if self.healthKitSwitch.isOn {
            HealthKitManager.sharedInstance.authorize()
        }
        else {
            HealthKitManager.sharedInstance.stopSendingData()
        }
    }
    
    func fitbitSwitchStateChanged(sender: AnyObject) {
        if self.fitbitSwitch.isOn {
            
            let urlString = "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=227ZMJ&scope=activity"
            
            guard let url = URL(string: urlString) else {return}
            
            UIApplication.shared.openURL(url)
        }
        else {
            UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.FitbitRegistered)
            UserDefaults.standard.synchronize()
        }
    }
}
