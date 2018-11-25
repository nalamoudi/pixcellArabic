//
//  accountCellView.swift
//  PixcellWorking
//
//  Created by Nahar Alamoudi on 11/8/18.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class accountCellView: UITableViewCell {
    
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid

    @IBOutlet weak var cellOneLabel: UILabel!
    @IBOutlet weak var cellOnePhoneNum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(name: String){
        cellOneLabel.text = name
        
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let userPhoneNum = value?["Phone Number"] as? String ?? ""
            if name == "Phone Number" || name == "رقم الجوال" {
                self.cellOnePhoneNum.text = "+966 \(userPhoneNum)"
            } else if name == "Password" || name == "كلمة السر"{
                self.cellOnePhoneNum.text = "********"
            }
        })
    }

}
