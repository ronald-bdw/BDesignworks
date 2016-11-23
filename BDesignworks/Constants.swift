//
//  Constants.swift
//  BDesignworks
//
//  Created by Kruperfone on 02.10.14.
//  Copyright (c) 2014 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift

var Logger: XCGLogger {return XCGLogger.default}
var BDRealm: Realm? {return try? Realm()}

/*--------------Keychain keys-------------*/
enum FSKeychainKey {
    
    static let AccountName     = "com.pearup"
    static let APIToken        = "KeychainAPIToken"
    static let FitbitToken     = "KeychainFitbitToken"
    static let UserEmail       = "KeychainUserEmail"
}

/*--------------User Defaults keys-------------*/
enum FSUserDefaultsKey {
    
    static let HealthKitRegistered  = "HealthKitRegistered"
    static let FitbitRegistered     = "FitbitRegistered"
    static let FitbitTokenId        = "FitbitTokenId"
    static let LoggedInUsers        = "LoggedInUsers"
    static let IsProviderChosen     = "IsProviderChosen"
    static let SmsCode              = "Smscode"
}

/*----------Notifications---------*/
enum FSNotificationKey {
    
    enum FitnessDataIntegration {
        static let HealthKit = "HealthKit"
        static let FitbitResponse = "FitbitResponse"
    }
    
    enum User {
        static let userChanged = "UserChanged"
    }
    enum Example {
        fileprivate static let Prefix = "Example"
        
        static let Key = GenerateKey(Prefix, key: "Key")
    }
}

/*----------Colors----------*/
enum AppColors
{
    static let MainColor = UIColor(fs_hexString: "224d71")
    static let GoldColor = UIColor(fs_hexString: "ebc44b")
}

/*----------Helpers----------*/
private func GenerateKey (_ prefix: String, key: String) -> String {
    return "__\(prefix)-\(key)__"
}

/*----------Storyboards----------*/

enum Storyboard {
    case main
    case login
    case trialPage
    case welcome
    case tourApp
    case profile
    
    var name: String {
        switch self {
        case .main      : return "Main"
        case .login     : return "Login"
        case .trialPage : return "TrialPage"
        case .welcome   : return "WelcomeScreen"
        case .tourApp   : return "TourApp"
        case .profile   : return "Profile"
        }
    }
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: self.name, bundle: nil)
    }
    
    var firstController: UIViewController? {
        return self.storyboard.instantiateInitialViewController()
    }
}

enum Image {
    enum Icon {
        static var Menu = UIImage(named: "menuIcon")!
    }
}

enum Fonts {
    enum OpenSans {
        case bold
        case regular
        
        var fontName: String {
            switch self {
            case .regular   : return "OpenSans"
            case .bold      : return "OpenSans-Bold"
            }
        }
        
        func getFontOfSize(_ size: CGFloat) -> UIFont {
            return UIFont(name: self.fontName, size: size)!
        }
    }
}
