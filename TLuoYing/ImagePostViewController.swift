//
//  ImagePostViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/20/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController, SSRadioButtonControllerDelegate , UITextFieldDelegate{

    var croppedImage : UIImage?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var optionButton1: SSRadioButton!
    
    @IBOutlet weak var optionButton2: SSRadioButton!
    @IBOutlet weak var optionButton3: SSRadioButton!
    let defaultsUserData = NSUserDefaults.standardUserDefaults()
    
    var stypeSelection: String = "";
    
    var radioButtonController: SSRadioButtonsController?
    var activityIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()){
            self.imageView.image = self.croppedImage
        }
        self.titleTextField.delegate = self
        radioButtonController = SSRadioButtonsController(buttons: optionButton1, optionButton2, optionButton3)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
        self.activityIndicatorView = ActivityIndicatorView(title: "Uploading...", center: self.view.center)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func postImage(sender: AnyObject) {
        
        if(titleTextField.text!.isEmpty){
            displayAlertMessage("Please input title")
            return
        }
        
        if(stypeSelection.isEmpty){
            displayAlertMessage("Please select a style")
            return
        }
        
        uploadPhoto()
        
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
    
    func displayAlertMessage(message: String){
        let alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func uploadPhoto() {
        
        let email = self.defaultsUserData.stringForKey(UserFields[0])!
        let uuid = self.defaultsUserData.stringForKey(UserFields[1])!
        let api_key = self.defaultsUserData.stringForKey(UserFields[9])!
        let title : String = titleTextField.text!
        let mystyle : String = stypeSelection
        
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        
        let request = createRequest(email, uuid: uuid, api_key: api_key, title: title, style: mystyle)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            
            if error != nil {
                let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hideView()
                
                    dispatch_async(dispatch_get_main_queue(), {
                    self.displayAlertMessage("response: \(str!)")
                    })
                }
                return
            }
            
            let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("update response: \(str)")
            
            let json: NSDictionary
            do {
                json = try NSJSONSerialization.JSONObjectWithData(str!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
                let response_code : Int? = Int(json["response_code"] as! String)
                let response_msg = json["response_msg"] as! String
            
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.removeView()
                        dispatch_async(dispatch_get_main_queue(), {
                            self.displayAlertCodeMessage(response_code!, message: response_msg)
                        })
                }
            } catch {
                
            }
        })
        
        task.resume()
        
    }
    
    func createRequest (email: String, uuid: String, api_key: String, title: String, style: String) -> NSURLRequest {
        
        let param = [
            "email" : email,
            "uuid" : uuid,
            "title" : title,
            "style" : style
        ]
        
        let boundary = generateBoundaryString()
        
        let url = NSURL(string: uploadURL + "/" + api_key + "/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "postFileImage", paths: ["upload"], boundary: boundary)
        
        return request
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, paths: [String]?, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 1)
        
        if paths != nil {
            for _ in paths! {
                let filename = "upload.jpg"
                let mimetype = "image/jpg"
                
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                body.appendData(imageData!)
                body.appendString("\r\n")
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    func displayAlertCodeMessage(code: Int, message: String){
        let alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action -> Void in
            if(code == 4){
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
        
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}
