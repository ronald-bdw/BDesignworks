//
//  SelectProvider.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 03/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class SelectProviderScreen: UIViewController, RollUpButtonDelegate, AutocompleteViewDelegate
{
    @IBOutlet var providerSelectionButton: RollUpButton!
    @IBOutlet weak var nextButton: RoundButton!
    @IBOutlet weak var notListedButton: RoundButton!
    
    private var autocompleteView: AutocompleteView!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let frame = CGRectMake(self.providerSelectionButton.frame.origin.x, self.providerSelectionButton.frame.origin.y - 205, self.providerSelectionButton.frame.size.width, 200)
        self.autocompleteView = AutocompleteView(frame: frame)
        self.autocompleteView.delegate = self
        self.autocompleteView.items = ["Fitbit", "Jawbone"]
        self.view.addSubview(autocompleteView)
        
        self.providerSelectionButton.delegate = self
        self.providerSelectionButton.label.text = self.autocompleteView.items[0]
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.initialAnimation()
    }
    
    func initialAnimation()
    {
        self.providerSelectionButton.alpha = 0
        self.notListedButton.alpha = 0
        self.nextButton.alpha = 0
        
        UIView.animateWithDuration(0.5) {
            self.providerSelectionButton.alpha = 1
            self.notListedButton.alpha = 1
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
    
    @IBAction func notListedButtonPressed(sender: AnyObject)
    {
        Smooch.show()
        //self.performSegueWithIdentifier("toTrialPage", sender: nil)
    }

    
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
