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
import Google

class FirstViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    let healthManager:HealthKitManager = HealthKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        let loginButton = LoginButton(readPermissions: [ .PublicProfile ])
        loginButton.center = CGPointMake(view.frame.width/2, 450)
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if configureError != nil {
            print(configureError)
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let button = GIDSignInButton(frame: CGRectMake(0, 0, 180, 10))
        button.center = CGPointMake(view.frame.width/2, 500)
        
        view.addSubview(loginButton)
        view.addSubview(button)
        
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        print(user.profile.email)
        print(user.profile.imageURLWithDimension(400))
    }
    
   }

