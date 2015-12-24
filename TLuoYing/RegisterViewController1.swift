//
//  RegisterViewController1.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/8/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit

class RegisterViewController1: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var repeatPasswordText: UITextField!
    var backFromNext : Bool = false
    let defaultsUserData = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameText.delegate = self
        self.lastNameText.delegate = self
        self.emailText.delegate = self
        self.passwordText.delegate = self
        self.repeatPasswordText.delegate = self
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        
        let fname = self.firstNameText.text
        let lname = self.lastNameText.text
        let email = self.emailText.text
        let password = self.passwordText.text
        let repeatPassword =  self.repeatPasswordText.text

        if(!self.isValidEmail(email!)){
            self.displayAlertMessage("Please enter the correct email address!")
            return
        }
        
        if(fname!.isEmpty || lname!.isEmpty || email!.isEmpty || password!.isEmpty){
            self.displayAlertMessage("Please enter all the fields!")
            return
        }
        
        if(password != repeatPassword) {
            self.displayAlertMessage("Passwords do not match!")
            return
        }
        
        self.defaultsUserData.setObject(self.firstNameText.text, forKey: UserFields[2])
        self.defaultsUserData.setObject(self.lastNameText.text, forKey: UserFields[3])
        
        self.performSegueWithIdentifier("registerView2", sender: self)
        self.backFromNext = true

    }
    
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func displayAlertMessage(message: String){
        var alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("I am register page 1")
        if(self.backFromNext) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if(segue.identifier == "registerView2") {
            
            var svc = segue!.destinationViewController as!RegisterViewController2
            svc.fname = self.firstNameText.text
            svc.lname = self.lastNameText.text
            svc.email = self.emailText.text
            svc.password = self.passwordText.text
            
        }
    }

}
