//
//  CustomView.swift
//  uclactive
//
//  Created by Diana Darie on 7/19/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit

class CustomView: UIView {
    
    override func awakeFromNib() {
        layer.cornerRadius = 4.0
        //        layer.shadowColor = UIColor(red: CGFloat(157.0) / 255.0, green: CGFloat(157.0) / 255.0, blue: CGFloat(157.0) / 255.0, alpha: 0.9).CGColor
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 4.0)
    }
    
}

