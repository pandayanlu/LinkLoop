//
//  PostInfo.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/29/15.
//  Copyright © 2015 YeWangxing. All rights reserved.
//

import Foundation

class PostInfo {

    var postID: Int
    var title: String
    var style: Int
    var createdAt : String
    var postByID: Int
    var postByName : String
    var postByProfileImage: String
    var action: String
    var loveByUserID: Int
    var loveByName: String
    var loveByUserImageProfile: String
    var address: String
    var loveCount: Int
    var postImagePath: String
    var comments: String
    var commentCount: Int
    
    init(postID: Int, title: String, style: Int, createdAt: String, postByID: Int, postByName: String, postByProfileImage: String,
        action: String, loveByUserID: Int, loveByName: String, loveByUserImageProfile: String, address: String, postImagePath: String,
        loveCount: Int, comments: String, commentCount: Int){
        self.postID = postID
        self.title = title
        self.style = style
        self.createdAt = createdAt
        self.postByID = postByID
        self.postByName = postByName
        self.postByProfileImage = postByProfileImage
        self.action = action
        self.loveByUserID = loveByUserID
        self.loveByName = loveByName
        self.loveByUserImageProfile = loveByUserImageProfile
        self.address = address
        self.postImagePath = postImagePath
        self.loveCount = loveCount
        self.comments = comments
        self.commentCount = commentCount
    }
    
}