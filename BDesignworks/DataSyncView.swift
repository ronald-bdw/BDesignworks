//
//  DataSyncView.swift
//  BDesignworks
//
//  Created by Ellina Kuznecova on 26.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class DataSyncView: UITableViewController {
    @IBOutlet weak var fitbitSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: FSUserDefaultsKey.FitbitRegistered) {
            self.fitbitSwitch.setOn(true, animated: true)
        }
        
        self.fitbitSwitch.addTarget(self, action: #selector(self.fitbitSwitchStateChanged(sender:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFitBitSwitchState), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFitBitSwitchState), name: NSNotification.Name(rawValue: FSNotificationKey.FitnessDataIntegration.FitbitResponse), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func fitbitSwitchStateChanged(sender: AnyObject) {
        if self.fitbitSwitch.isOn {
            let urlString = "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=227ZMJ&scope=activity"
            
            guard let url = URL(string: urlString) else {return}
            
            UIApplication.shared.openURL(url)
        }else {
            FitbitManager.sharedInstance.removeFitBitTokenFromServer()
        }
    }
    
    func updateFitBitSwitchState(){
        if (UserDefaults.standard.object(forKey: FSUserDefaultsKey.FitbitTokenId) != nil) {
            self.fitbitSwitch.setOn(true, animated: false)
        }else{
            self.fitbitSwitch.setOn(false, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let lIdentifier = segue.identifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        switch lIdentifier {
        case SegueIdentifiers.HealthKit:
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension DataSyncView {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.fs_deselectSelectedRow(true)
    }
}

extension DataSyncView {
    enum SegueIdentifiers {
        static let HealthKit = "HealthKit"
    }
}

extension DataSyncView: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting, height: 400)
    }
}
