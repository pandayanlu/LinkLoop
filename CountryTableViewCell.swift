//
//  CountryTableViewCell.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/20/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(country : String){
        self.countryLabel.text = country
    }

}
