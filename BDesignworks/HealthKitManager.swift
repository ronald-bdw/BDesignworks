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
    private let healthKitStore: HKHealthStore = HKHealthStore()
    static let sharedInstance = HealthKitManager()
    
    
    func authorize(completion: ((authStatus: HealthKitAuthorizationResult) -> Void)?)
    {
        if !HKHealthStore.isHealthDataAvailable() {
            completion?(authStatus: HealthKitAuthorizationResult.InvailidDevice)
            return
        }
        
        let itemsToWrite = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
                               HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
                               HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
                               HKQuantityType.workoutType())
        
        let itemsToRead = Set(arrayLiteral:  HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
                              HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
                              HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
                              HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
                              HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
                              HKObjectType.workoutType())
        
        
        self.healthKitStore.requestAuthorizationToShareTypes(itemsToWrite, readTypes: itemsToRead) { (completed, error) in
            
            if error != nil {
                if completed == false {
                    completion?(authStatus: HealthKitAuthorizationResult.OperationCanceled)
                } else {
                    completion?(authStatus: HealthKitAuthorizationResult.OtherError)
                }
                return
            }
            
            completion?(authStatus: HealthKitAuthorizationResult.Success)
        }
    }
    
    
    
    //MARK: Writing User Information
    func saveDistance(distance: Double, date: NSDate, completion: ((success: Bool) -> Void)?)
    {
        let distanceType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        let distance = HKQuantitySample(type: distanceType!, quantity: distanceQuantity, startDate: date, endDate: date)
        
        healthKitStore.saveObject(distance, withCompletion: { (success, error) -> Void in
            if (error != nil) {
                completion?(success: false)
            } else {
                print("Error writing steps: \(error?.localizedDescription)")
                completion?(success: true)
            }
        })
    }
    
    
    
    //MARK: Reading User Information
    func userInfo() -> UserHealthInfo
    {
        return (userAge(), userSex(), userBloodType())
    }
    
    func userAge() -> Int?
    {
        do {
            let birthDay = try healthKitStore.dateOfBirth()
            
            let today = NSDate()
            let differenceComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: birthDay, toDate: today, options: NSCalendarOptions(rawValue: 0))
            return differenceComponents.year
        }
        catch {
            print("Error reading birthday: \(processInformationError(error as NSError))")
            return nil
        }
    }
    
    func userSex() -> HKBiologicalSexObject?
    {
        do {
            return try healthKitStore.biologicalSex()
        }
        catch {
            print("Error reading sex: \(processInformationError(error as NSError))")
            return nil
        }
    }
    
    func userBloodType() -> HKBloodTypeObject?
    {
        do {
            return try healthKitStore.bloodType()
        }
        catch {
            print("Error reading blood type: \(processInformationError(error as NSError))")
            return nil
        }
    }
    
    func processInformationError(error: NSError) -> String
    {
        switch error.code
        {
        case 5:
            return "Доступ к этому типу данных не был получен"
            
        default:
            return error.localizedDescription
        }
    }
}
