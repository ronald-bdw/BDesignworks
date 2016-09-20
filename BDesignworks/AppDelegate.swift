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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.setupProject()
//        User.createTestUser()
        do {
            let realm = try Realm()
            if let authInfo = realm.objects(AuthInfo.self).first {
                if authInfo.isRegistered {
                    ShowWelcomeViewController()
                }
                else {
                    ShowRegistrationViewController()
                }
            }
            else if let _ = realm.objects(User.self).first {
                ShowConversationViewController()
            }
            else {
                ShowInitialViewController()
            }
        } catch let error {
            ShowInitialViewController()
            Logger.error("\(error)")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        //pearup://pearup.com?authcode=####
        guard let urlFragment = url.fragment,
            let startRange = urlFragment.range(of: "="),
            let endRange = urlFragment.range(of: "&") else {return true}
        let token = urlFragment.substring(with: startRange.upperBound..<endRange.lowerBound)
        Logger.debug(token)
        return true
    }
    
    //MARK: - Remote Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        UIFont.systemFont(ofSize: 1, weight: 1)
        for i in 0 ..< deviceToken.count {
            let formatString = "%02.2hhx"
            tokenString += String(format: formatString, arguments: [tokenChars[i]])
        }
        
        UserDefaults.standard.set(deviceToken, forKey: FSUserDefaultsKey.DeviceToken.Data)
        UserDefaults.standard.set(tokenString, forKey: FSUserDefaultsKey.DeviceToken.String)
        UserDefaults.standard.synchronize()
    }
}

extension AppDelegate {
    
    func setupProject() {
        
        self.printProjectSettings()
        
        self.setupProjectForTests()
        
        self.setupLogger()
        
        //setup Crashlytics
        Fabric.with([Crashlytics.self])
        
        DispatchQueue.global().async {  let _ = countryCodes }
        
        self.setupAppearance()
    }
    
    func setupAppearance() {
        
        let navigationBar = UINavigationBar.appearance()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationBar.barTintColor = AppColors.MainColor
        navigationBar.tintColor = UIColor.white
        navigationBar.isTranslucent = false
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
            print("\n*******************************************\nDOCUMENTS:\n\(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])\n*******************************************\n")
            print("\n*******************************************\nDEVICE ID:\n\((UIDevice.current.identifierForVendor?.uuidString)!)\n*******************************************\n")
            print("\n*******************************************\nBUNDLE ID:\n\((Bundle.main.bundleIdentifier)!)\n*******************************************\n")
        #endif
    }
    
    func setupLogger() {
        Logger.setup(level: .debug, showLogIdentifier: false, showFunctionName: false, showThreadName: true, showLevel: false, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: .none)
        
        Logger.dateFormatter?.dateFormat = "HH:mm:ss.SSS"
        
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

