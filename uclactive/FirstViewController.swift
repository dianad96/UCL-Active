//
//  FirstViewController.swift
//  uclactive
//
//  Created by Yonita Carter on 7/16/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.backgroundColor = UIColor.clearColor()
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.backgroundColor = UIColor(red: 0.58, green: 0.80, blue: 0.63, alpha: 1)
      
        
        
        button2.backgroundColor = UIColor.clearColor()
        button2.layer.cornerRadius = 20
        button2.layer.borderWidth = 1
        button2.layer.borderColor = UIColor.blackColor().CGColor
        button2.backgroundColor = UIColor(red: 0.58, green: 0.80, blue: 0.63, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func authorizeTapped(sender: UIButton) {
        HealthKitManager.authorizeHealthKit()

    }
    
}

