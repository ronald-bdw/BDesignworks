//
//  HealthAppView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 27/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class HealthAppView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accessibilityLabel = "Health app modal screen"
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
