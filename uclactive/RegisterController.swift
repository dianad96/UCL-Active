//
//  RegisterController.swift
//  uclactive
//
//  Created by DianaD on 17/08/2016.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class RegisterController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var postalcode: UITextField!
    @IBOutlet weak var birthdate: UITextField!
    @IBOutlet weak var sex: UITextField!
    @IBOutlet weak var familyName: UITextField!
    @IBOutlet weak var givenName: UITextField!
    let identif: String = String(arc4random_uniform(5000))
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        var pickerView = UIPickerView()
        pickerView.delegate = self
        sex.inputView = pickerView
        
        /*
         NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
         */
    }
    
    //Looks for single or multiple taps.
    @IBAction func textFieldEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(RegisterController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateFormat = "yyyy-MM-dd"
        birthdate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    var pickOption = ["male", "female"]
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return pickOption[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sex.text = pickOption[row]
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
            else {
                
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
            else {
                
            }
        }
    }
    
    @IBAction func sendData(sender: AnyObject) {
        print(self.givenName.text)
        print(self.familyName.text)
        print(self.sex.text)
        print(self.birthdate.text)
        print(self.postalcode.text)
        print(self.identif)
        
        let givenName: String = self.givenName.text!
        let familyName: String = self.familyName.text!
        let sex: String = self.sex.text!
        let birthdate: String = self.birthdate.text!
        let postalcode: String = self.postalcode.text!
        
        //**SEND DATA TO NODE SERVER**//
        let parameters = [
            "resourceType": "Patient",
            "identifier": [
                [
                    "use":"usual",
                    "system":"Old Identification Number",
                    "value":self.identif
                ]
            ],
            "name": [
                [
                    "use":"usual",
                    "family":[
                        familyName
                    ],
                    "given":[
                        givenName
                    ]
                ]
            ],
            "gender":sex,
            "birthdate":birthdate,
            "deceasedBoolean":"false",
            "address":[
                [
                    "use":"home",
                    "postal code":postalcode,
                    "country":"United Kingdom"
                ]
            ],
            "active":"true"
            
        ]
        
        print (parameters)
        
        Alamofire.request(.POST, "http://uclactiveserver.westeurope.cloudapp.azure.com:3001/createUser", parameters: parameters as! [String : AnyObject])
    }
    
}
