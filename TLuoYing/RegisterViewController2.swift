//
//  RegisterViewController2.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/8/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit

class RegisterViewController2: UIViewController, UITextFieldDelegate , MyDataDelegate{

    @IBOutlet weak var dobText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var countryText: UITextField!
    
    var backFromNext : Bool = false
    var countryCode : String = ""
    var fname: String!
    var lname: String!
    var email: String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("I am register page 2 - viewDidLoad")
        print(fname)
        print(lname)
        print(email)
        print(password)
        
        self.dobText.delegate = self
        self.genderText.delegate = self
        self.countryText.delegate = self
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        

        
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {

        var dob = self.dobText.text
        var gender = self.genderText.text
        var country = self.countryText.text
        
        if(dob!.isEmpty || gender!.isEmpty || country!.isEmpty ){
            self.displayAlertMessage("Please enter all the fields!")
            return
        }
        
        if(self.genderText.text!.uppercaseString == "MALE" || self.genderText.text!.uppercaseString == "FEMALE") {
        } else {
            self.displayAlertMessage("Please enter correct gender!")
            return
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.dateFromString(dob!)
        
        
        self.backFromNext = true
        self.performSegueWithIdentifier("registerView3", sender: self)
        
    }
    
    
    func displayAlertMessage(message: String){
        var alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("I am register page 2 - viewWillAppear")
        if(self.backFromNext) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if(segue.identifier == "registerView3") {
            
            var svc = segue!.destinationViewController as!RegisterViewController3
            svc.fname = self.fname
            svc.lname = self.lname
            svc.email = self.email
            svc.password = self.password
            svc.dob = self.dobText.text
            if(self.genderText.text!.uppercaseString == "MALE") {
                svc.gender = "m"
            } else {
                svc.gender = "f"
            }
            if(countryCode.isEmpty) {
                svc.country = self.countryText.text
            } else {
                svc.country = countryCode
            }
            
            print("svc.country = \(svc.country)")
            
        }
    }

    @IBAction func selectACountry(sender: AnyObject) {
        
        let countryTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CountryTableViewController") as! CountryTableViewController
        countryTableViewController.countryDataDelegate = self
        self.presentViewController(countryTableViewController, animated: true, completion: nil)
        
    }
    
    func didSelectRow(row: NSIndexPath, data: String){
        print("I am register page 2 - didSelectRow \(data)")
        let countries = data.componentsSeparatedByString(":") as [String]
        countryCode = countries[0]
        countryText.text = countries[1]
    }
    
}
