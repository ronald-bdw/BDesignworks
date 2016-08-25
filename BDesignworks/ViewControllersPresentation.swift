//
//  ViewControllersPresentation.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 25.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation


func ShowInitialViewController(animated: Bool = true) {
    
    guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
        let window = appDelegate.window,
        let navigationController = Storyboard.Main.firstController
        else {return}
    
    if let rootViewController = window.rootViewController {
        
        UIView.transitionFromView(rootViewController.view,
                                  toView: navigationController.view,
                                  duration: animated ? 0.4 : 0.0,
                                  options: UIViewAnimationOptions.TransitionFlipFromRight) { (success) -> Void in
                                    window.rootViewController = navigationController
        }
    } else {
        window.rootViewController = navigationController
    }
}


func ShowRegistrationViewController(animated: Bool = true) {
    
    guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
        let window = appDelegate.window,
        let navigationController = Storyboard.TrialPage.firstController
        else {return}
    
    if let rootViewController = window.rootViewController {
        
        UIView.transitionFromView(rootViewController.view,
                                  toView: navigationController.view,
                                  duration: animated ? 0.4 : 0.0,
                                  options: UIViewAnimationOptions.TransitionFlipFromRight) { (success) -> Void in
                                    window.rootViewController = navigationController
        }
    } else {
        window.rootViewController = navigationController
    }
}

func ShowConversationViewController(animated: Bool = true) {
    guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
        let window = appDelegate.window
        else {return}
    
    let navigationController = Storyboard.Main.storyboard.instantiateViewControllerWithIdentifier("ConversationScreen")
    
    if let rootViewController = window.rootViewController {
        
        UIView.transitionFromView(rootViewController.view,
                                  toView: navigationController.view,
                                  duration: animated ? 0.4 : 0.0,
                                  options: UIViewAnimationOptions.TransitionFlipFromRight) { (success) -> Void in
                                    window.rootViewController = navigationController
        }
    } else {
        window.rootViewController = navigationController
    }
}

func ShowWelcomeViewController(animated: Bool = true) {
    guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
        let window = appDelegate.window,
        let navigationController = Storyboard.Welcome.firstController
        else {return}
    
    if let rootViewController = window.rootViewController {
        
        UIView.transitionFromView(rootViewController.view,
                                  toView: navigationController.view,
                                  duration: animated ? 0.4 : 0.0,
                                  options: UIViewAnimationOptions.TransitionFlipFromRight) { (success) -> Void in
                                    window.rootViewController = navigationController
        }
    } else {
        window.rootViewController = navigationController
    }
}