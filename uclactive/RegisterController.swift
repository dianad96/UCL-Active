//
//  RegisterController.swift
//  uclactive
//
//  Created by DianaD on 17/08/2016.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import Foundation
import UIKit

class RegisterController: UIViewController{
    @IBOutlet weak var postalcode: UITextField!
    @IBOutlet weak var birthdate: UITextField!
    @IBOutlet weak var sex: UITextField!
    @IBOutlet weak var familyName: UITextField!
    @IBOutlet weak var givenName: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
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
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        birthdate.text = dateFormatter.stringFromDate(sender.date)
        
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

    }
    
 }
