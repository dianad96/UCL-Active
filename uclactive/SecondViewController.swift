//
//  SecondViewController.swift
//  uclactive
//
//  Created by Diana Darie on 7/16/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//


import UIKit
import CoreLocation
import HealthKit


class SecondViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    let healthManager: HealthKitManager = HealthKitManager()
    
    var zeroTime = NSTimeInterval()
    var timer : NSTimer = NSTimer()
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var distanceTraveled = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Need to Enable Location")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    @IBAction func startTimer(sender: AnyObject) {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        zeroTime = NSDate.timeIntervalSinceReferenceDate()
        
        distanceTraveled = 0.0
        startLocation = nil
        lastLocation = nil
        
        locationManager.startUpdatingLocation()
    }

    @IBAction func stopTimer(sender: AnyObject) {
        timer.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var timePassed: NSTimeInterval = currentTime - zeroTime
        let minutes = UInt8(timePassed / 60.0)
        timePassed -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(timePassed)
        timePassed -= NSTimeInterval(seconds)
        let millisecsX10 = UInt8(timePassed * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strMSX10 = String(format: "%02d", millisecsX10)
        
        timerLabel.text = "\(strMinutes):\(strSeconds):\(strMSX10)"
        
        if timerLabel.text == "60:00:00" {
            timer.invalidate()
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first as CLLocation!
        } else {
            let lastDistance = lastLocation.distanceFromLocation(locations.last as CLLocation!)
            distanceTraveled += lastDistance * 0.000621371
            
            let trimmedDistance = String(format: "%.2f", distanceTraveled)
            
            milesLabel.text = "\(trimmedDistance) Miles"
        }
        
        lastLocation = locations.last as CLLocation!
    }


    @IBAction func share(sender: AnyObject) {
        healthManager.saveDistance(distanceTraveled, date: NSDate())
    }
    
}

