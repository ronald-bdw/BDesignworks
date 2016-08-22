//
//  CustomNavigationController.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 11/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

final class CustomNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.enabled = false
        self.navigationBar.titleTextAttributes        = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.barTintColor               = AppColors.MainColor
        self.navigationBar.tintColor                  = UIColor.whiteColor()
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
    
    override func showViewController(vc: UIViewController, sender: AnyObject?) {
        super.showViewController(vc, sender: sender)
        self.updateUI(withViewController: vc)
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        
        let viewController = super.popViewControllerAnimated(animated)
        if let topVC = self.topViewController {
            self.updateUI(withViewController: topVC)
        }
        return viewController
    }
    
    private func updateUI(withViewController vc: UIViewController) {
        switch vc {
        case is WelcomeScreen,
             is SelectProviderScreen:
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
            self.setNavigationBarHidden(true, animated: true)
        default:
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
            self.setNavigationBarHidden(false, animated: true)
        }
    }
}
