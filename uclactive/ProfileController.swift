//
//  ProfileController.swift
//  uclactive
//
//  Created by Diana Darie on 7/20/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit
import HealthKit
import Foundation

struct Recipe {
    var name: String
    let thumbnails: String
    let prepTime: String
}

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
    
    //Credentials
    var apigeeKey: String = ""
    var apigeeSecret: String = ""
    
    // Errors
    var errorApigee: Int = 0
    
    //TableView
    var pressed: Int = 0
    
    
    // Basic Info
    var heightValue = "Not enough data/Unauthorized"
    var sexValue = "Not enough data/Unauthorized"
    var bloodTypeValue = "Not enough data/Unauthorized"
    var skinType = "Not enough data/Unauthorized"
    var birthdateValue = "Not enough data/Unauthorized"
    var weightValue = "Not enough data/Unauthorized"
    var bmiValue = "Not enough data/Unauthorized"
    
    var heightInMeters: Double = 0.0
    var weightInKilograms: Double = 0.0
    
    //Fitness Data
    var todayStepsValue: Double = 0.0
    var averageStepsValue: Double = 0.0
    var todayActiveEnergy: Double = 0.0

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
        
        readConfig()
        // Authorize the UCLActive app against Apigee Health APIx before allowing it to get permission from other apps
        self.authorizeApigee() { (result) -> () in
            print ("AUTHORIZING APIGEE!")
            if result == 1 {
                
                print ("APIGEE AUTHORIZED!")
                // We cannot access the user's HealthKit data without specific permission.
                print ("AUTHORIZING HEALTHKIT!!")
                self.getHealthKitPermission()
                print ("HEALTHKIT AUTORIZED!")
            } else {
                print ("APIGEE UNAUTHORIZED!")
            }
        }
        
    }
    
    // Read property/configuration file for the credentials
    func readConfig () {
        
        var format = NSPropertyListFormat.XMLFormat_v1_0 //format of the property list
        var plistData:[String:AnyObject] = [:]  //our data
        let plistPath:String? = NSBundle.mainBundle().pathForResource("Property List", ofType: "plist")! //the path of the data
        let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath!)! //the data in XML format
        do{ //convert the data to a dictionary and handle errors.
            plistData = try NSPropertyListSerialization.propertyListWithData(plistXML,options: .MutableContainersAndLeaves,format: &format)as! [String:AnyObject]
            
            self.apigeeKey = plistData["ApigeeKey"] as! String
            self.apigeeSecret = plistData["ApigeeSecret"] as! String
            print (self.apigeeKey)
            print(self.apigeeSecret)
        }
        catch{ // error condition
            print("Error reading plist: \(error), format: \(format)")
        }
    }
    
    // Authenticating app with Apigee Health APIx
    func authorizeApigee(completion: (Int) -> ()){
        // Send HTTP GET Request
    
        let scriptUrl = "https://fhirsandbox-prod.apigee.net/oauth/v2"
        let urlWithParams = scriptUrl + "/accesstoken?grant_type=client_credentials"
        let myUrl = NSURL(string: urlWithParams);
        
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST"
        
        // Add Basic Authorization
        
        let username = self.apigeeKey
        let password = self.apigeeSecret
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")
        
        
        // Or add Token value
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                completion(0)
                self.errorApigee = 1
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            if responseString!.containsString("invalid_client") == true {
                print ("NOPE")
                completion(0)
            } else { completion(1) }
        }
        
        task.resume()
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
                self.getSteps()
                self.getActiveEnergy()
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
    
    /*
     8. Get User's Steps
     */
    func getSteps () {
        let endDate = NSDate()
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: -1, toDate: endDate, options: [])
        
        let stepsSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        print ("start date: ", startDate)
        print ("end date: ", endDate)
        
        let query = HKSampleQuery(sampleType: stepsSampleType!, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                print("There was an error running the query: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                var dailyAVG:Double = 0.0
                var i:Int = 0
                var last:Double = 0.0
                for steps in results as! [HKQuantitySample]
                {
                    dailyAVG += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                    print(i, dailyAVG)
                    i+=1
                    last = steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
                self.averageStepsValue = dailyAVG
                self.todayStepsValue = last
                
                print("average: ", dailyAVG)
                print("today's steps: ", last)
                
            }
        })
        self.healthKitStore.executeQuery(query)
    }
    

    
    /*
     9. Get User's Active Energy
     */
    func getActiveEnergy () {
        let endDate = NSDate()
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: -1, toDate: endDate, options: [])
        
        let energySampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        print ("start date: ", startDate)
        print ("end date: ", endDate)
        
        let query = HKSampleQuery(sampleType: energySampleType!, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                print("There was an error running the query: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                for activity in results as! [HKQuantitySample]
                {
                    self.todayActiveEnergy = activity.quantity.doubleValueForUnit(HKUnit.kilocalorieUnit())
                    print(">>>>>", self.todayActiveEnergy)
                }
                
            }
        })
        self.healthKitStore.executeQuery(query)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    
    // MARK: Table view processing
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch contentToDisplay {
        case .Performance:
            return 10
            
        case .Details:
            return 10
        }
        
    }
    
    //MARK: - UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("HEREEE")
        print(indexPath)
        print(self.tableView!.indexPathForSelectedRow)
        self.pressed = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("detailsController", sender:self)
        
    }
    
    // MARK: Segue Method
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       // if segue.identifier == "detailsController" {
            print("WHY AM I HERE?")
        var secondVC: DetailController = segue.destinationViewController as! DetailController
        secondVC.received = todayStepsValue
        secondVC.rowPressed = pressed
        
       // }
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch contentToDisplay {
        case .Performance:
            let cellNr = indexPath.row
            switch cellNr {
                
            case 1:
                cell.textLabel?.text = "Daily Steps: " + String(self.todayStepsValue) + " steps"
            case 2:
                cell.textLabel?.text = "Average Steps: " + String(self.averageStepsValue) + " steps"
            case 3:
                cell.textLabel?.text = "Active Energy: " + String(self.todayActiveEnergy) + " kcal"
                
            default:
                cell.textLabel?.text = " "
            }
            
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

