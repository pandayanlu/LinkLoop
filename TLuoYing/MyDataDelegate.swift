//
//  MyDataDelegate.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/20/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit

protocol MyDataDelegate {
    func didSelectRow(row: NSIndexPath, data: String)
}