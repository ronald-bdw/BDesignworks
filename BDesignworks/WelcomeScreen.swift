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

    @IBOutlet weak var conversationLabel: UILabel!
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var conversationTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    private lazy var modalPresentationController: ModalPresentationController = {
        return ModalPresentationController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        self.navigationItem.hidesBackButton = true
        self.containerTopConstraint.constant += 216
        self.containerView.alpha = 0.0
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animateWithDuration(0.7) {
            self.conversationTopConstraint.constant += 216
            self.containerTopConstraint.constant    -= 216
            self.conversationLabel.alpha             = 0.0
            self.containerView.alpha                 = 1.0
            self.view.layoutIfNeeded()
        }
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
        return ModalPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

