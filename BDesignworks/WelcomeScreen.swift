//
//  VerifyScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 04/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

final class WelcomeScreen: UIViewController {
    
    struct SegueIdentifiers {
        static let Trial           = "showTrialScreen"
        static let SelectProvider  = "showProviderSelection"
    }
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var invitationLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.welcomeLabel.font = UIFont.systemFontOfSize(16.0)
        self.welcomeLabel.text = "your get active coach with you every step of the way"
        self.noButton.hidden = true
        self.yesButton.hidden = true
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let lIdentifier = segue.identifier else {
            super.prepareForSegue(segue, sender: sender)
            return
        }
        switch lIdentifier {
        case SegueIdentifiers.Trial:
            segue.destinationViewController.transitioningDelegate = self
            segue.destinationViewController.modalPresentationStyle = .Custom
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    @IBAction func yesAction(sender: AnyObject) {
        self.performSegueWithIdentifier(SegueIdentifiers.SelectProvider, sender: nil)
    }
    
    @IBAction func noAction(sender: AnyObject) {
        self.performSegueWithIdentifier(SegueIdentifiers.Trial, sender: nil)
    }
}

extension WelcomeScreen: UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presenting, presentingViewController: source)
    }
}

