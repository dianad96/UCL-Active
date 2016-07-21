//
//  ProfileController.swift
//  uclactive
//
//  Created by Diana Darie on 7/20/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit
import HealthKit

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let distance_W_LabelHeader:CGFloat = 30.0 // The distance between the top of the screen and the top of the White Label

enum contentTypes {
    case Performance, Details
}

class ProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate  {
    
    let healthKitStore:HKHealthStore = HKHealthStore()

    let healthManager: HealthKitManager = HealthKitManager()
    var height: HKQuantitySample?
    var bmi: HKQuantitySample?
    
    var heightValue = "Not enough data"
    var sexValue = "Not enough data"
    var bloodTypeValue = "Not enough data"
    var skinType = "Not enough data"
    var birthdateValue = "Not enough data"
    var weightValue = "Not enough data"
    var bmiValue = "Not enough data"
    
    var heightInMeters: Double = 0.0
    var weightInKilograms: Double = 0.0

    //Outlet properties
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    
    //Class properties
    var headerBlurImageView:UIImageView!
    var headerImageView:UIImageView!
    var contentToDisplay : contentTypes = .Performance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
        tableView.delegate=self
        tableView.dataSource=self
        
        
        // We cannot access the user's HealthKit data without specific permission.
        getHealthKitPermission()
        
    }
    
    func getHealthKitPermission() {
        
        // Seek authorization in HealthKitManager.swift.
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                
                // Get and set the user's data.
                self.setHeight()
                self.getSex()
                self.getBloodType()
                self.getSkinType()
                self.getBirthdate()
                self.getWeight()
            } else {
                if error != nil {
                    print(error)
                }
                print("Permission denied.")
            }
        }
    }
    
    
    
    /*
        1. Get User's Height
    */
    func setHeight() {
        // Create the HKSample for Height.
        let heightSample = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        
        // Call HealthKitManager's getSample() method to get the user's height.
        self.healthManager.getSample(heightSample!, completion: { (userHeight, error) -> Void in
            
            if( error != nil ) {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            var heightString = ""
            
            self.height = userHeight as? HKQuantitySample
            self.heightInMeters = self.height!.quantity.doubleValueForUnit(HKUnit.meterUnit())

            // The height is formatted to the user's locale.
            if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
                let formatHeight = NSLengthFormatter()
                formatHeight.forPersonHeightUse = true
                heightString = formatHeight.stringFromMeters(meters)
            }
            
            // Set the label to reflect the user's height.
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("Height:", heightString)
                self.heightValue = heightString
            })
        })
        
    }
    
    /*
        2. Get User's Sex
     */
    func getSex() {
        
        var error:NSError?

        var biologicalSex:HKBiologicalSexObject?
        do {
            biologicalSex = try healthKitStore.biologicalSex()
            print("sex: ", biologicalSex)
            
            switch biologicalSex!.biologicalSex.rawValue {
            case 1:
                sexValue = "Female"
            case 2:
                sexValue = "Male"
            case 3:
                sexValue = "Other"
            default:
                sexValue = "Not enough data"
            }

        } catch var error1 as NSError {
            error = error1
            biologicalSex = nil
        };
        if error != nil {
            print("Error reading Biological Sex: \(error)")
        }
    }
    
    /*
        3. Get User's BloodType
     */
    func getBloodType() {
        
        var error:NSError?
        
        var bloodtype:HKBloodTypeObject?
        do {
            bloodtype = try healthKitStore.bloodType()
            print("blood type: ", bloodtype)
            
            switch bloodtype!.bloodType.rawValue {
            case 1:
                bloodTypeValue = "A+"
            case 2:
                bloodTypeValue = "A-"
            case 3:
                bloodTypeValue = "B+"
            case 4:
                bloodTypeValue = "B-"
            case 5:
                bloodTypeValue = "AB+"
            case 6:
                bloodTypeValue = "AB-"
            case 7:
                bloodTypeValue = "O+"
            case 8:
                bloodTypeValue = "O-"
                
            default:
                sexValue = "Not enough data"
            }
            
        } catch var error1 as NSError {
            error = error1
            bloodtype = nil
        };
        if error != nil {
            print("Error reading Blood Type: \(error)")
        }
    }
    
    
    /*
        4. Get User's SkinType
     */
    func getSkinType() {
        
        var error:NSError?
        
        var skin:HKFitzpatrickSkinTypeObject?
        do {
            skin = try healthKitStore.fitzpatrickSkinType()
            print("skin type: ", skin)
            
            switch skin!.skinType.rawValue {
            case 1:
                skinType = "Type I"
            case 2:
                skinType = "Type II"
            case 3:
                skinType = "Type III"
            case 4:
                skinType = "Type IV"
            case 5:
                skinType = "Type V"
            case 6:
                skinType = "Type VI"
            default:
                skinType = "Not enough data"
            }
            
        } catch var error1 as NSError {
            error = error1
            skin = nil
        };
        if error != nil {
            print("Error reading Skin Type: \(error)")
        }
    }

    /*
        5. Get User's Birthdate
     */
    func getBirthdate() {
        
        var error:NSError?
        
        var date: NSDate?
        do {
            date = try healthKitStore.dateOfBirth()
            print("birthdate: ", date)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            
            birthdateValue = dateFormatter.stringFromDate(date!)
            
        } catch var error1 as NSError {
            error = error1
            date = nil
        };
        if error != nil {
            print("Error reading Skin Type: \(error)")
        }
    }
    
    
    /*
        6. Get User's Weight
     */
    func getWeight(){
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        self.healthManager.getSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            
            var weightLocalizedString = "";
            var weight = mostRecentWeight as? HKQuantitySample;
            self.weightInKilograms = weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))

            if let kilograms = weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true;
                weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
            }
            print ("weight: " + weightLocalizedString)
            self.weightValue = weightLocalizedString
            self.getBMI()
        });
    }
    
    /*
        7. Get User's BMI
     */
    func getBMI(){
        if weightValue != "Not enough data!" && heightValue != "Not enough data!" {
            print("****", weightInKilograms, heightInMeters)
            bmiValue = String (weightInKilograms/(heightInMeters*heightInMeters))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Header - Image
        
        headerImageView = UIImageView(frame: headerView.bounds)
        headerImageView?.image = UIImage(named: "header_bg")
        headerImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerView.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        headerBlurImageView = UIImageView(frame: headerView.bounds)
        
        headerBlurImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBlurImageView?.alpha = 0.0
        headerView.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        headerView.clipsToBounds = true


    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view processing
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch contentToDisplay {
        case .Performance:
            return 3
            
        case .Details:
            return 10
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch contentToDisplay {
        case .Performance:
            cell.textLabel?.text = "Daily Steps"
            
        case .Details:
            let cellNr = indexPath.row
            switch cellNr {
            case 0:
                    cell.textLabel?.text = "Date of Birth: " + birthdateValue
            case 1:
                    cell.textLabel?.text = "Sex: " + sexValue
            case 2:
                    cell.textLabel?.text = "Blood Type: " + bloodTypeValue
            case 3:
                    cell.textLabel?.text = "Skin Type: " + skinType
            case 5:
                    cell.textLabel?.text = "Height: " + heightValue
            case 6:
                    cell.textLabel?.text = "Weight: " + weightValue
            case 7:
                    cell.textLabel?.text = "BMI: " + bmiValue
            default:
                    cell.textLabel?.text = " "
            }
        }
        return cell
    }
    
    
    
    @IBAction func selectContentType(sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            contentToDisplay = .Performance
        }
        else {
            contentToDisplay = .Details
        }
        
        tableView.reloadData()
    }

}

