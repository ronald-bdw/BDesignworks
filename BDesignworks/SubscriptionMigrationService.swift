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
    
    var shouldShowSubscriptionWillExpireAlertIfNeeded: Bool {
        if let user = ENUser.getMainUser(), user.id != 0,
            (user.provider != "" && InAppManager.shared.isSubscriptionAvailable == false
                && user.shouldShowFirstPopup == true && user.firstPopupText != ""
                && UserDefaults.standard.bool(forKey: FSUserDefaultsKey.IsFirstPopupWasShown) == false) {
            return true
        } else {
            return false
        }
    }
    
    func showSubscriptionEndedAlertIfNeeded() {
        guard let user = ENUser.getMainUser(), user.id != 0,
            (InAppManager.shared.isSubscriptionAvailable == false
                && (user.isSubscriber == false && user.shouldShowSecondPopup || user.isSubscriber == true)) else {return}
        
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
