//
//  SmoochHelper.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 15/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class SmoochHelper: NSObject {
    static let sharedInstance = SmoochHelper()
    let smoochToken = "eiw2afikzfabehcj65ilhnp7q"
    
    //Custom properties for user
    //SKTUser.currentUser().addProperties([ "nickname" : "Lil Big Daddy Slim", "weight" : 650, "premiumUser" : true ])
    
    func startWithParameters(_ user: ENUser) {
        let settings = SKTSettings(appToken: smoochToken)
        settings.userId = user.zendeskId
        settings.conversationAccentColor = UIColor(fs_hexString: "74A025")!
        Smooch.initWith(settings)
        self.login(user.zendeskId)
        
        self.updateUserInfo(user: user)
        
        Smooch.conversation()?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageUploaded), name: NSNotification.Name.SKTMessageUploadCompleted, object: nil)
    }
    
    func login(_ userID: String) {
        Smooch.login(userID, jwt: nil)
    }
    
    func updateUserInfo(user: ENUser) {
        SKTUser.current()?.firstName = user.firstName
        SKTUser.current()?.lastName = "\(user.id)"
        SKTUser.current()?.email = user.email
        SKTUser.current()?.addProperties(["isNotDefaultUser": true])
    }
    
    func updateSignUpDate() {
        SKTUser.current()?.signedUpAt = Date()
    }
    
    func messageUploaded() {
        DispatchQueue.main.async {
            SubscriptionMigrationService.shared.showSubscriptionEndedAlertIfNeeded()
        }
    }
}

extension SmoochHelper: SKTConversationDelegate {
    func conversation(_ conversation: SKTConversation, shouldShowInAppNotificationFor message: SKTMessage) -> Bool {
        return false
    }
    
    func conversation(_ conversation: SKTConversation, didReceiveMessages messages: [Any]) {
        guard let message = messages.last as? SKTMessage,
                let text = message.text,
                message.isFromCurrentUser == false else {return}
        guard let window = UIApplication.shared.windows.first else {return}
        if window.rootViewController is SWRevealViewController &&
            window.rootViewController?.childViewControllers.first?.childViewControllers.first as? ConversationScreen == nil  {
            NotificationView.presentOnTop(with: text)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func conversation(_ conversation: SKTConversation, shouldShowFor action: SKTAction) -> Bool {
        return false
    }
    
    func conversation(_ conversation: SKTConversation, unreadCountDidChange unreadCount: UInt) {
        guard let window = UIApplication.shared.windows.first else {return}
        if window.rootViewController is SWRevealViewController &&
            window.rootViewController?.childViewControllers.first?.childViewControllers.first as? ConversationScreen == nil  {
            UIApplication.shared.applicationIconBadgeNumber = Int(unreadCount)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    
}
