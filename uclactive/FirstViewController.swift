//
//  FirstViewController.swift
//  uclactive
//
//  Created by Diana Darie on 7/16/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit
import HealthKit
import FacebookLogin
import FacebookCore

class FirstViewController: UIViewController {
    
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    let healthManager:HealthKitManager = HealthKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let loginButton = LoginButton(readPermissions: [ .PublicProfile ])
        loginButton.center = CGPointMake(view.frame.width/2, 500)
        
        view.addSubview(loginButton)
        
        if let accessToken = AccessToken.current {
            print ("I'm logged in.")
        } else {
            print ("I'm logged out.")
        }
        
    }
   }

