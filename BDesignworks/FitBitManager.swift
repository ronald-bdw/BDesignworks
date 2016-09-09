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
    private let expireTime = 31536000
    
    private let defaultDaysToStepsCount = 7
    
    func sendFitBitData() {
        if let token = User.getMainUser()?.fitbitToken {
            Logger.debug(token)
            self.getSteps()
        }
        else {
            let urlString = "https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=" + self.cliendId + "&redirect_uri=pearup%3A%2F%2Fpearup.com%2Ffitbit_auth&scope=activity&expires_in=\(self.expireTime)"
            guard let url = NSURL(string: urlString) else {return}
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    private func getSteps() {
        let endDate = NSDate()
        let startDate = User.getMainUser()?.lastStepsFitBitUpdateDate ?? endDate.fs_dateByAddingDays(-self.defaultDaysToStepsCount)
        
        let dates = NSDate.datesByDay(from: startDate, to: endDate)
        for date in dates {
            Router.Steps.Get(day: date).request().responseObject { (response: Response<RTStepsGetResponse, RTError>) in
                switch response.result {
                case .Success(let value):
                    
                    let validSteps = value.stepsIntraday.filter({startDate.compare($0.startDate) == .OrderedAscending})
                        .filter({$0.finishDate.compare(endDate) == .OrderedAscending})
                    
                    guard validSteps.count > 0 else {return}
                    self.sendDataToServer(validSteps)
                case .Failure(let error):
                    Logger.error("\(error)")
                }
            }
        }
    }
    
    private func sendDataToServer(steps: [ENSteps]) {
        Router.Steps.Send(steps: steps).request().responseObject({ (response: Response<RTStepsSendResponse, RTError>) in
            switch response.result {
            case .Success(_):
                do {
                    let realm = try Realm()
                    let user = realm.objects(User).first
                    try realm.write({
                        user?.lastStepsFitBitUpdateDate = NSDate()
                    })
                }
                catch let error {
                    Logger.error("\(error)")
                }
            case .Failure(let error):
                Logger.error("\(error)")
            }
        })
    }
}