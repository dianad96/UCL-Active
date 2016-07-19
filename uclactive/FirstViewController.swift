//
//  FirstViewController.swift
//  uclactive
//
//  Created by Diana Darie on 7/16/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit
import HealthKit

class FirstViewController: UIViewController {
    
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var heightLabel: UILabel!
    
    
    let healthManager:HealthKitManager = HealthKitManager()
    
    var height: HKQuantitySample?

    
    override func viewDidLoad() {
        super.viewDidLoad()
               
  
    }
   }

