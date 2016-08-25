//
//  SelectProvider.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 03/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift

enum ProviderOption: String {
    case HBF         = "HBF"
    case NoProvider  = "I do not have a provider"
}

final class SelectProviderScreen: UIViewController, RollUpButtonDelegate, AutocompleteViewDelegate {
    
    struct Constants {
        static let defaultLogoTopConstraintRatio: CGFloat = 0.2 // Show how less logo's top offset relative to screen size
    }
    
    struct SegueIdentifiers {
        static let ShowVerify = "VerificationSegue"
        static let ShowTrial = "TrialSegue"
    }
    
    @IBOutlet var providerSelectionButton: RollUpButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    
    private lazy var autocompleteView: AutocompleteView = {
        let autocompleteView = AutocompleteView()
        autocompleteView.items = [.HBF, .NoProvider]
        autocompleteView.delegate = self
        self.view.addSubview(autocompleteView)
        return autocompleteView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoTopConstraint.constant = self.getDefaultLogoTopOffset()
        self.providerSelectionButton.delegate = self
        self.providerSelectionButton.chooseLabel.text = self.autocompleteView.items.first?.rawValue
        self.view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        self.autocompleteView.frame = CGRectMake(self.providerSelectionButton.frame.origin.x,
                                                 self.providerSelectionButton.fs_y + self.providerSelectionButton.fs_height,
                                                 self.providerSelectionButton.frame.size.width,
                                                 self.autocompleteView.fs_height)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.initialAnimation()
    }
    
    private func getDefaultLogoTopOffset() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height == 480 ? 50 : FSScreenBounds.size.height*Constants.defaultLogoTopConstraintRatio  //Checking for iPhone 4/4s
    }
    
    private func initialAnimation() {
        self.providerSelectionButton.alpha = 0
        self.nextButton.alpha = 0
        
        UIView.animateWithDuration(0.5) {[weak self] in
            guard let sself = self else { return }
            sself.providerSelectionButton.alpha = 1
            sself.nextButton.alpha = 1
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let lIdentifier = segue.identifier else {
            super.prepareForSegue(segue, sender: sender)
            return
        }
        switch lIdentifier {
        case SegueIdentifiers.ShowTrial:
            segue.destinationViewController.transitioningDelegate = self
            segue.destinationViewController.modalPresentationStyle = .Custom
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    //MARK: Actions
    @IBAction func nextButtonPressed(sender: AnyObject) {
        guard let labelText = self.providerSelectionButton.chooseLabel.text,
            let selectedButtonState = ProviderOption(rawValue: labelText) else {return}
        
        switch selectedButtonState {
        case .HBF: self.performSegueWithIdentifier(SegueIdentifiers.ShowVerify, sender: nil)
        case .NoProvider: self.performSegueWithIdentifier(SegueIdentifiers.ShowTrial, sender: nil)
        }
    }
    
    //MARK: Delegates
    func rollUpButtonDidChangeState(active: Bool) {
        if active {
            self.autocompleteView.present()
        } else {
            self.autocompleteView.dismiss()
        }
    }
    
    func autocompleteViewRowSelected(row: Int, item: String) {
        self.providerSelectionButton.chooseLabel.text = item
        self.providerSelectionButton.active = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
}

extension SelectProviderScreen: UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                                                   sourceViewController source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}
