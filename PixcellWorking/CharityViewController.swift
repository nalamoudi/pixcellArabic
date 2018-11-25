//
//  CharityViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-11-07.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class CharityViewController: UIViewController {
    
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid
    
    
    var openPawsTotal: Double?
    var IHYAATotal: Double?
    var UNRefugeeAgencyTotal: Double?
    var albumsOrdered: Double?
    var amountOwed: Double?
    var totalAlbumsToDate: Int?
    var didSubmit: Bool?
    var indexPathsOfCheckedOutAlbums: [Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        let ac = UIAlertController(title: "Please Select a Charity", message: "Pixcell will donate money on your behalf to a charity you choose!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Proceed to Select", style: .default, handler: nil)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.ref.child("charities").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let openPawsCurrentMoney = value?["Open Paws"] as? Double ?? 0
            let IHYAACurrentMoney = value?["IHYAA"] as? Double ?? 0
            let UNCurrentMoney = value?["UN Refugee Agency"] as? Double ?? 0
            self.openPawsTotal = openPawsCurrentMoney
            self.IHYAATotal = IHYAACurrentMoney
            self.UNRefugeeAgencyTotal = UNCurrentMoney
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.ref.child("users").child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.totalAlbumsToDate = value?["Total Albums To Date"] as? Int ?? 0
        })
    }
    
    @IBAction func firstCharityButton(_ sender: Any) {
        print(openPawsTotal)
        print(self.albumsOrdered)
        print(self.totalAlbumsToDate)
        print(self.amountOwed)
        print(self.albumsOrdered)
        print(self.indexPathsOfCheckedOutAlbums)
        guard let openPawsCharity = openPawsTotal, let orderQuantity = self.albumsOrdered, let totalAlbums = self.totalAlbumsToDate, let amount = self.amountOwed, let quantity = self.albumsOrdered, let indexPaths = self.indexPathsOfCheckedOutAlbums else {return}
        print(openPawsCharity)
        print(orderQuantity)
        print(totalAlbums)
        print(amount)
        print(quantity)
        print(indexPaths)
        let charity = (amount - quantity * 1.00) * 0.05
        self.ref.child("charities/Open Paws").setValue(openPawsCharity + charity)
        setValueOfSubmittedAlbumsToTrue(indexPaths)
        self.ref.child("users/\(uid)/Total Albums To Date").setValue(totalAlbums + Int(orderQuantity))
        self.ref.child("users/\(uid)/Submitted").setValue(true)
        performSegue(withIdentifier: "HomePageSegue", sender: self)
    }
    
    @IBAction func secondCharityButton(_ sender: Any) {
        guard let UNRefugeeCharity = UNRefugeeAgencyTotal, let albumsToDate = self.albumsOrdered, let totalAlbums = self.totalAlbumsToDate, let amount = self.amountOwed, let quantity = self.albumsOrdered, let indexPaths = self.indexPathsOfCheckedOutAlbums else {return}
        let charity = (amount - quantity * 1.00) * 0.05
        self.ref.child("charities/UN Refugee Agency").setValue(UNRefugeeCharity + charity)
        setValueOfSubmittedAlbumsToTrue(indexPaths)
        self.ref.child("users/\(uid)/Total Albums To Date").setValue(totalAlbums + Int(albumsToDate))
        self.ref.child("users/\(uid)/Submitted").setValue(true)
        performSegue(withIdentifier: "HomePageSegue", sender: self)
    }
    
    @IBAction func thirdCharityButton(_ sender: Any) {
        guard let IHYAACharity = IHYAATotal, let albumsToDate = self.albumsOrdered, let totalAlbums = self.totalAlbumsToDate, let amount = self.amountOwed, let quantity = self.albumsOrdered, let indexPaths = self.indexPathsOfCheckedOutAlbums else {return}
        let charity = (amount - quantity * 1.00) * 0.05
        self.ref.child("charities/IHYAA").setValue(IHYAACharity + charity)
        setValueOfSubmittedAlbumsToTrue(indexPaths)
        self.ref.child("users/\(uid)/Total Albums To Date").setValue(totalAlbums + Int(albumsToDate))
        self.ref.child("users/\(uid)/Submitted").setValue(true)
        performSegue(withIdentifier: "HomePageSegue", sender: self)
    }
    
    func setValueOfSubmittedAlbumsToTrue(_ indexPaths: [Int]) {
        for index in indexPaths {
            self.ref.child("users").child(self.uid).child("Albums").child("\(Date().getMonthName())").child("\(index)").child("1").setValue(true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomePageSegue"{
            let tb = segue.destination as! TabBarController
            let nv = tb.viewControllers![0] as! UINavigationController
            let dest = nv.topViewController as! HomeViewController
            dest.submittedNotification = true
        }
    }
    
}
