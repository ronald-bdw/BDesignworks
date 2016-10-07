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
    
    func startWithParameters(_ user: ENUser) {
        let settings = SKTSettings(appToken: smoochToken)
        settings?.userId = "\(user.id)"
        
        settings?.conversationAccentColor = UIColor(fs_hexString: "74A025")
        Smooch.initWith(settings)
        self.login("\(user.id)")
        
        self.updateUserInfo(user: user)
    }
    
    func login(_ userID: String) {
        Smooch.login(userID, jwt: nil)
    }
    
    func updateUserInfo(user: ENUser) {
        SKTUser.current().firstName = user.firstName
        SKTUser.current().lastName = "\(user.id)"
        SKTUser.current().email = user.email
    }
    
    func updateSignUpDate() {
        SKTUser.current().signedUpAt = Date()
    }
}
