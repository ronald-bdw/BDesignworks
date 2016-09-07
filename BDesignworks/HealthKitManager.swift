//
//  HealthKitManager.swift
//  Health Kit
//
//  Created by Eduard Lisin on 25/07/16.
//  Copyright © 2016 Eduard Lisin. All rights reserved.
//  1. Import HealthKit framework
//  2. Project Settings -> Capabilities -> HealthKit (Turn On)


import HealthKit

typealias UserHealthInfo = (age: Int?, sex: HKBiologicalSexObject?, bloodType: HKBloodTypeObject?)

enum HealthKitAuthorizationResult
{
    case Success
    case InvailidDevice
    case OperationCanceled
    case OtherError
    
    var description: String {
        switch self
        {
        case .Success:
            return "Авторизация успешна"
        case .InvailidDevice:
            return "Данное устройство не поддерживает HealthKit"
        case .OperationCanceled:
            return "Доступ не был предоставлен"
        case .OtherError:
            return "Иная ошибка"
        }
    }
}


class HealthKitManager
{
    class var sharedInstance: HealthKitManager {
        struct Singleton {
            static let instance = HealthKitManager()
        }
        
        return Singleton.instance
    }
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    let stepsCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    
    let stepsUnit = HKUnit.countUnit()
    
    let defaultDaysToStepsCount = 7
    
    func sendHealthKitData() {
        let dataTypesToRead = NSSet(objects: self.stepsCount!)
        self.healthStore?.requestAuthorizationToShareTypes(nil, readTypes: dataTypesToRead as? Set<HKObjectType>, completion: { [unowned self] (success, error) in
            if success {
                self.queryStepsByDay()
            } else {
                Logger.error("\(error)")
            }
        })
    }
    
    func queryStepsByDay() {
        let interval = NSDateComponents()
        interval.day = 1
        
        let anchorDate = NSDate().fs_midnightDate()
        
        let query = HKStatisticsCollectionQuery(quantityType: self.stepsCount!,
                                                quantitySamplePredicate: nil,
                                                options: .CumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            let endDate = NSDate()
            let startDate = User.getMainUser()?.lastStepsUpdateDate ?? endDate.fs_dateByAddingDays(-self.defaultDaysToStepsCount)
            
            results?.enumerateStatisticsFromDate(startDate, toDate: endDate) {statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    Router.Steps.Send(count: Int(quantity.doubleValueForUnit((HKUnit.countUnit()))), startedAt: statistics.startDate, finishedAt: statistics.endDate).request().responseObject({ (response: Response<RTStepsSendResponse, RTError>) in
                        switch response.result {
                        case .Success(let value):
                            Logger.debug("\(value.activity)")
                            guard let lUser = User.getMainUser() else {return}
                            if lUser.lastStepsUpdateDate == nil || lUser.lastStepsUpdateDate!.compare(statistics.endDate) == .OrderedAscending {
                                do {
                                    let realm = try Realm()
                                    let user = realm.objects(User).first
                                    try realm.write({
                                        user?.lastStepsUpdateDate = statistics.endDate
                                    })
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
            
        }
        
        self.healthStore?.executeQuery(query)
    }
}
