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
        static let TrialModal       = "showTrialModalView"
        static let SelectProvider   = "showProviderSelection"
        static let Verification     = "showVerification"
        static let TrialPage        = "showTrialPage"
    }

    struct Constants {
        static let defaultLogoHeight: CGFloat             = 228 // Height of logo on splash screen
        static let defaultVerticalCenterOffset: CGFloat   = 10  // Vertical offset of logo on splash screen
        static let defaultLogoTopConstraintRatio: CGFloat = 0.2 // Show how less logo's top offset relative to screen size
    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
//        self.containerHeightConstraint.constant = self.getDefaultContainerHeight()
//        self.logoTopConstraint.constant = (UIScreen.main.bounds.size.height - Constants.defaultLogoHeight)/2 - Constants.defaultVerticalCenterOffset
//        self.containerBottomConstraint.constant = -self.containerView.fs_height
        self.containerView.alpha = 0.0
        self.view.layoutIfNeeded()
    }
    
//    fileprivate func getDefaultContainerHeight() -> CGFloat {
//        guard let screenType = FSScreenType() else { return 200 }
//        return screenType.defaultContainerHeight
//    }
//    
//    fileprivate func getDefaultLogoTopOffset() -> CGFloat {
//        return UIScreen.main.bounds.size.height == 480 ? 50 : UIScreen.main.bounds.size.height*Constants.defaultLogoTopConstraintRatio  //Checking for iPhone 4/4s
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.8, delay: 0.4, options: UIViewAnimationOptions(), animations: {
            [weak self] in
            guard let sself = self else { return }
//            sself.logoTopConstraint.constant          = sself.getDefaultLogoTopOffset()
//            sself.conversationTopConstraint.constant += UIScreen.main.bounds.size.height/2
//            sself.containerBottomConstraint.constant  = 0
//            sself.conversationLabel.alpha             = 0.0
            sself.containerView.alpha                 = 1.0
            sself.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let lIdentifier = segue.identifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        switch lIdentifier {
        case SegueIdentifiers.TrialModal:
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
            (segue.destination as? TrialPageScreen)?.delegate = self
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @IBAction func yesAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: SegueIdentifiers.SelectProvider, sender: nil)
    }
    
    @IBAction func noAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: SegueIdentifiers.TrialModal, sender: nil)
    }
}

extension WelcomeScreen: TrialModalViewDelegate {
    func learnMoreSelected() {
        self.performSegue(withIdentifier: SegueIdentifiers.TrialPage, sender: nil)
    }
    
    func startTrialSelected() {
        self.performSegue(withIdentifier: SegueIdentifiers.Verification, sender: nil)
    }
}

extension WelcomeScreen: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                                          presenting: UIViewController?,
                                                          source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

