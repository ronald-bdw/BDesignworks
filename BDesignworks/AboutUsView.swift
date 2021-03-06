//
//  AboutScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class AboutUsView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsManager.shared.trackScreen(named: "About us screen", viewController: self)
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        self.moveToMainControllerTransitioned()
    }
    
    @IBAction func linkPressed(sender: AnyObject) {
        let urlString = "http://pairup.im"
        
        guard let url = URL(string: urlString) else {return}
        
        UIApplication.shared.openURL(url)
    }
}
