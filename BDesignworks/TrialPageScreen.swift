//
//  TrialPage.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 04/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

protocol TrialModalViewDelegate: class {
    func learnMoreSelected()
    func startTrialSelected()
}

final class TrialPageScreen: UIViewController {
    
    weak var delegate: TrialModalViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Welcome"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func learnMoreAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.learnMoreSelected()
    }
    
    @IBAction func startTrialAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.startTrialSelected()
    }
}
