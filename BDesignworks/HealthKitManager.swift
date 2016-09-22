
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
    
    let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    
    let stepsUnit = HKUnit.count()
    
    let defaultDaysToStepsCount = 7
    let defaultSamplesCount = 10
    
    var observerQuery: HKObserverQuery?
    
    func sendHealthKitData() {
        let dataTypesToRead = NSSet(objects: self.stepsCount)
//        let itemsToWrite = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
        self.healthStore?.requestAuthorization(toShare: nil, read: dataTypesToRead as? Set<HKObjectType>, completion: { [weak self] (success, error) in
            if success {
                self?.enableBackgroundDelivery()
            } else {
                Logger.error("\(error)")
            }
        })
    }
    
    func stopSendingData() {
        self.healthStore?.disableAllBackgroundDelivery(completion: { (success, error) in
            success && error == nil ? Logger.debug("disabled background delivery") : Logger.error("error occured" + (error != nil ? "\(error)" : ""))
        })
        
        if let lObserverQuery = self.observerQuery {
            self.healthStore?.stop(lObserverQuery)
        }
    }
    
    func enableBackgroundDelivery() {
        self.healthStore?.enableBackgroundDelivery(for: self.stepsCount, frequency: .hourly, withCompletion: { [weak self] (success, error) in
            guard error == nil else { Logger.error(error); return}
            self?.queryStepsInBackground()
        })
    }
    
    ///Use only in debug mode. Before using add corresponding write access
    func saveSteps() {
        let stepsQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: 1000)
        let distance = HKQuantitySample(type: self.stepsCount, quantity: stepsQuantity, start: Date().dateByAddingHours(-5), end: Date())
        
        self.healthStore?.save(distance, withCompletion: { (success, error) -> Void in
            if (error == nil) {
                Logger.debug("successfully written")
            } else {
                Logger.debug("Error writing steps: \(error)")
            }
        })
    }
    
    func querySteps(_ completionHandler: HKObserverQueryCompletionHandler? = nil) {
        
        let endDate = Date()
        let startDate = ENUser.getMainUser()?.lastStepsHealthKitUpdateDate ?? endDate.fs_dateByAddingDays(-self.defaultDaysToStepsCount)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        let sampleQuery = HKSampleQuery(sampleType: self.stepsCount,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)] )
        {  (query, results, error) in
            
            guard var results = results as? [HKQuantitySample] else {return}
            if Int(startDate.timeIntervalSince1970) == Int(results.last?.startDate.timeIntervalSince1970 ?? 0) {
                results.remove(at: results.count - 1)
            }
            let steps = results.map({ENSteps(startDate: $0.startDate, finishDate: $0.endDate, count: Int($0.quantity.doubleValue(for: (HKUnit.count()))))})
            guard steps.count > 0 else {return}
            
            let lastStepsSampleDate = steps.map({$0.startDate}).max(by: { (date, otherDate) -> Bool in
                date.compare(otherDate) == .orderedAscending
            })
            let _ = Router.Steps.send(steps: steps, source: .HealthKit).request().responseObject({ (response: DataResponse<RTStepsSendResponse>) in
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
    
    func queryStepsInBackground() {
        if let lObserverQuery = self.observerQuery {
            self.healthStore?.stop(lObserverQuery)
        }
        self.observerQuery = HKObserverQuery(sampleType: self.stepsCount, predicate: nil) { [weak self] (query, completionHandler, error) in
            
            guard error == nil else { Logger.error(error); return}
            
            self?.querySteps(completionHandler)
        }
        self.healthStore?.execute(self.observerQuery!)
    }
}
