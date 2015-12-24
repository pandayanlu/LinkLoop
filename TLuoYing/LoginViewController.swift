//
//  LoginViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/8/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit
import SwiftHTTP

class LoginViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    let defaultsUserData = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailText.delegate = self
        self.passwordText.delegate = self

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        let email : String = self.emailText.text!
        let password: String = self.passwordText.text!
        
        if(email.isEmpty || password.isEmpty){
            self.displayAlertMessage("You need to enter all the fields!")
            return
        }
        
        let params: Dictionary<String, String> =
        [
            "email": email,
            "password": password
        ]

        login(params, url: loginURL)
    }
    
    func login(params : Dictionary<String, String>, url : String){
        let request = HTTPTask()
        request.POST(url, parameters: params, completionHandler: {(response: HTTPResponse) in
            
            if let _ = response.error {
                if let data = response.responseObject as? NSData {
                    let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print("update error response: \(str)")
                }
                return
            }
            if let data = response.responseObject as? NSData {
                let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                print("update response: \(str)")
                
                do {
                let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(str!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let response_code = Int(json["response_code"] as! String)
                let response_msg = json["response_msg"] as! String
                
                let uuid = json["uuid"] as! String
                let bucketid = json["bucketid"] as! String
                let api_key = json["api_key"] as! String
                let userID = json["userid"] as! String
                let fname = json["fname"] as! String
                let lname = json["lname"] as! String
                
                self.defaultsUserData.setObject(self.emailText.text, forKey: UserFields[0])
                self.defaultsUserData.setObject(uuid, forKey: UserFields[1])
                self.defaultsUserData.setObject(bucketid, forKey: UserFields[8])
                self.defaultsUserData.setObject(api_key, forKey: UserFields[9])
                self.defaultsUserData.setObject(userID, forKey: UserFields[11])
                    
                self.defaultsUserData.setObject(fname, forKey: UserFields[2])
                self.defaultsUserData.setObject(lname, forKey: UserFields[3])
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.displayAlertCodeMessage(response_code!, message: response_msg)
                }
                
                } catch {
                }
                
                return
            }
            
        })
    }
    
    
    func post(params : Dictionary<String, String>, url : String) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    let response_code = parseJSON["response_code"] as! Int
                    let response_msg = parseJSON["response_msg"] as! String
                    
                    print("response_msg = \(response_msg)")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.displayAlertCodeMessage(response_code, message : response_msg)
                    }
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                }
                
            } catch {
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
        })
            task.resume()
        } catch {
            
        }
        
        
    }
    
    
    func displayAlertCodeMessage(code: Int, message: String){
        let alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action -> Void in
            if(code == 2){
                self.passwordText.text = ""
                self.emailText.text = ""
                self.performSegueWithIdentifier("mainView", sender: self)
            }
        }
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayAlertMessage(message: String){
        let alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
