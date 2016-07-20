//
//  AvatarImageView.swift
//  uclactive
//
//  Created by Diana Darie on 7/20/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit

class AvatarImageView: UIImageView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 3.0
    }
}

