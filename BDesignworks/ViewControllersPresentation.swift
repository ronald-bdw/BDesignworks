//
//  ViewControllersPresentation.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 25.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

func PresentViewController(controller: UIViewController, animated: Bool = true) {
    guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
        let window = appDelegate.window
        else {return}
    
    if let rootViewController = window.rootViewController {
        
        UIView.transitionFromView(rootViewController.view,
                                  toView: controller.view,
                                  duration: animated ? 0.4 : 0.0,
                                  options: UIViewAnimationOptions.TransitionFlipFromRight) { (success) -> Void in
                                    window.rootViewController = controller
        }
    } else {
        window.rootViewController = controller
    }
}

func ShowInitialViewController(animated: Bool = true) {
    
    let navigationController = Storyboard.Login.storyboard.instantiateViewControllerWithIdentifier("WelcomeController")
    
    PresentViewController(navigationController, animated: animated)
}


func ShowRegistrationViewController(animated: Bool = true) {
    
    let navigationController = Storyboard.TrialPage.storyboard.instantiateViewControllerWithIdentifier("RegistrationNavigationView")
    
    PresentViewController(navigationController, animated: animated)
}

func ShowConversationViewController(animated: Bool = true) {
    guard let navigationController = Storyboard.Main.firstController else {return}
    
    PresentViewController(navigationController, animated: animated)
}

func ShowWelcomeViewController(animated: Bool = true) {
    guard let navigationController = Storyboard.Welcome.firstController else {return}
    
    PresentViewController(navigationController, animated: animated)
}

func ShowTrialPageViewController(animated: Bool = true) {
    guard let navigationController = Storyboard.TrialPage.firstController else {return}
    
    PresentViewController(navigationController, animated: animated)
}