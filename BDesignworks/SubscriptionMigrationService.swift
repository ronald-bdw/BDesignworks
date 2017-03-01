//
//  SubscriptionMigrationService.swift
//  BDesignworks
//
//  Created by Ellina Kuznecova on 17.02.17.
//  Copyright © 2017 Flatstack. All rights reserved.
//

import Foundation

class SubscriptionMigrationService {
    
    static let shared = SubscriptionMigrationService()
    
    func showSubscriptionWillExpireAlertIfNeeded() {
        guard let user = ENUser.getMainUser(), user.id != 0,
            (user.provider != "" && InAppManager.shared.isSubscriptionAvailable == false
                && user.shouldShowFirstPopup == true && user.firstPopupText != ""
            && UserDefaults.standard.bool(forKey: FSUserDefaultsKey.IsFirstPopupWasShown) == false) else {return}
        
        let alert = UIAlertController(title: nil, message: user.firstPopupText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.IsFirstPopupWasShown)
            UserDefaults.standard.synchronize()
            
            ShowInAppAlert()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (alertAction) in
            UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.IsFirstPopupWasShown)
            UserDefaults.standard.synchronize()
            
            alert?.dismiss(animated: true, completion: nil)
        }))
        alert.presentIfNoAlertsPresented()
    }
    
    func showSubscriptionEndedAlertIfNeeded() {
        guard let user = ENUser.getMainUser(), user.id != 0,
            (InAppManager.shared.isSubscriptionAvailable == false
                && ((user.provider != "" && user.shouldShowSecondPopup && user.secondPopupText != "")
                    || user.provider == "")) else {return}
        
        let textToShow = user.secondPopupText != "" ? user.secondPopupText : SecondPopupTextReplacement
        
        let alert = UIAlertController(title: nil, message: textToShow, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
            ShowInAppAlert()
        }))
        alert.addAction(UIAlertAction(title: "Restore subscription", style: .default, handler: { (action) in
            InAppManager.shared.restoreSubscription()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (alertAction) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        alert.presentIfNoAlertsPresented()
    }
}
