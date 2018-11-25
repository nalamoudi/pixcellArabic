//
//  UserPhoneNumberViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-11-12.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class UserPhoneNumberViewController: UIViewController {
    
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid
    var currentUserPhone: String?

    
    @IBOutlet weak var userPhoneNumberField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        guard let userPhone = currentUserPhone else {return}
        userPhoneNumberField!.text = "\(userPhone)"
    }
    
    
    @IBAction func saveNewPhoneNumber(_ sender: Any) {
        guard let oldUserPhone = currentUserPhone, let newPhoneNumber = userPhoneNumberField.text else {return}
        if newPhoneNumber != oldUserPhone {
            self.ref.child("users/\(uid)/Phone Number").setValue(newPhoneNumber)
            let ac = UIAlertController(title: "Success", message: "Your phone number has been updated successfully", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            ac.addAction(action)
            present(ac,animated: true)
        }
    }

}
