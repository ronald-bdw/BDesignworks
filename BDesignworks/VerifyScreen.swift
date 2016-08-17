//
//  VerifyScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 04/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class VerifyScreen: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    @IBAction func nextPressed(sender: UIButton)
    {
        performSegueWithIdentifier("toWelcomeScreen", sender: nil)
    }
    
    @IBAction func backPressed(sender: AnyObject)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
