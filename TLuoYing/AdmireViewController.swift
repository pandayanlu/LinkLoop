//
//  AdmireViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 10/11/15.
//  Copyright © 2015 YeWangxing. All rights reserved.
//

import UIKit
import ImageLoader

class AdmireViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView1: UIImageView!
    @IBOutlet weak var postImageView2: UIImageView!
    
    let imageURL1 = "http://d25ravoyatajqb.cloudfront.net/users/yl313I21/images/p21_s1443423560960.jpg"
    let imageURL2 = "http://d25ravoyatajqb.cloudfront.net/users/yl313I21/images/p21_s1443334119718.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        let defaultProfileImage = UIImage(named: "defaultUser")!
        profileImageView.image = defaultProfileImage
        
        self.title = "FANFAN"
        
        if let cacheImage1 = ImageLoader.cache(imageURL1) {
            postImageView1.image = cacheImage1
        }
        
        ImageLoader.load(imageURL1).completionHandler {completedURL, image, error, cacheType in
            if cacheType == CacheType.None {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                
                dispatch_async(dispatch_get_main_queue(), {
                    if(image != nil) {
                        self.postImageView1.layer.addAnimation(transition, forKey: nil)
                        self.postImageView1.image = image
                    }
                })
            }
        }
        
        if let cacheImage2 = ImageLoader.cache(imageURL2) {
            postImageView2.image = cacheImage2
        }
        
        ImageLoader.load(imageURL2).completionHandler {completedURL, image, error, cacheType in
            if cacheType == CacheType.None {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = kCATransitionFade
                
                dispatch_async(dispatch_get_main_queue(), {
                    if(image != nil) {
                        self.postImageView2.layer.addAnimation(transition, forKey: nil)
                        self.postImageView2.image = image
                    }
                })
            }
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

}
