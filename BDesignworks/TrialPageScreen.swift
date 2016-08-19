//
//  TrialPage.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 04/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

final class TrialPageScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Welcome"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func learnMoreAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func startTrialAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
