//
//  Constants.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/13/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import Foundation

let loginURL = "http://yingluoapp.com/api/v1/au/login"
let registerURL = "http://yingluoapp.com/api/v1/au/register"
let uploadURL = "http://yingluoapp.com/api/v1/post/add"
let queryPostURL = "http://yingluoapp.com/api/v1/post/list-by-everyone"
let lovePostURL = "http://yingluoapp.com/api/v1/post/love"
let addCommentURL = "http://yingluoapp.com/api/v1/comment/add"
let queryCommentURL = "http://yingluoapp.com/api/v1/comment/list-comment-by-product"
let listAllLoveURL = "http://yingluoapp.com/api/v1/love/list-all-love-by-product"
let listByAdmirer = "http://yingluoapp.com/api/v1/post/list-by-admire"
let userProfile = "http://yingluoapp.com/api/v1/user/user-profile"
let mylovedPost = "http://yingluoapp.com/api/v1/love/list-all-love-by-this-user"

let UserFields : [String] =
[
    "email",
    "UUID",
    "firstname",
    "lastname",
    "birthday",
    "gender",
    "country",
    "style",
    "bucketid",
    "api_key",
    "loved_post",
    "userID"
]

extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// :param: string       The string to be added to the `NSMutableData`.
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
    
}

