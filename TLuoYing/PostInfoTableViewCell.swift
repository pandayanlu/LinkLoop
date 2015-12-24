//
//  PostInfoTableViewCell.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/29/15.
//  Copyright © 2015 YeWangxing. All rights reserved.
//

import UIKit

class PostInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var topView: UIView!

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentLabelConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(postInfo : PostInfo, position: Int){
        
        print("position = \(position)")
        
        if(position > 0) {
            leftButton.hidden = true
            rightButton.hidden = true
        }else{
            leftButton.hidden = false
            rightButton.hidden = false
        }
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.clipsToBounds = true
        
        if(postInfo.loveByUserImageProfile.isEmpty){
            var createAt = postInfo.createdAt
            createAt.removeAtIndex(createAt.endIndex.predecessor())
            createAt.removeAtIndex(createAt.endIndex.predecessor())
            statusLabel.text = postInfo.action + " @" + createAt
            nameLabel.text = postInfo.postByName
            
        } else {
            statusLabel.text = postInfo.action + " just now"
            nameLabel.text = postInfo.loveByName
        }
        
        addressLabel.text = postInfo.address
        
        var numberStr : String = ""
        
        if( postInfo.loveCount == 1) {
            numberStr = String(postInfo.loveCount) + " Love"
        }
        if( postInfo.loveCount > 1) {
            numberStr = String(postInfo.loveCount) + " Loves"
        }
        
        if(postInfo.commentCount  == 1 ) {
            numberStr = numberStr + "    " + String(postInfo.commentCount) + " Comment"
        }
        if(postInfo.commentCount  > 1 ) {
            numberStr = numberStr + "    " + String(postInfo.commentCount) + " Comments"
        }
        
        numberLabel.text = numberStr
        titleLabel.text = postInfo.title
        
        let lovedPost = NSUserDefaults.standardUserDefaults().stringForKey(UserFields[10])
        if(lovedPost != nil){
            if(lovedPost!.containsString("[" + String(postInfo.postID) + "]")){
                loveButton.setImage(UIImage(named: "love"), forState: UIControlState.Normal)
            } else {
                loveButton.setImage(UIImage(named: "nolove"), forState: UIControlState.Normal)
            }
        } else {
            loveButton.setImage(UIImage(named: "nolove"), forState: UIControlState.Normal)
        }
        
        //comments label
        
        if(!postInfo.comments.isEmpty){
            let commentData = try! NSJSONSerialization.JSONObjectWithData(postInfo.comments.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            var comments : String = ""
            for index in 0...(commentData.count - 1)  {
                
                let commentInfo = commentData[index] as! NSDictionary
                let comment = commentInfo.valueForKey("msg") as! String
                let fname = commentInfo.valueForKey("fname") as! String
                let lname = commentInfo.valueForKey("lname") as! String
                
                comments = comments + fname + " " + lname + ": " + comment + "\n"
                
            }
            
            commentsLabel.numberOfLines = 0
            comments.removeAtIndex(comments.endIndex.predecessor())
            comments.removeAtIndex(comments.endIndex.predecessor())
            commentsLabel.numberOfLines = commentData.count
            commentsLabel.text = comments

            let commentHeight : CGFloat = CGFloat (20 * commentData.count)
            commentLabelConstraint.constant = commentHeight
            self.updateConstraints()
            
        }
        else {
            commentsLabel.numberOfLines = 0
            commentsLabel.text = ""
            commentLabelConstraint.constant = 20
            self.updateConstraints()
        }
    
    }
    
    @IBAction func leftButtonAction(sender: AnyObject) {
        leftButton.titleLabel!.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        rightButton.titleLabel!.font = UIFont(name:"HelveticaNeue", size: 16.0)
    }
    
    
    
    @IBAction func rightButtonAction(sender: AnyObject) {
        rightButton.titleLabel!.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        leftButton.titleLabel!.font = UIFont(name:"HelveticaNeue", size: 16.0)
    }
    
}
