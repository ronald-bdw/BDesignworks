//
//  SmoochHelper.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 15/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class SmoochHelper
{
    static let sharedInstance = SmoochHelper()
    let smoochToken = "833kwj0z5wkvt82tpgfbbqn3z"
    
    //Custom properties for user
    //SKTUser.currentUser().addProperties([ "nickname" : "Lil Big Daddy Slim", "weight" : 650, "premiumUser" : true ])
    
    func startWithParameters(userID: String)
    {
        let settings = SKTSettings(appToken: smoochToken)
        settings.userId = userID
        Smooch.initWithSettings(settings)
    }
    
    func login(userID: String)
    {
        Smooch.login(userID, jwt: nil)
    }
    
    func updateUserInfo(name: String, lastName: String, email: String)
    {
        SKTUser.currentUser().firstName = name
        SKTUser.currentUser().lastName = lastName
        SKTUser.currentUser().email = email
    }
    
    func updateSignUpDate()
    {
        SKTUser.currentUser().signedUpAt = NSDate()
    }
}