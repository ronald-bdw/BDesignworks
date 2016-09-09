//
//  FitBitManager.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 08.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class FitBitManager {
    static let sharedInstance = FitBitManager()
    
    private let cliendId = "227RV6"
    
    func sendFitBitData() {
        if let token = User.getMainUser()?.fitbitToken {
            Logger.debug(token)
            self.getSteps()
        }
        else {
            let urlString = "https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=" + self.cliendId + "&redirect_uri=pearup%3A%2F%2Fpearup.com%2Ffitbit_auth&scope=activity&expires_in=31536000"
            guard let url = NSURL(string: urlString) else {return}
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    private func getSteps() {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.month = 9
        dateComponents.day = 1
        guard let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents) else {return}
        Router.Steps.Get(day: date).request().responseObject { (response: Response<RTStepsGetResponse, RTError>) in
            switch response.result {
            case .Success(let value):
                Logger.debug("\(value.stepsPerDay)")
                Logger.debug("\(value.stepsIntraday)")
                
                let validSteps = value.stepsIntraday.filter({$0.finishDate.compare(NSDate()) == .OrderedAscending})
                guard validSteps.count > 0 else {return}
                self.sendDataToServer(validSteps)
            case .Failure(let error):
                Logger.error("\(error)")
            }
        }
    }
    
    private func sendDataToServer(steps: [ENSteps]) {
        Router.Steps.Send(steps: steps).request().responseObject({ (response: Response<RTStepsSendResponse, RTError>) in
            switch response.result {
            case .Success(_):
                guard let lUser = User.getMainUser() else {return}
                if lUser.lastStepsFitBitUpdateDate == nil || lUser.lastStepsFitBitUpdateDate!.compare(NSDate()) == .OrderedAscending {
                    do {
                        let realm = try Realm()
                        let user = realm.objects(User).first
                        try realm.write({
                            user?.lastStepsFitBitUpdateDate = NSDate()
                        })
                        Logger.debug("updatedStepsDate: \(user?.lastStepsFitBitUpdateDate)")
                    }
                    catch let error {
                        Logger.error("\(error)")
                    }
                }
            case .Failure(let error):
                Logger.error("\(error)")
            }
        })
    }
}