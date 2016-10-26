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
        
//        ENUser.createTestUser()
        
        let realm = try? Realm()
        if let _ = realm?.objects(ENUser.self).first,
            realm?.objects(AuthInfo.self).count == 0 {
            ShowConversationViewController()
        }
        else {
            ShowInitialViewController()
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
        //pearup://pearup.com?code=####
        //pearup://pearup.com?authcode=%{phone_code}" smscode
        
        guard let query = url.query else {return true}
        var code = ""
        if let smsCodeDividerIndex = query.range(of: "authcode=")?.upperBound {
            code = query.substring(from: smsCodeDividerIndex)
            if let realm = try? Realm(),
                let authInfo = realm.objects(AuthInfo.self).first {
                
                UserDefaults.standard.set(code, forKey: FSUserDefaultsKey.SmsCode)
                UserDefaults.standard.synchronize()
                
                if authInfo.isRegistered {
                    ShowWelcomeViewController()
                }
                else {
                    ShowRegistrationViewController()
                }
            }
        }
        else if let fitBitDividerIndex = query.range(of: "code=")?.upperBound {
            code = query.substring(from: fitBitDividerIndex)
            
            let _ = Router.Steps.sendFitbitCode(code: code).request().responseObject { (response: DataResponse<RTStepsSendResponse>) in
                switch response.result {
                case .success(_):
                    Logger.debug("successfully sent fitbit code")
                    UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.FitbitRegistered)
                    UserDefaults.standard.synchronize()
                case .failure(let error):
                    Logger.error(error)
                    ShowErrorAlert()
                }
            }
        }
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
        Logger.debug(tokenString)
//        UserDefaults.standard.set(deviceToken, forKey: FSUserDefaultsKey.DeviceToken.Data)
//        UserDefaults.standard.set(tokenString, forKey: FSUserDefaultsKey.DeviceToken.String)
//        UserDefaults.standard.synchronize()
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
//        guard let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController,
//            let _ = navigationController.topViewController as? TourAppUserInfoView else {return}
        UIApplication.shared.registerForRemoteNotifications()
        HealthKitManager.sharedInstance.authorize()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Logger.debug(userInfo)
        guard let aps = userInfo["aps"] as? [AnyHashable : Any],
            let title = aps["alert"] as? String else {return}
        if UIApplication.shared.windows.first?.rootViewController?.getLastController() as? ConversationScreen == nil  {
            NotificationView.presentOnTop(with: title)
        }
        
    }
}

extension AppDelegate {
    
    func setupProject() {
        
        self.printProjectSettings()
        
        self.setupProjectForTests()
        
        self.setupLogger()
        
        self.setupSDWebImage()
        
        self.setupSVProgressHUD()
        
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
    
    func setupSDWebImage() {
        let imageCache:SDImageCache = SDImageCache.shared()
        imageCache.maxCacheSize     = 1024*1024*50 // 100mb on disk
        imageCache.maxMemoryCost    = 1024*1024*10  // 10mb in memory
        
        let imageDownloader:SDWebImageDownloader = SDWebImageDownloader.shared()
        imageDownloader.downloadTimeout          = 60.0
    }
    
    func setupSVProgressHUD() {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
    }
}

