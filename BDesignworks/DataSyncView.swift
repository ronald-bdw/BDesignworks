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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFitBitSwitchState), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
//        let _ = Router.Steps.deleteFitBitToken(tokenId: "243").request().responseObject { (response: DataResponse<RTStepsSendResponse>) in
//            switch response.result {
//            case .success(let response):
//                Logger.debug("successfully remove fitbit code")
//                Logger.debug(response.toJSON())
//                UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.FitbitRegistered)
//                UserDefaults.standard.synchronize()
//            case .failure(let error):
//                Logger.error(error)
//                ShowErrorAlert()
//            }
//        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        }else {
            UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.FitbitRegistered)
            UserDefaults.standard.synchronize()
        }
    }
    
    func updateFitBitSwitchState(){
        if UserDefaults.standard.bool(forKey: FSUserDefaultsKey.FitbitRegistered) == true {
            self.fitbitSwitch.setOn(true, animated: false)
        }else{
            self.fitbitSwitch.setOn(false, animated: false)
        }
    }
}
