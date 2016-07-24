//
//  DetailsController.swift
//  uclactive
//
//  Created by Diana Darie on 7/24/16.
//  Copyright © 2016 Diana Darie. All rights reserved.
//

import UIKit


class DetailsController: UIStoryboardSegue {
    
    
    override func perform () {
        
        let sourceVC = self.sourceViewController
        let destinationVC = self.destinationViewController
        
        sourceVC.view.addSubview(destinationViewController.view)
        destinationVC.view.transform = CGAffineTransformMakeScale(0.05, 0.85)
        
        UIView.animateWithDuration(0.5, delay:0.0, options: .CurveEaseInOut, animations: { () -> Void in
            
            destinationVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }) { (finished) -> Void in
            
            destinationVC.view.removeFromSuperview()
            
            let time = dispatch_time (DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC)))
            
            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                sourceVC.presentViewController(destinationVC, animated: false, completion: nil)
            })
        }
    }
    
}
