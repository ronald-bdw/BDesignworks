//
//  CustomNavigationController.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 11/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

final class CustomNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    private var statusBarStyle = UIStatusBarStyle.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationBar.titleTextAttributes        = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.barTintColor               = AppColors.MainColor
        self.navigationBar.tintColor                  = UIColor.white
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.updateUI(withViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard let topVC = self.topViewController else { return }
        self.updateUI(withViewController: topVC)
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        super.show(vc, sender: sender)
        self.updateUI(withViewController: vc)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        let viewController = super.popViewController(animated: animated)
        if let topVC = self.topViewController {
            self.updateUI(withViewController: topVC)
        }
        return viewController
    }
    
    fileprivate func updateUI(withViewController vc: UIViewController) {
        switch vc {
        case is WelcomeScreen,
             is SelectProviderScreen:
            self.statusBarStyle = .default
            self.setNavigationBarHidden(true, animated: true)
        default:
            self.statusBarStyle = .lightContent
            self.setNavigationBarHidden(false, animated: true)
        }
    }
}
