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
    let smoochToken = "eiw2afikzfabehcj65ilhnp7q"
    
    //Custom properties for user
    //SKTUser.currentUser().addProperties([ "nickname" : "Lil Big Daddy Slim", "weight" : 650, "premiumUser" : true ])
    
    func startWithParameters(_ userID: String)
    {
        let settings = SKTSettings(appToken: smoochToken)
        settings?.userId = userID
        Smooch.initWith(settings)
    }
    
    func login(_ userID: String)
    {
        Smooch.login(userID, jwt: nil)
    }
    
    func updateUserInfo(_ name: String, lastName: String, email: String)
    {
        SKTUser.current().firstName = name
        SKTUser.current().lastName = lastName
        SKTUser.current().email = email
    }
    
    func updateSignUpDate()
    {
        SKTUser.current().signedUpAt = Date()
    }
}
