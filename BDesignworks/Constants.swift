//
//  Constants.swift
//  BDesignworks
//
//  Created by Kruperfone on 02.10.14.
//  Copyright (c) 2014 Flatstack. All rights reserved.
//

import UIKit
import FSHelpers_Swift

var Logger: XCGLogger {return XCGLogger.defaultInstance()}

/*--------------Keychain keys-------------*/
enum FSKeychainKey {
    
    static let AccountName     = "com.pearup"
    static let APIToken        = "KeychainAPIToken"
    static let FitbitToken     = "KeychainFitbitToken"
    static let UserEmail       = "KeychainUserEmail"
}

/*--------------User Defaults keys-------------*/
enum FSUserDefaultsKey {
    
    enum DeviceToken {
        private static let Prefix = "FSDeviceToken"
        
        static let Data    = GenerateKey(Prefix, key: "Data")
        static let String  = GenerateKey(Prefix, key: "String")
    }
}

/*----------Notifications---------*/
enum FSNotificationKey {
    
    enum Example {
        private static let Prefix = "Example"
        
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
private func GenerateKey (prefix: String, key: String) -> String {
    return "__\(prefix)-\(key)__"
}

/*----------Storyboards----------*/

enum Storyboard {
    case Main
    case Login
    case TrialPage
    case Welcome
    
    var name: String {
        switch self {
        case .Main      : return "Main"
        case .Login     : return "Login"
        case .TrialPage : return "TrialPage"
        case .Welcome   : return "WelcomeScreen"
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
    
    enum Logo {
        static var HbfLogoWhite = UIImage(named: "hbf-logo-white")!
    }
}

enum Fonts {
    enum OpenSans {
        case Bold
        
        var fontName: String {
            return "OpenSans-Bold"
        }
        
        func getFontOfSize(size: CGFloat) -> UIFont {
            return UIFont(name: self.fontName, size: size)!
        }
    }
}
