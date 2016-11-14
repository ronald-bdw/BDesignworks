//
//  LogoutView.swift
//  BDesignworks
//
//  Created by Ellina Kuznecova on 26.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class LogoutView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: AnyObject) {
        ENUser.logout()
        self.dismiss(animated: true, completion: nil)
        
        FSDispatch_after_short(0.5) {
            let controller = Storyboard.login.storyboard.instantiateViewController(withIdentifier: "WelcomeController")
            UIApplication.shared.delegate?.window??.rootViewController = controller
        }
    }
}
