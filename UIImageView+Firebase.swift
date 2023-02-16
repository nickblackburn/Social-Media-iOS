//
//  UIImageView+Firebase.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/12/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import UIKit
import FirebaseStorage

let firebaseImageCache: NSCache<NSString, UIImage> = NSCache()

extension UIImageView {
    // Download images from Firebase and store them in an imageCache
    func setImage(url: String) {
        self.image = nil
        if let image = firebaseImageCache.object(forKey: url as NSString) {
            self.image = image
        } else {
            
            let ref = FIRStorage.storage().reference(forURL: url)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Unable to download image from Firebase Storage")
                } else {
                    print("Image downloaded successfully from Firebase Storage")
                    if let imageData = data {
                        if let img = UIImage(data: imageData) {
                            self.image = img
                            firebaseImageCache.setObject(img, forKey: url as NSString)
                        }
                        
                    }
                }
            })
        }
    }
    
}


