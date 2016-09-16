
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
    
    let stepsCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
    
    let stepsUnit = HKUnit.countUnit()
    
    let defaultDaysToStepsCount = 7
    let defaultSamplesCount = 10
    
    func sendHealthKitData() {
        let dataTypesToRead = NSSet(objects: self.stepsCount)
//        let itemsToWrite = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
        self.healthStore?.requestAuthorizationToShareTypes(nil, readTypes: dataTypesToRead as? Set<HKObjectType>, completion: { [unowned self] (success, error) in
            if success {
//                self.saveSteps()
//                self.querySteps()
                self.enableBackgroundDelivery()
//                FitBitManager.sharedInstance.sendFitBitData()
            } else {
                Logger.error("\(error)")
            }
        })
    }
    
    func enableBackgroundDelivery() {
        self.healthStore?.enableBackgroundDeliveryForType(self.stepsCount, frequency: .Hourly, withCompletion: { (success, error) in
            guard error == nil else {print(error); return}
            self.queryStepsInBackground()
        })
    }
    
    ///Use only in debug mode. Before using add corresponding write access
    func saveSteps() {
        let stepsQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: 1000)
        let distance = HKQuantitySample(type: self.stepsCount, quantity: stepsQuantity, startDate: NSDate().dateByAddingHours(-5), endDate: NSDate())
        
        self.healthStore?.saveObject(distance, withCompletion: { (success, error) -> Void in
            if (error == nil) {
                Logger.debug("successfully written")
            } else {
                Logger.debug("Error writing steps: \(error)")
            }
        })
    }
    
    func querySteps() {
        let sampleQuery = HKSampleQuery(sampleType: self.stepsCount,
                                        predicate: nil,
                                        limit: self.defaultSamplesCount,
                                        sortDescriptors: nil)
        {  (query, results, error) in
            guard let results = results as? [HKQuantitySample] else {return}
            
            let endDate = NSDate()
            let startDate = User.getMainUser()?.lastStepsHealthKitUpdateDate ?? endDate.fs_dateByAddingDays(-self.defaultDaysToStepsCount)
            
            let validResults = results.filter({startDate.compare($0.startDate) == .OrderedAscending})
            let steps = validResults.map({ENSteps(startDate: $0.startDate, finishDate: $0.endDate, count: Int($0.quantity.doubleValueForUnit((HKUnit.countUnit()))))})
            guard steps.count > 0 else {return}
            
            
            let notification = UILocalNotification()
            notification.repeatInterval = NSCalendarUnit.Minute
            notification.alertBody = "Hello"
            notification.fireDate = NSDate().dateByAddingMinutes(1)
            notification.timeZone = NSTimeZone.defaultTimeZone()
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
//            Router.Steps.Send(steps: steps, source: .HealthKit).request().responseObject({ (response: Response<RTStepsSendResponse, RTError>) in
//                switch response.result {
//                case .Success(_):
//                    do {
//                        let realm = try Realm()
//                        let user = realm.objects(User).first
//                        try realm.write({
//                            user?.lastStepsHealthKitUpdateDate = endDate
//                        })
//                        Logger.debug("updatedStepsDate: \(user?.lastStepsHealthKitUpdateDate)")
//                    }
//                    catch let error {
//                        Logger.error("\(error)")
//                    }
//                case .Failure(let error):
//                    Logger.error("\(error)")
//                }
//            })}
        
        self.healthStore?.executeQuery(sampleQuery)
    }
    
    func queryStepsInBackground() {
        let observerQuery = HKObserverQuery(sampleType: self.stepsCount, predicate: nil) { [weak self] (query, completionHandler, error) in
            guard error == nil else {Logger.error("\(error)"); return}
            self?.querySteps()
        }
        self.healthStore?.executeQuery(observerQuery)
    }
}
