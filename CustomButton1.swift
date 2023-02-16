//
//  CustomButton1.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/9/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import UIKit

class CustomButton1: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.width / 2
        self.resizableSnapshotView(from: self.bounds, afterScreenUpdates: false, withCapInsets: UIEdgeInsetsMake(10, 10, 10, 10))
    }
}
