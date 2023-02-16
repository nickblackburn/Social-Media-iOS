//
//  CircleView.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/9/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
 
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutIfNeeded()
        self.clipsToBounds = true
        self.layer.cornerRadius = frame.size.height / 2.0
    }
    
}
