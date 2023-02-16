//
//  UIView+Shake.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/11/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    // Shake function for incorrect email/password OR no caption/image in attempt to post
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}
