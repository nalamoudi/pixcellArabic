//
//  ViewController.swift
//  PixcellWorking
//
//  Created by Nahar Alamoudi on 11/5/18.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//
//THIS IS THE ONE TO KEEP

import UIKit
import Firebase
import UserNotifications

class HomeViewController: UIViewController {

    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid
    
    var resetMonth: Int?
    var resetDay: Int?
    var todayDay: Int?
    var todayMonth: Int?
    var deadlineDayToSubmit: String?
    var submittedNotification: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let submittedValue = submittedNotification else {return}
            if submittedValue {
                let ac = UIAlertController(title: "Thank you for Submitting", message: "Sit tight and your album will be on its way to you", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                ac.addAction(action)
                self.present(ac, animated: true)
            }
    }
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.ref.child("Reset Date").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.resetDay = value?["Day"] as? Int ?? 0
            self.resetMonth = value?["Month"] as? Int ?? 0
            self.deadlineDayToSubmit = value?["Deadline"] as? String ?? ""
            let today = Date().yearMonthDay()
            print (today)
            let today1 = today.replacedArabicDigitsWithEnglish
            print (today1)
            let todayArray = today1.components(separatedBy: "/")
            print (todayArray)
            self.todayDay = Int(todayArray[2])
            self.todayMonth = Int(todayArray[1])
            
            guard let todayDay = self.todayDay, let todayMonth = self.todayMonth, let resetDay = self.resetDay, let resetMonth = self.resetMonth else {return}
            
            if todayDay == resetDay && todayMonth == resetMonth {
                self.ref.child("users").child(self.uid).child("Albums").setValue(["\(Date().getMonthName())":[[["empty":1000],false, false],[["empty":1000], false, false]]])
                print("values reset")
            } else {
                print("It is not reset day yet")
            }
        })
    }
}

public extension String {
    
    public var replacedArabicDigitsWithEnglish: String {
        var str = self
        let map = ["٠": "0",
                   "١": "1",
                   "٢": "2",
                   "٣": "3",
                   "٤": "4",
                   "٥": "5",
                   "٦": "6",
                   "٧": "7",
                   "٨": "8",
                   "٩": "9"]
        map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
        return str
    }
}
