//
//  SelectProvider.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 03/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift

final class SelectProviderScreen: UIViewController, RollUpButtonDelegate, AutocompleteViewDelegate {
    
    struct Constants {
        static let defaultLogoTopConstraintRatio: CGFloat = 0.2 // Show how less logo's top offset relative to screen size
    }
    
    @IBOutlet var providerSelectionButton: RollUpButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    
    private var autocompleteView: AutocompleteView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoTopConstraint.constant = self.getDefaultLogoTopOffset()
        self.autocompleteView = AutocompleteView()
        self.autocompleteView.layer.cornerRadius = 5
        self.autocompleteView.delegate = self
        self.autocompleteView.items = ["HBF", "I do not have a provider"]
        self.view.addSubview(self.autocompleteView)
        
        self.providerSelectionButton.delegate = self
        self.providerSelectionButton.label.text = self.autocompleteView.items[0]
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
    
    func initialAnimation() {
        self.providerSelectionButton.alpha = 0
        self.nextButton.alpha = 0
        
        UIView.animateWithDuration(0.5) {
            self.providerSelectionButton.alpha = 1
            self.nextButton.alpha = 1
        }
    }
    
    //MARK: Actions
    
    @IBAction func nextButtonPressed(sender: AnyObject)
    {
        if self.providerSelectionButton.label.text != "Tap to chose" {
            self.performSegueWithIdentifier("toVerifyScreen", sender: nil)
        }
    }
    
//    @IBAction func notListedButtonPressed(sender: AnyObject)
//    {
//        Smooch.show()
//        //self.performSegueWithIdentifier("toTrialPage", sender: nil)
//    }

    
    //MARK: Delegates
    func rollUpButtonDidChangeState(active: Bool)
    {
        if active {
            self.autocompleteView.present()
            return
        }
        
        self.autocompleteView.dismiss()
    }
    
    func autocompleteViewRowSelected(row: Int, item: String)
    {
        self.providerSelectionButton.label.text = item
        self.providerSelectionButton.active = false
    }
}
