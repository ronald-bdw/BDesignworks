//
//  ViewControllersPresentation.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 25.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

func PresentViewController(_ controller: UIViewController, animated: Bool = true) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let window = appDelegate.window
        else {return}
    
    if let rootViewController = window.rootViewController {
        
        UIView.transition(from: rootViewController.view,
                                  to: controller.view,
                                  duration: animated ? 0.4 : 0.0,
                                  options: UIViewAnimationOptions.transitionFlipFromRight) { (success) -> Void in
                                    window.rootViewController = controller
        }
    } else {
        window.rootViewController = controller
    }
}

func ShowInitialViewController(_ animated: Bool = true) {
    
    let navigationController = Storyboard.login.storyboard.instantiateViewController(withIdentifier: "WelcomeController")
    
    PresentViewController(navigationController, animated: animated)
}


func ShowRegistrationViewController(_ animated: Bool = true) {
    
    let navigationController = Storyboard.trialPage.storyboard.instantiateViewController(withIdentifier: "RegistrationNavigationView")
    
    PresentViewController(navigationController, animated: animated)
}

func ShowConversationViewController(_ animated: Bool = true) {
    guard let navigationController = Storyboard.main.firstController else {return}
    
    PresentViewController(navigationController, animated: animated)
}

func ShowWelcomeViewController(_ animated: Bool = true) {
    guard let navigationController = Storyboard.welcome.firstController else {return}
    
    PresentViewController(navigationController, animated: animated)
}

func ShowTrialPageViewController(_ animated: Bool = true) {
    guard let navigationController = Storyboard.trialPage.firstController else {return}
    
    PresentViewController(navigationController, animated: animated)
}

func ShowTourAppViewController(_ animated: Bool = true) {
    guard let navigationController = Storyboard.tourApp.firstController else {return}
    
    PresentViewController(navigationController, animated: animated)
}

func ShowVerificationViewController(_ animated: Bool = true) {
    let navigationController = Storyboard.login.storyboard.instantiateViewController(withIdentifier: "VerificationNavigationController")
    
    PresentViewController(navigationController, animated: animated)
}

