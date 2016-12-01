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
        static let TrialModal               = "showTrialModalView"
        static let SelectProvider           = "showProviderSelection"
        static let Verification             = "showVerification"
        static let TrialPage                = "showTrialPage"
        static let VerificationWithAccount  = "showVerificationWithAccount"
    }

    struct Constants {
        static let defaultLogoHorizontalOffset: CGFloat   = 70
        static let defaultVerticalCenterOffset: CGFloat   = 10  // Vertical offset of logo on splash screen
        static let defaultLogoTopConstraintRatio: CGFloat = 0.2 // Show how less logo's top offset relative to screen size
    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var containerView                    : UIView!
    @IBOutlet weak var logoView                         : UIImageView!
    @IBOutlet weak var previousScreenTextTopConstraint  : NSLayoutConstraint!
    @IBOutlet weak var containerBottomConstraint        : NSLayoutConstraint!
    @IBOutlet weak var containerHeightConstraint        : NSLayoutConstraint!
    @IBOutlet weak var containerTopConstraint           : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        self.view.layoutIfNeeded()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        self.containerView.alpha = 0.0
        
        let screenWidth = UIScreen.main.bounds.width
        let logoHeight = screenWidth - 2 * Constants.defaultLogoHorizontalOffset
        
        self.containerBottomConstraint.constant = UIScreen.main.bounds.height/2 + 50 -
            self.containerHeightConstraint.constant - self.containerTopConstraint.constant - logoHeight/2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1, delay: 0.5, options: [], animations: {
            [weak self] in
            guard let sself = self else { return }
            sself.containerView.alpha = 1.0
            sself.containerBottomConstraint.constant = 0
            sself.previousScreenTextTopConstraint.constant += sself.view.fs_height
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
        case SegueIdentifiers.VerificationWithAccount:
            (segue.destination as? VerificationView)?.shouldCheckForRegistration = true
            (segue.destination as? VerificationView)?.shouldCheckForProvider = true
        case SegueIdentifiers.Verification:
            (segue.destination as? VerificationView)?.shouldCheckForRegistration = false
            (segue.destination as? VerificationView)?.shouldCheckForProvider = false
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
    
    @IBAction func accountExistTapped(_sender: AnyObject) {
        self.performSegue(withIdentifier: SegueIdentifiers.VerificationWithAccount, sender: nil)
    }
}

extension WelcomeScreen: TrialModalViewDelegate {
    func learnMoreSelected() {
        FSDispatch_after_short(0.3, block: {[weak self] in
            self?.performSegue(withIdentifier: SegueIdentifiers.TrialPage, sender: nil)
        })
    }
    
    func startTrialSelected() {
        FSDispatch_after_short(0.3, block: {[weak self] in
            self?.performSegue(withIdentifier: SegueIdentifiers.Verification, sender: nil)
        })
    }
}

extension WelcomeScreen: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                                          presenting: UIViewController?,
                                                          source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

