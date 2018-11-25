//
//  accountCellView2.swift
//  PixcellWorking
//
//  Created by Nahar Alamoudi on 11/8/18.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class accountCellView2: UITableViewCell {
    
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid

    @IBOutlet weak var cellTwoLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(name: String){
        cellTwoLabel.text = name
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let totalAlbums = value?["Total Albums To Date"] as? Double ?? 0.0
            if name == "Total Albums Ordered" || name == "مجموع الالبومات المطلوبة" {
                self.countLabel.text = "\(Int(totalAlbums))"
            } else if name == "Total Donations" || name == "مجموع التبرعات"{
                self.countLabel.text = "\(totalAlbums * 1.45) SAR"
            }
        })
        
    }


}
