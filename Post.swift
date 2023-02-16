//
//  Post.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/10/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import Foundation
import Firebase

class Post {
    // Variables
    var caption: String
    var imageUrl: String
    var likes: Int
    var postKey: String
    var postRef: FIRDatabaseReference
    var width: CGFloat = 320
    var height: CGFloat = 320
    
    // Optional properties
    var userId: String?
    
    // Initializer
    init(snapshot: FIRDataSnapshot) {
        self.postKey = snapshot.key
        
        let json = JSON(snapshot.value)
        userId = json["userId"].string
        if let width = json["width"].float,
            let height = json["height"].float {
            self.width = CGFloat(width)
            self.height = CGFloat(height)
        }
        caption = json["caption"].stringValue
        imageUrl = json["imageUrl"].stringValue
        likes = json["likes"].intValue
        postRef = snapshot.ref
        
    }
    
    // Add and subtract likes upon like button being pressed, update Firebase
    func adjustLikes(addLike: Bool) {
        if addLike {
            likes += 1
        } else {
            likes -= 1
        }
        postRef.child("likes").setValue(likes)
    }
}
