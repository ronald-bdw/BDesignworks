//
//  FitbitManager.swift
//  BDesignworks
//
//  Created by Ildar Zalyalov on 27.10.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
class FitbitManager {
    static let sharedInstance = FitbitManager()
    
    //MARK: - API Requests
    
    func removeFitBitTokenFromServer(){
        guard let tokeId = UserDefaults.standard.object(forKey: FSUserDefaultsKey.FitbitTokenId) as? Int else {return}
        let _ = Router.Steps.deleteFitBitToken(tokenId: String(tokeId)).request().responseObject { (response: DataResponse<RTFitbitResponse>) in
            switch response.result {
            case .success(let response):
                Logger.debug("successfully remove fitbit code")
                Logger.debug("Fitbit body: \(response)")
                UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.FitbitRegistered)
                UserDefaults.standard.removeObject(forKey: FSUserDefaultsKey.FitbitTokenId)
                UserDefaults.standard.synchronize()
            case .failure(let error):
                Logger.error(error)
                ShowErrorAlert()
            }
        }
    }
}
