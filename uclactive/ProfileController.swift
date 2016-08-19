//  ProfileController.swift
//  uclactive
//
//  Created by Diana Darie on 7/20/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit
import HealthKit
import Foundation
import Alamofire
import SwiftyJSON

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

class ProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let healthKitStore:HKHealthStore = HKHealthStore()

    let healthManager: HealthKitManager = HealthKitManager()
    var height: HKQuantitySample?
    var bmi: HKQuantitySample?
    
    
    //openMRS 
    var person_uuid: String = "85511527-6223-11e6-a4f9-000d3a23bb00"
    //concepts openmrs
    var heart_rate_uuid: String = "85062ed4-6223-11e6-a4f9-000d3a23bb00"
    var daily_steps_uuid: String = "cc66a103-8bdb-4128-83f8-23abb9124b93"
    var average_steps_uuid: String = "e8581e20-5d50-4578-8447-b43ba56b0990"
    var active_energy_uuid: String = "58431d42-19d4-4992-87f7-ccf5774b3059"
    var date_of_birth_uuid: String = "fea80672-aa3a-4ff9-9ae0-b440752a37bc"
    var sex_uuid: String = "3d8cffcd-59a8-422d-b6f5-b4f18a0b2863"
    var blood_type_uuid: String = "20f83fad-25b0-4766-bd60-2a23369489d2"
    var skin_type_uuid: String = "9287547e-5601-4337-8490-6977b3f862ce"
    var weight_uuid: String = "7945ff5e-32a8-4728-90bf-1bd2695c8dae"
    var height_uuid: String = "60e82064-7a69-4a2a-a5f3-290c36de0513"
    var bmi_uuid: String = "1f3bccd6-06bb-4a32-8506-91379c6ebafb"
    // concepts snomed
    var heart_rate_snomed: String = "364075005"
    var daily_steps_snomed: String = ""
    var average_steps_snomed: String = ""
    var active_energy_snomed: String = "359755007"
    var date_of_birth_snomed: String = "184099003"
    var sex_snomed: String = ""
    var blood_type_snomed: String = "365642005"
    var skin_type_snomed: String = ""
    var weight_snomed: String = "27113001"
    var height_snomed: String = "50373000"
    var bmi_snomed: String = "60621009"
    // concepts loinc
    var heart_rate_loinc: String = "8867-4"
    var daily_steps_loinc: String = "c41950-7"
    var average_steps_loinc: String = "41950-7"
    var active_energy_loinc: String = ""
    var date_of_birth_loinc: String = "21112-8"
    var sex_loinc: String = "76689-9"
    var blood_type_loinc: String = "933-2"
    var skin_type_loinc: String = "66555-4"
    var weight_loinc: String = "29463-7"
    var height_loinc: String = "8302-2"
    var bmi_loinc: String = "59574-4"
    // concepts names
    var heart_rate_name: String = "Heart Rate"
    var daily_steps_name: String = "Daily Steps"
    var average_steps_name: String = "Average Steps"
    var active_energy_name: String = "Energy Steps"
    var date_of_birth_name: String = "Date of Birth"
    var sex_name: String = "Sex"
    var blood_type_name: String = "Blood Type"
    var skin_type_name: String = "Skin Type"
    var weight_name: String = "Weight"
    var height_name: String = "Height"
    var bmi_name: String = "BMI"
    //concepts units
    var heart_rate_unit: String = "bmp"
    var daily_steps_unit: String = "steps"
    var average_steps_unit: String = "steps"
    var active_energy_unit: String = "kcal"
    var date_of_birth_unit: String = ""
    var sex_unit: String = ""
    var blood_type_unit: String = ""
    var skin_type_unit: String = ""
    var weight_unit: String = "kg"
    var height_unit: String = "cm"
    var bmi_unit: String = "kg/m2"
    //coding names
    var coding_system_1: String = "http://openmrs.org"
    var coding_system_2: String = "http://snomed.org"
    var coding_system_3: String = "http://loinc.org"
    var unit_system: String = "http://unitsofmeasure.org"
    
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
    var yesterdayStepsValue: Double = 0.0
    var averageStepsValue: Double = 0.0
    var todayActiveEnergy: Double = 0.0

    // Date
    var todayStepsDate: String = ""
    var yesterdayStepsDate: String = ""
    
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
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: -1 , toDate: endDate, options: [])
        
        let stepsSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        print ("start date: ", startDate)
        print ("end date: ", endDate)
        
        let query = HKSampleQuery(sampleType: stepsSampleType!, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                print("There was an error running the query: \(error)")
            }
            
            
            // IMPORTANT NOTE
            // Healthkit doesn't return the data ordered by when the action was completed but when the data was actually saved
            // For example if the user has 3 step values:
            // 2016-08-11 157 steps (1)
            // 2016-08-19 257 steps (2)
            // 2016-08-18 65 steps (3)
            // that were inputed as (1) (3) (2) this is also the way they are going to be fetched
            // if you want the steps value from yesterday you have to manually search for it
            
            dispatch_async(dispatch_get_main_queue()) {
                var dailyAVG:Double = 0.0
                var i:Int = 0
                var last:Double = 0.0
                
                var dateAux: NSDate = startDate!
                var dateAux2: NSDate = startDate!
                for steps in results as! [HKQuantitySample]
                {
                    dailyAVG += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                    print(steps.startDate, i, steps.quantity.doubleValueForUnit(HKUnit.countUnit()))
                    i+=1
                    
                    // Getting today registered steps
                    switch steps.startDate.compare(dateAux) {
                    case .OrderedDescending:
                        print (dateAux, " < ", steps.startDate )
                        dateAux = steps.startDate
                        self.todayStepsValue = steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                    default:
                        break
                    }
        
                    self.todayStepsDate = String(dateAux)
                }
                
                print (">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
                
                for steps in results as! [HKQuantitySample]
                {
  
                    // Getting yesterday registered steps
                    switch steps.startDate.compare(dateAux2) { // find greatest value
                    case .OrderedDescending:
                        print ("*** ", steps.startDate, " > ", dateAux2)
                        switch steps.startDate.compare(dateAux) { // value less than today
                        case .OrderedAscending:
                            print (dateAux2, " < ", dateAux)
                            dateAux2 = steps.startDate
                            self.yesterdayStepsValue = steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                            print ("new value: ", dateAux2, " ", self.yesterdayStepsValue)
                        default : break
                        }
                    default: break
                    }
                    self.yesterdayStepsDate = String(dateAux2)
                }
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.yesterdayStepsDate = dateFormatter.stringFromDate(dateAux2)
                self.todayStepsDate = dateFormatter.stringFromDate(dateAux)
                
                self.averageStepsValue = dailyAVG/Double(i)
                print ("Yesterday steps: ", self.yesterdayStepsValue, " ", self.yesterdayStepsDate)
                print ("Today steps: ", self.todayStepsValue, " ", self.todayStepsDate)
                
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
        //secondVC.received = todayStepsValue
        //secondVC.rowPressed = pressed
        
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

    // Get data directly from openMRS (not calling node)
    func getObs() {
        
        let user = "nodejs"
        let password = "[]Uclactive15"
        
        let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
       Alamofire
        .request(.GET, "http://uclactiveserver.westeurope.cloudapp.azure.com:8080/openmrs/ws/fhir/Observation?date="+self.todayStepsDate+"T00:00:00", headers: headers)
        .responseJSON { response in
            var json = JSON(response.result.value!)
            var i = 0
            while (json["entry"][i]["resource"]["valueQuantity"]["value"] != nil) {
                print("Observation: ", json["entry"][i]["resource"]["code"]["coding"][0]["display"])
                print("Date: ", json["entry"][i]["resource"]["issued"])
                print("Value: ", json["entry"][i]["resource"]["valueQuantity"]["value"])
                i=i+1
            }
        }
    }
    
    func sendDatatoNode_Numerical(openMRS_uuid: String, snomed_code: String, loinc_code:String, concept_name:String, concept_unit:String, date: String, concept_value:AnyObject) {
        
        //**SEND DATA TO NODE SERVER**//
        let parameters = [
            "resourceType":"Observation",
            "code":[
                "coding":[
                    [
                        "system": self.coding_system_1,
                        "code":openMRS_uuid,
                        "display":concept_name
                    ],
                    [
                        "system": self.coding_system_2,
                        "code":snomed_code,
                        "display":concept_name
                    ],
                    [
                        "system": self.coding_system_3,
                        "code":loinc_code,
                        "display":concept_name
                    ]
                ]
            ],
            "valueQuantity":[
                "value":concept_value
            ],
            "appliesDateTime": date,
            "issued": date,
            "status":"final",
            "reliability":"ok",
            "subject":[
                "reference":"Patient/" + self.person_uuid
            ]
        ]
        
        Alamofire.request(.POST, "http://uclactiveserver.westeurope.cloudapp.azure.com:3001/sendmessage", parameters: parameters as! [String : AnyObject])
    }
    func sendDatatoNode_String(openMRS_uuid: String, snomed_code: String, loinc_code:String, concept_name:String, concept_unit:String, concept_value:AnyObject) {
        
        //**SEND DATA TO NODE SERVER**//
        let parameters = [
            "resourceType":"Observation",
            "code":[
                "coding":[
                    [
                        "system": self.coding_system_1,
                        "code":openMRS_uuid,
                        "display":concept_name
                    ],
                    [
                        "system": self.coding_system_2,
                        "code":snomed_code,
                        "display":concept_name
                    ],
                    [
                        "system": self.coding_system_3,
                        "code":loinc_code,
                        "display":concept_name
                    ]
                ]
            ],
            "valueString":[
                "value":concept_value
            ],
            "appliesDateTime":"2016-08-14T09:41:52",
            "issued":"2016-08-14T09:41:52.000",
            "status":"final",
            "reliability":"ok",
            "subject":[
                "reference":"Patient/" + self.person_uuid
            ]
        ]
        
        Alamofire.request(.POST, "http://uclactiveserver.westeurope.cloudapp.azure.com:3001/sendmessage", parameters: parameters)
    }
    
    // Sending data to Aidbox
    func sendData(observationType: String, snomedCode: String, observationDisplay: String, observationValue: String, observationUnit: String) {
        let scriptUrl = "https://uclactive.aidbox.io/fhir"
        let urlWithParams = scriptUrl + "/Observation?access_token=dce1ebc0-33ed-43f0-b471-24da1f532c85"
        let myUrl = NSURL(string: urlWithParams);
        
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST"
        
        // Get Current Date
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        let year =  components.year
        let month = components.month
        let day = components.day
        
        let today_date = String(day) + "/" + String(month) + "/" + String(year)
        
        // Daily Steps
        let jsonString = "{\"resourceType\":\"Observation\",\"identifier\":\"" + observationType + "\",\"code\":{\"coding\":[{\"system\":\"http://snomed.info/sct\",\"code\":\"" + snomedCode + "\",\"display\":\"" + observationDisplay + "\"}]},\"subject\":{\"reference\":\"Patient/87f95c58-b826-40d9-b7fb-69c600308e08\"},\"issued\":\"" + today_date + "\",\"valueQuantity\":{\"value\":\"" + observationValue + "\",\"unit\":\"" + observationUnit + "\"}}"
        
        //let jsonString = "json=[{\"str\":\"Hello\",\"num\":1},{\"str\":\"Goodbye\",\"num\":99}]"
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
        }
        task.resume()
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
    
    
    
    @IBAction func sync(sender: AnyObject) {
        // Send HTTP GET Request
        
        getObs()
        
        /*
        //**SEND DATA TO NODEjs**//
        //Send Daily Steps 
        
        if(self.todayStepsValue != 0.0) {
            sendDatatoNode_Numerical(self.daily_steps_uuid, snomed_code: self.daily_steps_snomed, loinc_code: self.daily_steps_loinc, concept_name: self.daily_steps_name, concept_unit: self.daily_steps_unit, date: self.todayStepsDate, concept_value: self.todayStepsValue)}
        
        //Send Average Steps
        if(self.averageStepsValue != 0.0) {
            sendDatatoNode_Numerical(self.average_steps_uuid, snomed_code: self.average_steps_snomed, loinc_code: self.average_steps_loinc, concept_name: self.average_steps_name, concept_unit: self.average_steps_unit, date: self.todayStepsDate ,concept_value: self.averageStepsValue)}
        
        //Send Active Energy
        if(self.todayActiveEnergy != 0.0) {
            sendDatatoNode_Numerical(self.active_energy_uuid, snomed_code: self.active_energy_snomed, loinc_code: self.active_energy_loinc, concept_name: self.active_energy_name, concept_unit: self.active_energy_unit, date: self.todayStepsDate, concept_value: self.todayActiveEnergy)}

        
        //Send Date of Birth
        if(self.birthdateValue != "Not enough data/Unauthorized") {
            sendDatatoNode_String(self.date_of_birth_uuid, snomed_code: self.date_of_birth_snomed, loinc_code: self.date_of_birth_loinc, concept_name: self.date_of_birth_name, concept_unit: self.date_of_birth_unit, concept_value: self.birthdateValue)}
        
        //Send Sex
        if(self.sexValue != "Not enough data/Unauthorized") {
            sendDatatoNode_String(self.sex_uuid, snomed_code: self.sex_snomed, loinc_code: self.sex_loinc, concept_name: self.sex_name, concept_unit: self.sex_unit, concept_value: self.sexValue)}
        
        //Send Blood Type
        if(self.bloodTypeValue != "Not enough data/Unauthorized") {
            sendDatatoNode_String(self.blood_type_uuid, snomed_code: self.blood_type_snomed, loinc_code: self.blood_type_loinc, concept_name: self.blood_type_name, concept_unit: self.blood_type_unit, concept_value: self.bloodTypeValue)}
        
        //Send Skin Type
        if(self.skinType != "Not enough data/Unauthorized") {
            sendDatatoNode_String(self.skin_type_uuid, snomed_code: self.skin_type_snomed, loinc_code: self.skin_type_loinc, concept_name: self.skin_type_name, concept_unit: self.skin_type_unit, concept_value: self.skinType)}
        
        
        //Send Height
        if(self.height != "Not enough data/Unauthorized") {
            sendDatatoNode_Numerical(self.height_uuid, snomed_code: self.height_snomed, loinc_code: self.height_loinc, concept_name: self.height_name, concept_unit: self.height_unit, concept_value: self.height!)}
            
        //Send Weight
        if(self.weightValue != "Not enough data/Unauthorized") {
            sendDatatoNode_Numerical(self.weight_uuid, snomed_code: self.weight_snomed, loinc_code: self.weight_loinc, concept_name: self.weight_name, concept_unit: self.weight_unit, concept_value: self.weightValue)}
        
        //Send BMI
        if(self.bmiValue != "Not enough data/Unauthorized" && self.bmiValue != "inf") {
            sendDatatoNode_Numerical(self.bmi_uuid, snomed_code: self.bmi_snomed, loinc_code: self.bmi_loinc, concept_name: self.bmi_name, concept_unit: self.bmi_unit, concept_value: self.bmiValue)}
        */
    }

}

