//
//  ViewController.swift
//  Talk2Me
//
//  Created by Nicholas Blackburn on 10/8/16.
//  Copyright © 2016 Nicholas Blackburn. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class ViewController: UIViewController {

    // IBOutlets
    @IBOutlet var emailField: CustomView1!
    @IBOutlet var passwordField: CustomView1!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("ID found in keychain")
            self.performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

    // Facebook button
    @IBAction func facebookBtnTapped(_ sender: AnyObject) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logOut()
        
        // Facebook authentication
        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
            if error != nil {
                print("Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("User cancelled Facebook authentication")
            } else {
                print("Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        })
    }
    
    // Firebase authentication
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to authenticate with Firebase - \(error)")
            } else {
                print("Successfully authenticated with Firebase")
                if let user = user {
                    let username = user.email!.components(separatedBy: "@").first!
                    let userData = ["provider": user.providerID,
                                    "username" : username]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    // Sign in button
    @IBAction func signInTapped(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("Email user authenticated with Firebase")
                    if let user = user {
                        // Update the user data in Firebase Database
                        let username = user.email!.components(separatedBy: "@").first!
                        let userData = ["provider": user.providerID,
                                    "username" : username]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Unable to authenticate with Firebase using Email")
                            self.passwordField.shake()
                        } else {
                            print("Successfully authenticated email with Firebase")
                            if let user = user {
                                let username = email.components(separatedBy: "@").first!
                                let userData = ["provider": user.providerID,
                                                "username" : username]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
                }
            )}
    }
    
    // Sign in push to Firebase and save to KeychainWrapper
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain - \(keychainResult)")
        self.performSegue(withIdentifier: "goToFeed", sender: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard upon touching the background
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

