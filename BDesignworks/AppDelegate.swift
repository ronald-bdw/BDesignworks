//
//  AppDelegate.swift
//  BDesignworks
//
//  Created by Kruperfone on 02.10.14.
//  Copyright (c) 2014 Flatstack. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        self.setupProject()
        
        do {
            let realm = try Realm()
            if let authInfo = realm.objects(AuthInfo).first {
                if authInfo.isRegistered {
                    ShowWelcomeViewController()
                }
                else {
                    ShowRegistrationViewController()
                }
            }
            else if let _ = realm.objects(User).first {
                ShowConversationViewController()
            }
        } catch let error {
            Logger.error("\(error)")
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    //MARK: - Remote Notifications
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        UIFont.systemFontOfSize(1, weight: 1)
        for i in 0 ..< deviceToken.length {
            let formatString = "%02.2hhx"
            tokenString += String(format: formatString, arguments: [tokenChars[i]])
        }
        
        NSUserDefaults.standardUserDefaults().setObject(deviceToken, forKey: FSUserDefaultsKey.DeviceToken.Data)
        NSUserDefaults.standardUserDefaults().setObject(tokenString, forKey: FSUserDefaultsKey.DeviceToken.String)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func requestForRemoteNotifications () {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
}

extension AppDelegate {
    
    func setupProject() {
        
        self.printProjectSettings()
        
        self.setupProjectForTests()
        
        self.setupLogger()
        
        //setup Crashlytics
        Fabric.with([Crashlytics.self])
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {  countryCodes }
        
        self.setupAppearance()
    }
    
    func setupAppearance() {
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
        let navigationBar = UINavigationBar.appearance()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.barTintColor = AppColors.MainColor
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.translucent = false
    }
    
    func setupProjectForTests() {
        #if TEST
            switch TestingMode() {
            case .Unit:
                print("Unit Tests")
                self.window?.rootViewController = UIViewController()
                return
                
            case .UI:
                print("UI Tests")
            }
        #endif
    }
    
    func printProjectSettings() {
        #if DEBUG
            // print documents directory and device ID
            print("\n*******************************************\nDOCUMENTS:\n\(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0])\n*******************************************\n")
            print("\n*******************************************\nDEVICE ID:\n\((UIDevice.currentDevice().identifierForVendor?.UUIDString)!)\n*******************************************\n")
            print("\n*******************************************\nBUNDLE ID:\n\((NSBundle.mainBundle().bundleIdentifier)!)\n*******************************************\n")
        #endif
    }
    
    func setupLogger() {
        Logger.setup(.Debug, showLogIdentifier: false, showFunctionName: false, showThreadName: true, showLogLevel: false, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLogLevel: .None)
        
        Logger.dateFormatter?.dateFormat = "HH:mm:ss.SSS"
        Logger.xcodeColorsEnabled = true
        
        print()
    }
    
//    func setupMagicalRecord() {
//        MagicalRecord.setShouldDeleteStoreOnModelMismatch(true)
//        MagicalRecord.setupAutoMigratingCoreDataStack()
//        MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.Off)
//    }
    
//    func setupSDWebImage() {
//        let imageCache:SDImageCache = SDImageCache.sharedImageCache()
//        imageCache.maxCacheSize     = 1024*1024*100 // 100mb on disk
//        imageCache.maxMemoryCost    = 1024*1024*10  // 10mb in memory
//        
//        let imageDownloader:SDWebImageDownloader = SDWebImageDownloader.sharedDownloader()
//        imageDownloader.downloadTimeout          = 60.0
//    }
}

