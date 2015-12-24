//
//  ReservedViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/8/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit

class ReservedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    override func viewDidAppear(animated: Bool) {
        self.performSegueWithIdentifier("loginView", sender: self)
    }

}
