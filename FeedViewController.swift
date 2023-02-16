//
//  FeedViewController.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/8/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImage: CircleView!
    @IBOutlet weak var captionField: CustomView1!
    @IBOutlet weak var previewImageView: CircleView!
    
    // Variables
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var imageToPost: UIImage?
    var isSelectingProfileImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set up image picker controller
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Cell autosizing
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 444.0
        
        // Post new caption and image, update feed
        DataService.ds.REF_POSTS.observe(.childAdded, with: { (snapshot) in
            DispatchQueue.main.async {
                if let _ = snapshot.value as? Dictionary<String, AnyObject> {
                    let post = Post(snapshot: snapshot)
                    self.posts.insert(post, at: 0)
                }
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.configureCell(post: post)
        return cell
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageToPost = image
            if isSelectingProfileImage {
                updateProfileImage()
            } else {
                previewImageView.isHidden = false
                previewImageView.image = image
                imageSelected = true
            }
        } else {
            print("A valid image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        isSelectingProfileImage = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func updateProfileImage() {
        guard let image = imageToPost, let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        
        // Upload the image
        DataService.ds.upload(image: image) { (url: String) in
            // Update the profile picture url of the current user
            let userData: Dictionary<String, AnyObject> = [
                "profilePictureURL": url as AnyObject
            ]
            DataService.ds.REF_USERS.child(uid).updateChildValues(userData)
        }
    }
    
    @IBAction func postButtonTapped(_ sender: AnyObject) {
        guard let caption = captionField.text, caption != "" else {
            print("Caption must be entered")
            captionField.shake()
            return
        }
        guard let image = imageToPost, imageSelected == true else {
            print("An image must be selected")
            // Show to the user what they are missing in the form
            addImage.shake()
            return
        }
        
        // Hide the keyboard after the post button was pressed
        view.endEditing(true)
        
        // Upload the image
        DataService.ds.upload(image: image) { (url: String) in
            // Post the post with the uploaded image
            self.postToFirebase(image: image, imageUrl: url)
        }
    }
    
    // Update firebase on post
    func postToFirebase(image: UIImage, imageUrl: String) {
        let post = [
            "caption": captionField.text!,
            "imageUrl": imageUrl,
            "likes": 0,
            "userId" : (FIRAuth.auth()?.currentUser?.uid ?? ""),
            "width" : image.size.width,
            "height" : image.size.width
        ] as [String : Any]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        // Clean up
        captionField.text = ""
        imageSelected = false
        previewImageView.isHidden = true
    }
    
    // Sign out button
    @IBAction func signOutTapped(_ sender: AnyObject) {
        // Removing the user from keychain
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed from keychain - \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        // Present sign in screen
        self.performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    // Add new profile picture
    @IBAction func addProfilePicturePressed(_ sender: AnyObject) {
        isSelectingProfileImage = true
        present(imagePicker, animated: true, completion: nil)
    }
    
}
