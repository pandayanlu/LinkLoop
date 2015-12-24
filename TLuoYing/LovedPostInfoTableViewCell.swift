//
//  LovedPostInfoTableViewCell.swift
//  TLuoYing
//
//  Created by YeWangxing on 11/29/15.
//  Copyright © 2015 YeWangxing. All rights reserved.
//

import UIKit

class LovedPostInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var postImageViewRight: UIImageView!
    @IBOutlet weak var loveButtonRight: UIButton!
    @IBOutlet weak var numberLabelRight: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(postInfo : PostInfo, position: Int){
        
        print("position = \(position)")
        
        var numberStr : String = ""
        
        if( postInfo.loveCount == 1) {
            numberStr = String(postInfo.loveCount) + " Love"
        }
        if( postInfo.loveCount > 1) {
            numberStr = String(postInfo.loveCount) + " Loves"
        }
        
        numberLabel.text = numberStr
        
        
    }
    
    func setRightCell(postInfo : PostInfo, position: Int){
        
        print("position = \(position)")
        
        var numberStr : String = ""
        
        if( postInfo.loveCount == 1) {
            numberStr = String(postInfo.loveCount) + " Love"
        }
        if( postInfo.loveCount > 1) {
            numberStr = String(postInfo.loveCount) + " Loves"
        }
        
        numberLabelRight.text = numberStr
        
        
    }
}
