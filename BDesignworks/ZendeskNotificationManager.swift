//
//  ZendeskNotificationManager.swift
//  BDesignworks
//
//  Created by Ildar Zalyalov on 25.10.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import UIKit

class ZendeskNotificationManager {
    static let sharedInstance = ZendeskNotificationManager()
    
    
    func trigerNotificationOnZendesk(){
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            self.enableNotificationOnZendesk()
        }else{
            self.disableNotificationOnZendesk()
        }
    }
    
    //MARK: - API Requests
    func enableNotificationOnZendesk(){
        let _ = Router.User.enableNotificationOnZendesk.request().responseObject { (response: DataResponse<RTZendeskNotificationResponse>) in
            switch response.result {
            case .success:
                FSDLog("Notifications on zedesk enabled")
            case .failure(let error):
                FSDLog("Error: \(error)")
            }
        }
    }
    
    func disableNotificationOnZendesk(){
        let _ = Router.User.disableNotificationOnZendesk.request().responseObject { (response: DataResponse<RTZendeskNotificationResponse>) in
            switch response.result {
            case .success:
                FSDLog("Notifications on zedesk disabled")
            case .failure(let error):
                FSDLog("Error: \(error)")
            }
        }
    }
}
