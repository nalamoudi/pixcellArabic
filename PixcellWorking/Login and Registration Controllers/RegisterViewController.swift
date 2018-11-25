//
//  RegisterViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-17.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

//This controller allows the user to register, and is reached from clicking the register button in ViewController.

import UIKit
import Firebase
import Foundation

class RegisterViewController: UIViewController {

    @IBOutlet fileprivate var firstNameField: UITextField!
    @IBOutlet fileprivate var lastNameField: UITextField!
    @IBOutlet fileprivate var emailField: UITextField!
    @IBOutlet fileprivate var passwordField: UITextField!
    @IBOutlet fileprivate var phoneNumbField: UITextField!
    @IBOutlet fileprivate var passwordCheckField: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        navigationItem.title = "Registration"
        firstNameField.text = ""
        lastNameField.text = ""
        emailField.text = ""
        passwordField.text = ""
        phoneNumbField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    //This action takes the users inputs for all the fields and unwraps them. Then it displays a spinner while the registration process is going on. If an error occurs, a local error message is generated depending on which field was not filled in correctly. If no error occurs, the spinner disappears and the firebase Auth.auth() method is called to sign up the user with a username and password, then sets up and saves their data in the datastorage under their userID as child perameters.
    
    @IBAction func signUpButton(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text, let firstName = firstNameField.text, let phoneNumb = phoneNumbField.text, let lastName = lastNameField.text, let passwordReEntry = passwordCheckField.text else {
            print("Username and Email Not Valid")
            return
        }
        if password == passwordReEntry {
            let sv = UIViewController.displaySpinner(onView: self.view)
            Auth.auth().createUser(withEmail: email, password: password) { (authResult , error) in
                if let error = error?.localizedDescription{
                    self.displayErrorMessage(message: error)
                } else {
                    guard let uid = authResult?.user.uid else {
                        if let descrip = error?.localizedDescription{
                            self.displayErrorMessage(message: descrip)
                        }
                        print("failed to load user")
                        return
                    }
                    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
                    let userRef = ref.child("users").child(uid)
                    let values: [String: Any] = ["First Name": firstName,
                                                 "Last Name": lastName,
                                                 "Phone Number": phoneNumb,
                                                 "Email": email,
                                                 "Password": password,
                                                 "Address": "empty",
                                                 "Submission Day":0,
                                                 "Location Coordinates":"empty",
                                                 "Paid": false,
                                                 "Delivered": false,
                                                 "Submitted": false,
                                                 "Total Albums To Date": 0,
                                                 "Albums":["\(Date().getMonthName())":[[["empty":1000],false, false],[["empty":1000], false, false]]]]
                    
                    userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            if let descrip = error?.localizedDescription{
                                self.displayErrorMessage(message: descrip)
                            }
                            return
                        }
                        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                            if error != nil {
                                if let descrip = error?.localizedDescription {
                                    self.displayErrorMessage(message: descrip)
                                }
                            } else {
                                UIViewController.removeSpinner(spinner: sv)
                                let ac = UIAlertController(title: "Authentication Email Sent", message: "Please check your junk folder and mark us as safe", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                    self.loadLoginScreen()
                                }))
                                self.present(ac, animated: true)
                            }
                        })
                        print("Saved User Successfully")
                    })
                }
            }
        } else {
            let ac = UIAlertController(title: "Password Mismatch", message: "Please ensure your passwords are matching", preferredStyle: .alert)
            let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            ac.addAction(action)
            present(ac, animated: true)
        }
    }
    
    @IBAction func privacyPolicyPressed(_ sender: Any) {
        if let url = URL(string: "https://pixcellbook.com/terms-and-conditions") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func termsAndConditionsPressed(_ sender: Any) {
        if let url = URL(string: "https://www.pixcellbook.com/privacy-policy") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    //method to present the login screen
    func loadLoginScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    //method to show error message
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
}
