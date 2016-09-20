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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func learnMoreAction(_ sender: AnyObject) {
        ShowTrialPageViewController()
    }
    
    @IBAction func startTrialAction(_ sender: AnyObject) {
        ShowRegistrationViewController()
    }
}
