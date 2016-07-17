//
//  HealthKitManager.swift
//  uclactive
//
//  Created by Yonita Carter on 7/16/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager: NSObject {
    
    static let healthKitStore = HKHealthStore()
    
    static func authorizeHealthKit() {
        
        let healthKitTypes: Set = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
        ]
        
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypes,
                                                        readTypes: healthKitTypes) { _, _ in }
    }
    
    func getHeight(sampleType: HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
        
        // Predicate for the height query
        let distantPastHeight = NSDate.distantPast() as NSDate
        let currentDate = NSDate()
        let lastHeightPredicate = HKQuery.predicateForSamplesWithStartDate(distantPastHeight, endDate: currentDate, options: .None)
        
        // Get the single most recent height
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query HealthKit for the last Height entry.
        let heightQuery = HKSampleQuery(sampleType: sampleType, predicate: lastHeightPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
            
            if let queryError = error {
                completion(nil, queryError)
                return
            }
            
            // Set the first HKQuantitySample in results as the most recent height.
            let lastHeight = results!.first
            
            if completion != nil {
                completion(lastHeight, nil)
                print(lastHeight)
            }
        }
        
    }
    
    
}