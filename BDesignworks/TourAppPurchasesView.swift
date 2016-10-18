//
//  TourAppPurchases.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class TourAppPurchasesView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InAppManager.shared.delegate = self
    }
    
    @IBAction func restorePressed(sender: AnyObject) {
        InAppManager.shared.restoreSubscription()
    }
    
    @IBAction func nextPressed(sender: AnyObject) {
        ShowConversationViewController()
    }
}

extension TourAppPurchasesView: InAppManagerDelegate {
    
    func inAppLoadingStarted() {
        SVProgressHUD.show()
    }
    
    func inAppLoadingSucceded(productType: ProductType) {
        SVProgressHUD.dismiss()
    }
    
    func inAppLoadingFailed(error: Swift.Error?) {
        SVProgressHUD.dismiss()
        ShowErrorAlert()
        Logger.debug(error)
    }
}
