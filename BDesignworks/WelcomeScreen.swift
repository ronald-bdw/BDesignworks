//
//  VerifyScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 04/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift

private extension FSScreenType {
    
    var defaultContainerHeight: CGFloat {
        switch self {
        case ._3_5 : return 200
        case ._4   : return 216
        case ._4_7 : return 300
        case ._5_5 : return 340
        }
    }
}

final class WelcomeScreen: UIViewController {
    
    struct SegueIdentifiers {
        static let Trial           = "showTrialScreen"
        static let SelectProvider  = "showProviderSelection"
    }

    struct Constants {
        static let defaultLogoHeight: CGFloat             = 228 // Height of logo on splash screen
        static let defaultVerticalCenterOffset: CGFloat   = 10  // Vertical offset of logo on splash screen
        static let defaultLogoTopConstraintRatio: CGFloat = 0.2 // Show how less logo's top offset relative to screen size
    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var conversationLabel: UILabel!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var conversationTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.navigationController?.navigationBar.hidden = true
        self.navigationItem.hidesBackButton = true
        self.containerHeightConstraint.constant = self.getDefaultContainerHeight()
        self.logoTopConstraint.constant = (FSScreenBounds.size.height - Constants.defaultLogoHeight)/2 - Constants.defaultVerticalCenterOffset
        self.containerBottomConstraint.constant = -self.containerView.fs_height
        self.containerView.alpha = 0.0
        self.view.layoutIfNeeded()
    }
    
    private func getDefaultContainerHeight() -> CGFloat {
        guard let screenType = FSScreenType() else { return 200 }
        return screenType.defaultContainerHeight
    }
    
    private func getDefaultLogoTopOffset() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height == 480 ? 50 : FSScreenBounds.size.height*Constants.defaultLogoTopConstraintRatio  //Checking for iPhone 4/4s
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animateWithDuration(0.8, delay: 0.4, options: .CurveEaseInOut, animations: {
            [weak self] in
            guard let sself = self else { return }
            sself.logoTopConstraint.constant          = sself.getDefaultLogoTopOffset()
            sself.conversationTopConstraint.constant += FSScreenBounds.size.height/2
            sself.containerBottomConstraint.constant  = 0
            sself.conversationLabel.alpha             = 0.0
            sself.containerView.alpha                 = 1.0
            sself.view.layoutIfNeeded()
        }, completion: nil)
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
    
    func presentationControllerForPresentedViewController(presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                          sourceViewController source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

