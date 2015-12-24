//
//  FirstViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/7/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit
import SwiftHTTP
import ImageLoader

class FirstViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var browseTableView: UITableView!
    var activityIndicator:UIActivityIndicatorView!
    var thumbQueue = NSOperationQueue()
    
    var postInfoList: [PostInfo] = [PostInfo]()
    let defaultsUserData = NSUserDefaults.standardUserDefaults()
    var email : String?
    var apiKey: String?
    var uuid: String?
    var startAt: Int = 0
    var admirerStartAt: Int = 0
    var refreshControl:UIRefreshControl!
    var refreshFunction : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.email = self.defaultsUserData.stringForKey(UserFields[0])!
        self.apiKey = self.defaultsUserData.stringForKey(UserFields[9])!
        self.uuid = self.defaultsUserData.stringForKey(UserFields[1])!
        
        self.browseTableView.delegate = self
        self.browseTableView.dataSource = self
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:
            UIActivityIndicatorViewStyle.Gray)
        activityIndicator.center=self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        self.queryAllPost()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refreshPost:", forControlEvents: UIControlEvents.ValueChanged)
        self.browseTableView.addSubview(refreshControl)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postInfoList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: PostInfoTableViewCell = tableView.dequeueReusableCellWithIdentifier("PostInfoTableViewCell") as! PostInfoTableViewCell
        let postInfo: PostInfo = self.postInfoList[indexPath.row]
        cell.setCell(postInfo, position: indexPath.row)
        
        // Cache & Asyc loading profile image
        var profileImageURL : String = ""
        let defaultProfileImage = UIImage(named: "defaultUser")!
        
        if(postInfo.loveByUserImageProfile.isEmpty){
            profileImageURL = postInfo.postByProfileImage
        } else {
            profileImageURL = postInfo.loveByUserImageProfile
        }
        if let cacheImage = ImageLoader.cache(profileImageURL) {
            cell.avatarImageView?.image = cacheImage
        } else {
            cell.avatarImageView?.image = defaultProfileImage
        }
        
        ImageLoader.load(profileImageURL).completionHandler { completedURL, image, error, cacheType in
            if cacheType == CacheType.None {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                
                dispatch_async(dispatch_get_main_queue(), {
                    if(image != nil) {
                        cell.avatarImageView?.layer.addAnimation(transition, forKey: nil)
                        cell.avatarImageView?.image = image
                    } else {
                        cell.avatarImageView?.image = defaultProfileImage
                    }
                })
            }
        }
        
        
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
        
        
        //Love button action
        cell.loveButton.tag = indexPath.row
        cell.loveButton.addTarget(self, action: "loveAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //Comment button action
        cell.commentButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: "commentAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.topView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.leftButton.tag = indexPath.row
        cell.leftButton.addTarget(self, action: "everyoneAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.rightButton.tag = indexPath.row
        cell.rightButton.addTarget(self, action: "admirerAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.postImageView!.tag = indexPath.row
        var imagePostTap = UITapGestureRecognizer(target: self, action: Selector("imagePostTap:"))
        cell.postImageView!.addGestureRecognizer(imagePostTap)
        cell.postImageView!.userInteractionEnabled = true
        
        cell.avatarImageView!.tag = indexPath.row
        var avatarImageTap = UITapGestureRecognizer(target: self, action: Selector("avatarImageTap:"))
        cell.avatarImageView!.addGestureRecognizer(avatarImageTap)
        cell.avatarImageView!.userInteractionEnabled = true
        
        //update topView Constraint
        if(indexPath.row > 0) {
            cell.topViewHeightConstraint.constant = 0
            cell.topView.updateConstraints()
        } else {
//            let constraintH = NSLayoutConstraint(item: cell.topView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 35)
//            cell.addConstraint(constraintH)
            
            cell.topViewHeightConstraint.constant = 35
            cell.topView.updateConstraints()

        }
        
        return cell
    }
    
    func imagePostTap(sender: UITapGestureRecognizer){
        let tappedView = sender.view as? UIImageView
        let row = tappedView!.tag
        let postid = postInfoList[row].postID
        let commentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CommentViewController") as! CommentViewController
        commentViewController.postID = postid
        commentViewController.postTitle = postInfoList[row].title
        commentViewController.postImageURL = postInfoList[row].postImagePath
        commentViewController.postComments = postInfoList[row].comments
        
        self.navigationController?.pushViewController(commentViewController, animated: true)
    }
    
    func avatarImageTap(sender: UITapGestureRecognizer){
        let tappedView = sender.view as? UIImageView
        let row = tappedView!.tag
        let postid = postInfoList[row].postID
        let userid = postInfoList[row].postByID
        
        let admireViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AdmireViewController") as! AdmireViewController
        
        self.navigationController?.pushViewController(admireViewController, animated: true)
    }
    
    func loveAction(sender: UIButton){
        
        let row = sender.tag
        let postid = postInfoList[row].postID
        let params: Dictionary<String, String> =
        [
            "email": self.email!,
            "uuid": self.uuid!,
            "postid": String(postid)
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
                            self.browseTableView.reloadData()
                        }
                        
                        if( response_code == 10){
                            var lovedPost = self.defaultsUserData.stringForKey(UserFields[10])
                            if(lovedPost != nil) {
                                lovedPost = lovedPost!.stringByReplacingOccurrencesOfString("[" + postid + "]", withString: "")
                                self.defaultsUserData.setObject(lovedPost!, forKey: UserFields[10])
                                 self.browseTableView.reloadData()
                            }
                        }
                    }
                    
                } catch {
                }
                
                return
            }
            
        })
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    
    func queryComments(row: Int, postID: Int) {
        let params: Dictionary<String, String> =
        [
            "email": self.email!,
            "postid": String(postID),
            "start_at": "0"
        ]
        
        let request = HTTPTask()
        let url = queryCommentURL + "/" + self.apiKey!
        
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
                print("comments response: \(str)")
                
                do {
                    let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(str!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    let response_code = Int(json["response_code"] as! String)
                    let response_msg = json["response_msg"] as! String
                    self.startAt = Int(json["load_end_at"] as! String)!
                    
                    print("response_code = \(response_code)")
                    print("response_msg = \(response_msg)")
                    print("load_end_at = \(self.startAt)")
                    
                    let commentList = json["comment_list"] as! String
                    if(commentList != "[]") {
                        self.postInfoList[row].comments = commentList
                    }
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        print("commentList = \(commentList)");

                    }
                } catch {
                    
                }
                
                return
            }
            
        })
        
    }
    
    func refreshPost(){
        if (self.refreshFunction == 0){
            self.queryAllPost()
        }
        
        if (self.refreshFunction == 1){
            self.queryAdmirerPost()
        }
    }
    
    func queryAllPost(){
        self.postInfoList.removeAll()
        let params: Dictionary<String, String> =
        [
            "email": self.email!,
            "start_at": String(self.startAt)
        ]
        
        let request = HTTPTask()
        let url = queryPostURL + "/" + self.apiKey!
        
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
                    self.startAt = Int(json["load_end_at"] as! String)!
                    
                    print("response_code = \(response_code)")
                    print("response_msg = \(response_msg)")
                    print("load_end_at = \(self.startAt)")
                    
                    let postList = json["post_list"] as! String
                    
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
                            
                            //load comment
                            self.queryComments(self.postInfoList.count - 1, postID : postID);
                            
                        }
                    }
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                      //table refresh
                        self.activityIndicator.stopAnimating()
                        self.browseTableView.reloadData()
                    }
                } catch {
                    //parse response data error
                }
                
                return
            }
            
        })
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
                            
                            //load comment
                            self.queryComments(self.postInfoList.count - 1, postID : postID);
                            
                        }
                    }
                    }
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //table refresh
                        self.activityIndicator.stopAnimating()
                        self.browseTableView.reloadData()
                    }
                    
                    
                    
                } catch {
                    //parse response data error
                }
                
                return
            }
            
        })
    }
    
    func everyoneAction(sender: UIButton){
        self.startAt = 0
        self.refreshFunction = 0
        queryAllPost()
    }
    
    func admirerAction(sender: UIButton){
        self.admirerStartAt = 0
        self.refreshFunction = 1
        queryAdmirerPost()
    }
    
    func commentAction(sender: UIButton){
        
        let row = sender.tag
        let postid = postInfoList[row].postID
            let commentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CommentViewController") as! CommentViewController
            commentViewController.postID = postid
            commentViewController.postTitle = postInfoList[row].title
            commentViewController.postImageURL = postInfoList[row].postImagePath
            commentViewController.postComments = postInfoList[row].comments
        
            self.navigationController?.pushViewController(commentViewController, animated: true)
        
        
//        let admireViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AdmireViewController") as! AdmireViewController
//        
//        self.navigationController?.pushViewController(admireViewController, animated: true)
        
        
    }
    

    
}

