//
//  AddressPaymentViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-31.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import LocationPickerViewController
import Firebase
import MapKit

class AddressPaymentViewController: UIViewController {
    
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid
    var userAddress = ""
    var albumsCheckedOut: Double?
    var didSubmit: Bool?
    var userName: String?
    var total: Double?
    var indexPathsOfCheckedOutAlbums: [Int]?
    

    @IBOutlet weak var proceedToPaymentOutlet: UIButton!
    @IBOutlet weak var locationAddressLabel: UITextField!
    @IBOutlet weak var cashIcon: UIImageView!
    @IBOutlet weak var creditcardIcon: UIImageView!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var subtotalView: UIView!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var VATLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Checkout", comment: "")
        searchLocationButton.layer.cornerRadius = 4
        creditcardIcon.layer.cornerRadius = 4
        cashIcon.layer.cornerRadius = 4
        submitButton.layer.cornerRadius = 4
        subtotalView.layer.cornerRadius = 4
        cashIcon.isHighlighted = false
        creditcardIcon.isHighlighted = false
        proceedToPaymentOutlet.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.userAddress = value?["Address"] as? String ?? ""
            let firstName = value?["First Name"] as? String ?? ""
            let lastName = value?["Last Name"] as? String ?? ""
            self.userName = firstName + " " + lastName
            self.locationAddressLabel!.text = ("\(self.userAddress)")
            
            guard let albumsQuantity = self.albumsCheckedOut else {return}
            print(albumsQuantity)
            let baseCost = (28.56 * albumsQuantity).rounded(toPlaces: 2)
            let VAT = (baseCost * 0.05).rounded(toPlaces: 2)
            let total = (baseCost + VAT).rounded(toPlaces: 2)
            self.total = total
            self.subtotalLabel.text = "\(baseCost) SAR"
            self.VATLabel.text = "\(VAT) SAR"
            self.totalLabel.text = "\(total) SAR"
        })
        UIViewController.removeSpinner(spinner: sv)
        
    }
    
    
    @IBAction func cashOnDeliveryClicked(_ sender: Any) {
        cashIcon.isHighlighted = true
        creditcardIcon.isHighlighted = false
        enablePayment()
    }
    
    @IBAction func crediCardClicked(_ sender: Any) {
        cashIcon.isHighlighted = false
        creditcardIcon.isHighlighted = true
        enablePayment()
    }
    
    func enablePayment () {
        if cashIcon.isHighlighted || creditcardIcon.isHighlighted && locationAddressLabel.text?.isEmpty == false {
            proceedToPaymentOutlet.isEnabled = true
        }
    }
    
    @IBAction func proceedButton(_ sender: Any) {
        if cashIcon.isHighlighted {
            didSubmit = true
            print(self.indexPathsOfCheckedOutAlbums)
            performSegue(withIdentifier: "PayInCashSegue", sender: self)
        } else if creditcardIcon.isHighlighted {
            didSubmit = false
            performSegue(withIdentifier: "CreditCardPaymentSegue", sender: self)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let total = self.total, let albumsCheckedOut = self.albumsCheckedOut else {return}
        if segue.identifier == "PickLocationSegue" {
            let locationPicker = segue.destination as! LocationPicker
            locationPicker.addBarButtons()
            locationPicker.pickCompletion = { (pickedLocationItem) in
                guard let addressString = pickedLocationItem.formattedAddressString else {return}
                let locationName = "\(pickedLocationItem.name), \(addressString), Saudi Arabia"
                
                let locationCoordinates = "\(pickedLocationItem.coordinate!.latitude),\(pickedLocationItem.coordinate!.longitude)"
                guard let uid = Auth.auth().currentUser?.uid else {return}
                self.ref.child("users/\(uid)/Address").setValue(locationName)
                self.locationAddressLabel!.text = locationName
                self.ref.child("users/\(uid)/Location Coordinates").setValue(locationCoordinates)
            }
        } else if segue.identifier == "CreditCardPaymentSegue" {
            let dest = segue.destination as! PaymentViewController
            dest.fullAddress = self.userAddress
            dest.userName = self.userName
            dest.amountOwed = total
            
        } else if segue.identifier == "PayInCashSegue" {
            let dest = segue.destination as! CharityViewController
            dest.didSubmit = self.didSubmit
            print(total)
            print(albumsCheckedOut)
            dest.amountOwed = total
            dest.albumsOrdered = albumsCheckedOut
            dest.indexPathsOfCheckedOutAlbums = self.indexPathsOfCheckedOutAlbums
        }
    }

}
