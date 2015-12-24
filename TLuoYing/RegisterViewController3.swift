//
//  RegisterViewController3.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/8/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit
import SwiftHTTP


class RegisterViewController3: UIViewController, SSRadioButtonControllerDelegate {

    @IBOutlet weak var optionButton1: SSRadioButton!
    @IBOutlet weak var optionButton2: SSRadioButton!
    @IBOutlet weak var optionButton3: SSRadioButton!
    
    var fname: String!
    var lname: String!
    var email: String!
    var password: String!
    var dob: String!
    var gender: String!
    var country: String!
    
    var stypeSelection: String = "";
    
    var radioButtonController: SSRadioButtonsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(fname)
        print(lname)
        print(email)
        print(password)
        print(dob)
        print(gender)
        print(country)
        
        radioButtonController = SSRadioButtonsController(buttons: optionButton1, optionButton2, optionButton3)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didSelectButton(aButton: UIButton?) {

        if(aButton == optionButton1){
            print("1")
            stypeSelection = "1"
        }
        
        if(aButton == optionButton2){
            print("2")
            stypeSelection = "2"
        }
        
        if(aButton == optionButton3){
            print("3")
            stypeSelection = "3"
        }
        
        
    }
    
    @IBAction func signupButtonTapped(sender: AnyObject) {
        if(stypeSelection.isEmpty){
            displayAlertMessage("Please select a stype")
            return
        }
        
        
        let params: Dictionary<String, String> =
        [
            "fname": self.fname,
            "lname": self.lname,
            "email": self.email,
            "password" : self.password,
            "dob" : self.dob,
            "gender" : self.gender,
            "country" : self.country,
            "style" : self.stypeSelection
        
        ]

        register(params, url: registerURL)
        
    }
    
    func displayAlertMessage(message: String){
        let alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayAlertCodeMessage(code: Int, message: String){
        let alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action -> Void in
            if(code == 1){
//                self.dismissViewControllerAnimated(true, completion: nil)


                
                
         let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController

          self.presentViewController(loginViewController, animated: true, completion: nil)
                
            }
        }
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func register(params : Dictionary<String, String>, url : String){
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
                
                let response_code : Int = Int(json["response_code"] as! String)!
                let response_msg = json["response_msg"] as! String
                
                self.displayAlertCodeMessage(response_code, message: response_msg)
                
                }
                catch{
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
        } catch {
            
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
                if let parseJSON = json {
                    let response_code = parseJSON["response_code"] as! Int
                    let response_msg = parseJSON["response_msg"] as! String
                    
                    self.displayAlertCodeMessage(response_code, message: response_msg)
                }
                else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
            
            
        })
        
        task.resume()
    }
}
