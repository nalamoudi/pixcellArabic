//
//  PasswordChangeViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-11-12.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class PasswordChangeViewController: UIViewController {
    
    var currentUserPassword: String?
    
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid
    
    
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var confirmNewPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.title = "Change Password"
        updatePasswordButton.layer.cornerRadius = 4
    }
    
    func loadAccountSettings() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let accountViewController = storyBoard.instantiateViewController(withIdentifier: "AccountTableViewController") as! AccountTableViewController
        // Change the above back
        self.present(accountViewController, animated: true, completion: nil)
    }
    
    func displayErrorMessage(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction) in }
        alertView.addAction(okAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func updatePasswordButtonPressed(_ sender: Any) {
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.currentUserPassword = value?["Password"] as? String ?? ""
        })
        guard let currentPasswordEntered = currentPasswordField.text,
            let currentPassword = currentUserPassword, let newPasswordEntered = newPasswordField.text, let newPasswordEnteredConfirm = confirmNewPasswordField.text else {return}
        if currentPasswordEntered != currentPassword {
            displayErrorMessage(message: "Please enter your current password correctly")
        } else {
            if newPasswordEntered != newPasswordEnteredConfirm {
                displayErrorMessage(message: "Please make sure the new password fields match")
            } else {
                let sv = UIViewController.displaySpinner(onView: self.view)
                Auth.auth().currentUser?.updatePassword(to: newPasswordEntered) { (error) in
                    UIViewController.removeSpinner(spinner: sv)
                    if error != nil {
                        if let descrip = error?.localizedDescription {
                            self.displayErrorMessage(message: descrip)
                        }
                    } else {
                        let ac = UIAlertController(title: "Password Changed Successfully", message: nil, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default, handler: { action in
                            self.ref.child("users/\(self.uid)/Password").setValue(newPasswordEntered)
                            self.loadAccountSettings()
                        })
                        ac.addAction(action)
                        self.present(ac, animated: true)
                    }
                    
                }
            }
        }
        
    }
    

}
