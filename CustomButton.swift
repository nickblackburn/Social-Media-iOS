//
//  CustomButton.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/8/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    // Custom class to make rounded, circular-shaped button
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 2.0
    }
}
