//
//  ProfileViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/26/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit
import SwiftHTTP
import ImageLoader

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var postInfoList: [PostInfo] = [PostInfo]()
    var email : String?
    var apiKey: String?
    var uuid: String?
    var userID : String?
    
    var startAt: Int = 0
    var admirerStartAt: Int = 0
    let defaultsUserData = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var browseTableView: UITableView!
    @IBOutlet weak var nameLabelRight: UILabel!
    @IBOutlet weak var loveNumberLabel: UILabel!
    @IBOutlet weak var admirerNumberLabel: UIButton!
    @IBOutlet weak var admiringNumberLabel: UIButton!
    
    @IBOutlet weak var lovesButton: UIButton!
    @IBOutlet weak var photosButton: UIButton!
    
    @IBOutlet weak var photoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.email = self.defaultsUserData.stringForKey(UserFields[0])!
        self.apiKey = self.defaultsUserData.stringForKey(UserFields[9])!
        self.uuid = self.defaultsUserData.stringForKey(UserFields[1])!
        self.userID = self.defaultsUserData.stringForKey(UserFields[11])!
        
        self.nameLabelRight.text =
            self.defaultsUserData.stringForKey(UserFields[2])!
            + " "
            + self.defaultsUserData.stringForKey(UserFields[3])!
        
        self.browseTableView.delegate = self
        self.browseTableView.dataSource = self
        
        self.queryUserProfile()
        self.queryAdmirerPost()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func logoutAction(sender: AnyObject) {
       self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = self.postInfoList.count / 2
        if(self.postInfoList.count % 2 > 0) {
            count = count + 1
        }
        
        return count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: LovedPostInfoTableViewCell = tableView.dequeueReusableCellWithIdentifier("LovedPostInfoTableViewCell") as! LovedPostInfoTableViewCell
        
        var postInfo: PostInfo = self.postInfoList[indexPath.row * 2]
        cell.setCell(postInfo, position: indexPath.row * 2)
        
        // Cache & Asyc loading post image
        let postImageURL = postInfo.postImagePath
        let defaultPostImage = UIImage(named: "browse_example.png")!
        
        if let cacheImage = ImageLoader.cache(postImageURL) {
            cell.postImageView?.image = cacheImage
        } else {
            cell.postImageView?.image = defaultPostImage
        }
        
        ImageLoader.load(postImageURL).completionHandler { completedURL, image, error, cacheType in
            if cacheType == CacheType.None {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                
                dispatch_async(dispatch_get_main_queue(), {
                    if(image != nil) {
                        cell.postImageView?.layer.addAnimation(transition, forKey: nil)
                        cell.postImageView?.image = image
                    } else {
                        cell.postImageView?.image = defaultPostImage
                    }
                })
            }
        }
        
        if(indexPath.row * 2 + 1 < postInfoList.count) {
            postInfo = self.postInfoList[indexPath.row * 2 + 1]
            cell.setRightCell(postInfo, position: indexPath.row * 2 + 1)
            cell.loveButtonRight.hidden = false
            
            // Cache & Asyc loading post image
            let postImageURL = postInfo.postImagePath
            let defaultPostImage = UIImage(named: "browse_example.png")!
            
            if let cacheImage = ImageLoader.cache(postImageURL) {
                cell.postImageViewRight?.image = cacheImage
            } else {
                cell.postImageViewRight?.image = defaultPostImage
            }
            
            ImageLoader.load(postImageURL).completionHandler { completedURL, image, error, cacheType in
                if cacheType == CacheType.None {
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.type = kCATransitionFade
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if(image != nil) {
                            cell.postImageViewRight?.layer.addAnimation(transition, forKey: nil)
                            cell.postImageViewRight?.image = image
                        } else {
                            cell.postImageViewRight?.image = defaultPostImage
                        }
                    })
                }
            }
            
        } else {
            cell.loveButtonRight.hidden = true
        }
        
        return cell
    }
    
    
    
    func queryAdmirerPost(){
        self.postInfoList.removeAll()
        let params: Dictionary<String, String> =
        [
            "email": self.email!,
            "start_at": String(self.admirerStartAt)
        ]
        
        let request = HTTPTask()
        let url = listByAdmirer + "/" + self.apiKey!
        
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
                    self.admirerStartAt = Int(json["load_end_at"] as! String)!
                    
                    print("response_code = \(response_code)")
                    print("response_msg = \(response_msg)")
                    print("load_end_at = \(self.admirerStartAt)")
                    
                    let postList = json["post_list"] as! String
                    
                    if(postList != "[]") {
                        do {
                            let postData = try! NSJSONSerialization.JSONObjectWithData(postList.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                            
                            for index in 0...(postData.count - 1)  {
                                
                                let postInfo = postData[index] as! NSDictionary
                                let postID = postInfo.valueForKey("postid") as! Int
                                let title = postInfo.valueForKey("title") as! String
                                let postImagePath = postInfo.valueForKey("post_image_path") as! String
                                let loveCount = postInfo.valueForKey("love_count") as! Int
                                let commentCount = postInfo.valueForKey("comment_count") as! Int
                                let postByID = postInfo.valueForKey("postByID") as! Int
                                let postByName = postInfo.valueForKey("postByName") as! String
                                let postByProfileImage = postInfo.valueForKey("postByProfileImage") as! String
                                let action = postInfo.valueForKey("action") as! String
                                let loveByUserID = postInfo.valueForKey("loveByUserID") as! Int
                                let loveByName = postInfo.valueForKey("loveByName") as! String
                                let loveByUserImageProfile = postInfo.valueForKey("loveByUserImageProfile") as! String
                                let createdAt = postInfo.valueForKey("created_at") as! String
                                let style = postInfo.valueForKey("style") as! Int
                                
                                var address : String = ""
                                //address = postInfo.valueForKey("location") as! String
                                
                                let post = PostInfo(postID: postID, title: title, style: style, createdAt: createdAt, postByID: postByID, postByName: postByName, postByProfileImage: postByProfileImage, action: action, loveByUserID: loveByUserID, loveByName: loveByName, loveByUserImageProfile: loveByUserImageProfile, address: address, postImagePath: postImagePath, loveCount: loveCount, comments: "", commentCount: commentCount)
                                
                                self.postInfoList.append(post)
                                
                            }
                            
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.loveNumberLabel.text = String(postData.count)
                            })
                        }
                    }
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //table refresh
                        self.browseTableView.reloadData()
                    }
                    
                    
                    
                } catch {
                    //parse response data error
                }
                
                return
            }
            
        })
    }
    
    func queryUserProfile(){
        
        let url = userProfile + "/" + self.apiKey!
        
        let params: Dictionary<String, String> =
        [
            "email": self.email!,
            "user_id": self.userID!
        ]
        
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
                    
                    let user_detail = json["user_detail"] as! String
                    
                    let user_love_list = json["user_love_list"] as! String
                    
                    print("user_love_list = \(user_love_list) \(user_detail)")

//                    let totalAdmirer = json["totalAdmirer"] as! String
//                    let totalAdmiring = json["totalAdmiring"] as! String
                    
                    if(user_love_list != "[]") {
                        do {
                            let postData = try! NSJSONSerialization.JSONObjectWithData(user_love_list.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                            
                            for index in 0...(postData.count - 1)  {
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                //self.loveNumberLabel.text = String(postData.count)
//                                self.admirerNumberLabel.titleLabel?.text = totalAdmirer + " Admirers"
//                                
//                                self.admiringNumberLabel.titleLabel?.text = totalAdmiring + " Admirings"
                            })
                            
                        }
                    }
                } catch {
                }
                
                return
            }
            
        })
    }
    
    
    
    @IBAction func lovesButtonAcition(sender: AnyObject) {
        self.queryAdmirerPost()
        
        lovesButton.titleLabel!.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        photosButton.titleLabel!.font = UIFont(name:"HelveticaNeue", size: 16.0)
        
    }
    
    @IBAction func photosButtonAction(sender: AnyObject) {
        self.queryMyLovedPost()
        photosButton.titleLabel!.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        lovesButton.titleLabel!.font = UIFont(name:"HelveticaNeue", size: 16.0)
        
    }
    
    
    func queryMyLovedPost(){
        self.postInfoList.removeAll()
        let params: Dictionary<String, String> =
        [
            "email": self.email!,
            "start_at": String(self.admirerStartAt)
        ]
        
        let request = HTTPTask()
        let url = mylovedPost + "/" + self.apiKey!
        
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
                    self.admirerStartAt = 0
                    
                    print("response_code = \(response_code)")
                    print("response_msg = \(response_msg)")
                    
                    let postList = json["love_list_by_current_user"] as! String
                    
                    if(postList != "[]") {
                        do {
                            let postData = try! NSJSONSerialization.JSONObjectWithData(postList.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                            
                            for index in 0...(postData.count - 1)  {
                                
                                let postInfo = postData[index] as! NSDictionary
                                let postID = postInfo.valueForKey("postID") as! Int
                                let title = postInfo.valueForKey("title") as! String
                                let postImagePath = postInfo.valueForKey("postImage") as! String
                                let loveCount = 1
                                let commentCount = 0
                                let postByID = 0
                                let postByName = ""
                                let postByProfileImage = ""
                                let action = ""
                                let loveByUserID = 0
                                let loveByName = ""
                                let loveByUserImageProfile = ""
                                let createdAt = "2015-11-01 01:59:54.0"
                                let style = 0
                                
                                var address : String = ""
                                //address = postInfo.valueForKey("location") as! String
                                
                                let post = PostInfo(postID: postID, title: title, style: style, createdAt: createdAt, postByID: postByID, postByName: postByName, postByProfileImage: postByProfileImage, action: action, loveByUserID: loveByUserID, loveByName: loveByName, loveByUserImageProfile: loveByUserImageProfile, address: address, postImagePath: postImagePath, loveCount: loveCount, comments: "", commentCount: commentCount)
                                
                                self.postInfoList.append(post)
                                
                            }
                            
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.photoLabel.text = String(postData.count)
                            })
                        }
                    }
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //table refresh
                        self.browseTableView.reloadData()
                    }
                    
                    
                    
                } catch {
                    //parse response data error
                }
                
                return
            }
            
        })
    }
    
}
