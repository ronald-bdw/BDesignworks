
//
//  HealthKitManager.swift
//  Health Kit
//
//  Created by Eduard Lisin on 25/07/16.
//  Copyright © 2016 Eduard Lisin. All rights reserved.
//  1. Import HealthKit framework
//  2. Project Settings -> Capabilities -> HealthKit (Turn On)


import HealthKit

class HealthKitManager
{
    static let sharedInstance = HealthKitManager()
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    var isAuthorized: Bool {
        return UserDefaults.standard.bool(forKey: FSUserDefaultsKey.HealthKitRegistered)
    }
    
    let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    
    let stepsUnit = HKUnit.count()
    
    let defaultDaysToStepsCount = 7
    let defaultSamplesCount = 10
    
    var observerQuery: HKObserverQuery?
    var request: DataRequest? {
        willSet {
            self.request?.cancel()
        }
    }
    
    
    func authorize() {
        let dataTypesToRead = NSSet(objects: self.stepsCount)
        self.healthStore?.requestAuthorization(toShare: nil, read: dataTypesToRead as? Set<HKObjectType>, completion: { [weak self] (success, error) in
            if success {
                UserDefaults.standard.set(true, forKey: FSUserDefaultsKey.HealthKitRegistered)
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: FSNotificationKey.FitnessDataIntegration.HealthKit) , object: nil)
                self?.sendHealthKitData()
            } else {
                Logger.error("\(error)")
            }
        })
    }
    
    func sendHealthKitData() {
        self.enableBackgroundDelivery()
    }
    
    func stopSendingData() {
        self.healthStore?.disableAllBackgroundDelivery(completion: { (success, error) in
            success && error == nil ? Logger.debug("disabled background delivery") : Logger.error("error occured" + (error != nil ? "\(error)" : ""))
        })
        
        if let lObserverQuery = self.observerQuery {
            self.healthStore?.stop(lObserverQuery)
        }
        
        UserDefaults.standard.set(false, forKey: FSUserDefaultsKey.HealthKitRegistered)
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func enableBackgroundDelivery() {
        self.healthStore?.enableBackgroundDelivery(for: self.stepsCount, frequency: .hourly, withCompletion: { [weak self] (success, error) in
            guard error == nil else { Logger.error(error); return}
            self?.queryStepsInBackground()
        })
    }
    
    fileprivate func querySteps(_ completionHandler: HKObserverQueryCompletionHandler? = nil) {
        
        let endDate = Date()
        let startDate = ENUser.getMainUser()?.lastStepsHealthKitUpdateDate ?? endDate.fs_dateByAddingDays(-self.defaultDaysToStepsCount)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        let sampleQuery = HKSampleQuery(sampleType: self.stepsCount,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)] )
        {  (query, results, error) in
            
            guard var results = results as? [HKQuantitySample] else {return}
            if Int(startDate.timeIntervalSince1970) == Int(results.last?.endDate.timeIntervalSince1970 ?? 0) {
                results.remove(at: results.count - 1)
            }
            let steps = results.map({ENSteps(startDate: $0.startDate, finishDate: $0.endDate, count: Int($0.quantity.doubleValue(for: (HKUnit.count()))))})
            guard steps.count > 0 else {return}
            
            let lastStepsSampleDate = steps.map({$0.finishDate}).max(by: { (date, otherDate) -> Bool in
                date.compare(otherDate) == .orderedAscending
            })
            Logger.debug("lastStepsDate:\(lastStepsSampleDate)")
            self.request = Router.Steps.send(steps: steps, source: .HealthKit).request().responseObject({ (response: DataResponse<RTStepsSendResponse>) in
                switch response.result {
                case .success(_):
                    do {
                        let realm = try Realm()
                        let user = realm.objects(ENUser.self).first
                        try realm.write({
                            user?.lastStepsHealthKitUpdateDate = lastStepsSampleDate
                        })
                    }
                    catch let error {
                        Logger.error("\(error)")
                        
                    }
                case .failure(let error):
                    Logger.error("\(error)")
                }
                
                completionHandler?()
            })}
        
        self.healthStore?.execute(sampleQuery)
    }
    
    fileprivate func queryStepsInBackground() {
        if let lObserverQuery = self.observerQuery {
            self.healthStore?.stop(lObserverQuery)
            self.request?.cancel()
        }
        self.observerQuery = HKObserverQuery(sampleType: self.stepsCount, predicate: nil) { [weak self] (query, completionHandler, error) in
            
            guard error == nil else { Logger.error(error); return}
            
            self?.querySteps(completionHandler)
        }
        self.healthStore?.execute(self.observerQuery!)
    }
}
