//
//  PostCell.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/9/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    // IB Outlets
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var addProfileImageButton: UIButton!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    // Variables
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var handle : FIRDatabaseHandle?
    var reference: FIRDatabaseReference?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post) {
        self.post = post
        
        // Set the labels texts
        self.caption.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        
        // Download the image or set from the cache
        self.postImage.setImage(url: post.imageUrl)
        self.addProfileImageButton.setImage(nil, for: .normal)
        
        // Stop observing the user (cleaning up before loading a new user)
        if let handle = handle {
            reference?.removeObserver(withHandle: handle)
        }
        
        // Fetching user info based on the userId from Firebase
        profileImg.image = nil
        if let userId = post.userId {
            // Set the user's profile picture
            reference = FIRDatabase.database().reference().child("users").child(userId)
            handle = reference?.observe(.value, with: { (snapshot: FIRDataSnapshot) in
                if let json = snapshot.value as? [String : Any] {
                    if let url = json["profilePictureURL"] as? String {
                        self.profileImg.setImage(url: url)
                        self.addProfileImageButton.setImage(nil, for: .normal)
                        
                        // Enable current user to change his/her profile picture
                        if userId == FIRAuth.auth()!.currentUser!.uid {
                            self.addProfileImageButton.isUserInteractionEnabled = true
                        } else {
                            self.addProfileImageButton.isUserInteractionEnabled = false
                        }
                    } else {
                        // Authenticate user, check if user has profile picture, if not add Plus image
                        if userId == FIRAuth.auth()!.currentUser!.uid {
                            self.addProfileImageButton.setImage(UIImage(named: "Plus"), for: .normal)
                            self.addProfileImageButton.isUserInteractionEnabled = true
                        } else {
                            // Disable interactivity of addProfileImage button for non users
                            self.addProfileImageButton.isUserInteractionEnabled = false
                            self.addProfileImageButton.setImage(UIImage(named: "Plus"), for: .normal)
                        }
                    }
                    self.userNameLabel.text = json["username"] as? String
                }
            })
        }
        
        // Pick the node of the current user's likes of this post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        // Setting the like
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "HeartEmpty")
            } else {
                self.likeImage.image = UIImage(named: "HeartFilled")
            }
        })
        
        // Calculate the image height
        let ratio = post.height / post.width
        imageHeightConstraint.constant = ratio * UIScreen.main.bounds.size.width
    }
    
    // UITapGesture called upon like button being pressed, toggles filled/empty heart image, updates Firebase
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "HeartFilled")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "HeartEmpty")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
            self.likesLabel.text = "\(self.post.likes)"
        })
    }

}
