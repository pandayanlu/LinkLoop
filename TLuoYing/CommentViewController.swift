//
//  CommentViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 10/11/15.
//  Copyright © 2015 YeWangxing. All rights reserved.
//

import UIKit
import SwiftHTTP
import ImageLoader

class CommentViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    var userID: String?
    var postID: Int = 0
    var postTitle : String?
    var postImageURL : String?
    var postComments: String?
    var keyboardHeight: CGFloat!
    let defaultsUserData = NSUserDefaults.standardUserDefaults()
    var email : String?
    var apiKey : String?
    var uuid : String?
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var loveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "COMMENTS"
        
        self.userID = self.defaultsUserData.stringForKey(UserFields[11])!
        self.email = self.defaultsUserData.stringForKey(UserFields[0])!
        self.apiKey = self.defaultsUserData.stringForKey(UserFields[9])!
        self.uuid = self.defaultsUserData.stringForKey(UserFields[1])!
        
        self.commentTextField.delegate = self
        self.postTitleLabel.text = postTitle
        
        if let cacheImage = ImageLoader.cache(self.postImageURL!) {
            self.postImageView?.image = cacheImage
        }
        
        ImageLoader.load(self.postImageURL!).completionHandler { completedURL, image, error, cacheType in
            if cacheType == CacheType.None {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                
                dispatch_async(dispatch_get_main_queue(), {
                    if(image != nil) {
                        self.postImageView?.layer.addAnimation(transition, forKey: nil)
                        self.postImageView?.image = image
                    }
                })
            }
        }
        
        self.showComments()
        self.listLoveByProduct()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                keyboardHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        let movement = (up ? -keyboardHeight : keyboardHeight)
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
    func showComments(){
        
        
        commentLabel.numberOfLines = 0
        commentLabel.text = ""
        
        if(!self.postComments!.isEmpty){
            let commentData = try! NSJSONSerialization.JSONObjectWithData(self.postComments!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            var comments : String = ""
            for index in 0...(commentData.count - 1)  {
                
                let commentInfo = commentData[index] as! NSDictionary
                let comment = commentInfo.valueForKey("msg") as! String
                let fname = commentInfo.valueForKey("fname") as! String
                let lname = commentInfo.valueForKey("lname") as! String
                
                comments = comments + fname + " " + lname + ": " + comment + "\n"
                
            }
            
            comments.removeAtIndex(comments.endIndex.predecessor())
            comments.removeAtIndex(comments.endIndex.predecessor())
            commentLabel.numberOfLines = commentData.count
            commentLabel.text = comments
            
        }
        
    }
    
    @IBAction func postButtion(sender: AnyObject) {
        
        if(self.commentTextField.text!.isEmpty){
            return
        }
        
        self.commentTextField.endEditing(true)
        let defaultsUserData = NSUserDefaults.standardUserDefaults()
        let email = defaultsUserData.stringForKey(UserFields[0])!
        let apiKey = defaultsUserData.stringForKey(UserFields[9])!
        let uuid = defaultsUserData.stringForKey(UserFields[1])!
        
        let params: Dictionary<String, String> =
        [
            "email": email,
            "uuid": uuid,
            "postid": String(postID),
            "message": self.commentTextField.text!
        ]
        
        
        let request = HTTPTask()
        let url = addCommentURL + "/" + apiKey
        request.POST(url, parameters: params, completionHandler: {(response: HTTPResponse) in
            
            if let _ = response.error {
                if let data = response.responseObject as? NSData {
                    let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print("update error response: \(str)")
                }
                self.commentTextField.text = ""
                return
            }
            
            if let data = response.responseObject as? NSData {
                let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                print("update response: \(str)")
                
                do {
                    let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(str!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    let response_code = Int(json["response_code"] as! String)
                    print("response_code=\(response_code)")
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let myName : String = self.defaultsUserData.stringForKey(UserFields[2])! + " " + self.defaultsUserData.stringForKey(UserFields[3])!
                        self.commentLabel.numberOfLines = self.commentLabel.numberOfLines + 1
                        if(self.commentLabel.numberOfLines == 1) {
                            self.commentLabel.text = myName + ": " + self.commentTextField.text!
                        } else {
                            self.commentLabel.text = myName + ": " + self.commentTextField.text! + "\n" + self.commentLabel.text!
                        }
                        self.commentTextField.text = ""
                    }
                    
                } catch {
                    self.commentTextField.text = ""
                }
                return
            }
            
        })
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.commentTextField.resignFirstResponder()
        return true
    }
    
    func listLoveByProduct(){
        
        let params: Dictionary<String, String> =
        [
            "email": self.email!,
            "postid": String(self.postID)
        ]
        
        let request = HTTPTask()
        let url = listAllLoveURL + "/" + self.apiKey!
        
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
                    
                    print("response_code = \(response_code)")
                    print("response_msg = \(response_msg)")
                    
                    let loveList = json["love_list"] as! String
                    print("love_list = \(loveList)")
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        if(loveList.rangeOfString(self.userID! + ",") != nil){
                            self.loveButton.setImage(UIImage(named: "love"), forState: UIControlState.Normal)
                        }else{
                            self.loveButton.setImage(UIImage(named: "nolove"), forState: UIControlState.Normal)
                        }
                    }
                    
                } catch {
                    //parse response data error
                }
                
                return
            }
            
        })
        
    }
    
    
    @IBAction func loveAction(sender: AnyObject) {
        
        let params: Dictionary<String, String> =
        [
            "email": self.email!,
            "uuid": self.uuid!,
            "postid": String(self.postID)
        ]
        
        let request = HTTPTask()
        let url = lovePostURL + "/" + self.apiKey!
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
                    let postid = json["postid"] as! String
                    
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        if( response_code == 9){
                            var lovedPost = self.defaultsUserData.stringForKey(UserFields[10])
                            if(lovedPost != nil) {
                                lovedPost = lovedPost!.stringByReplacingOccurrencesOfString("[" + postid + "]", withString: "")
                                lovedPost = lovedPost! + "[" + postid + "]"
                            } else {
                                lovedPost = "[" + postid + "]"
                            }
                            
                            self.defaultsUserData.setObject(lovedPost, forKey: UserFields[10])
                            self.loveButton.setImage(UIImage(named: "love"), forState: UIControlState.Normal)

                        }
                        
                        if( response_code == 10){
                            var lovedPost = self.defaultsUserData.stringForKey(UserFields[10])
                            if(lovedPost != nil) {
                                lovedPost = lovedPost!.stringByReplacingOccurrencesOfString("[" + postid + "]", withString: "")
                                self.defaultsUserData.setObject(lovedPost!, forKey: UserFields[10])
                                self.loveButton.setImage(UIImage(named: "nolove"), forState: UIControlState.Normal)
                            }
                        }
                    }
                    
                } catch {
                }
                
                return
            }
            
        })
        
    }
    

}
