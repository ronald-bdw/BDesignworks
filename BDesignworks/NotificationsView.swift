//
//  NotificationsView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 07/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol NotificationsViewDelegate: class {
    func viewWillDismiss()
}

class NotificationsView: UIViewController {
    
    weak var delegate: NotificationsViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accessibilityLabel = "Notifications modal screen"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.delegate?.viewWillDismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingsAction(_ sender: AnyObject) {
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.shared.openURL(url)
        self.delegate?.viewWillDismiss()
        self.dismiss(animated: true, completion: nil)
    }
}
