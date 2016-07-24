//
//  DetailController.swift
//  uclactive
//
//  Created by Yonita Carter on 7/24/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import Foundation
import UIKit


class DetailController: UIViewController {
    
    @IBOutlet weak var label: UILabel!

    var received: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = String (received)
    }
}