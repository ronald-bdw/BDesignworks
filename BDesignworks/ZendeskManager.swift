//
//  ZendeskManager.swift
//  BDesignworks
//
//  Created by Ildar Zalyalov on 25.10.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import UIKit

class ZendeskManager {
    static let sharedInstance = ZendeskManager()
    
    
    func trigerNotificationOnZendesk(){
        guard let user = BDRealm?.objects(ENUser.self).first,
            BDRealm?.objects(AuthInfo.self).count == 0, user.token != nil else {return}
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            self.enableNotificationOnZendesk()
        }else{
            self.disableNotificationOnZendesk()
        }
    }
    
    func trigerTimezoneOnZendesk() {
        guard let user = ENUser.getMainUser(), user.token != nil else {return}
        
        let _ = Router.User.sendTimezone(userId: user.id).request().responseObject { (response: DataResponse<RTEmptyResponse>) in
            switch response.result {
            case .success:
                Logger.debug("TimeZone sent")
            case .failure(let error):
                Logger.error("Error:\(error)")
            }
        }
    }
    
    //MARK: - API Requests
    private func enableNotificationOnZendesk(){
        let _ = Router.User.enableNotificationOnZendesk.request().responseObject { (response: DataResponse<RTEmptyResponse>) in
            switch response.result {
            case .success:
                Logger.debug("Notifications on zedesk enabled")
            case .failure(let error):
                Logger.error("Error:\(error)")
            }
        }
    }
    
    private func disableNotificationOnZendesk(){
        let _ = Router.User.disableNotificationOnZendesk.request().responseObject { (response: DataResponse<RTEmptyResponse>) in
            switch response.result {
            case .success:
                Logger.debug("Notifications on zedesk disabled")
            case .failure(let error):
                Logger.error("Error:\(error)")
            }
        }
    }
}
