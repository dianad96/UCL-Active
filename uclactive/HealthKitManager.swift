//
//  HealthKitManager.swift
//  uclactive
//
//  Created by Diana Darie on 7/16/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager: NSObject {
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success: Bool, error: NSError!) -> Void)!) {
        
        // State the health data type(s) we want to read from HealthKit.
        let healthDataToRead = Set(arrayLiteral:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierFitzpatrickSkinType)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!)
        
        // State the health data type(s) we want to write from HealthKit.
        let healthDataToWrite = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!)
        
        // Just in case OneHourWalker makes its way to an iPad...
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        // Request authorization to read and/or write the specific data.
        healthKitStore.requestAuthorizationToShareTypes(healthDataToWrite, readTypes: healthDataToRead) { (success, error) -> Void in
            if( completion != nil ) {
                completion(success:success, error:error)
            }
        }
    }
    
    
    // Get User's Data
    func getSample(sampleType: HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
        
        // Predicate for the sample query
        let distantPastSample = NSDate.distantPast() as NSDate
        let currentDate = NSDate()
        let lastSamplePredicate = HKQuery.predicateForSamplesWithStartDate(distantPastSample, endDate: currentDate, options: .None)
        
        // Get the single most recent sample
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query HealthKit for the last Sample entry.
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: lastSamplePredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
            
            if let queryError = error {
                completion(nil, queryError)
                return
            }
            
            // Set the first HKQuantitySample in results as the most recent sample.
            let lastSample = results!.first
            
            if completion != nil {
                completion(lastSample, nil)
            }
        }
        // Time to execute the query.
        self.healthKitStore.executeQuery(sampleQuery)
    }
    

    
    func saveDistance(distanceRecorded: Double, date: NSDate ) {
        
        // Set the quantity type to the running/walking distance.
        let distanceType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
        
        // Set the unit of measurement to miles.
        let distanceQuantity = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: distanceRecorded)
        
        // Set the official Quantity Sample.
        let distance = HKQuantitySample(type: distanceType!, quantity: distanceQuantity, startDate: date, endDate: date)
        
        // Save the distance quantity sample to the HealthKit Store.
        healthKitStore.saveObject(distance, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print(error)
            } else {
                print("The distance has been recorded! Better go check!")
            }
        })
    }
}