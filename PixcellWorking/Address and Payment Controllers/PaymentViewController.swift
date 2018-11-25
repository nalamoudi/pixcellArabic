//
//  PaymentViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-28.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class PaymentViewController: UIViewController, OPPCheckoutProviderDelegate {
    
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var checkoutButton: UIButton!
    @IBOutlet var processingView: UIActivityIndicatorView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextView!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var provinceField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var sameAsShippingSwitch: UISwitch!
    
    var checkoutProvider: OPPCheckoutProvider?
    var transaction: OPPTransaction?
    var amountOwed: Double?
    var fullAddress: String?
    var userName: String?
    var didSubmit: Bool?
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Credit Card Information"
        guard let amount = self.amountOwed else {return}
        amountLabel.text = "\(amount) SAR"
        checkoutButton.layer.cornerRadius = 4
        processingView.isHidden = true
        addressField!.layer.borderWidth = 1
        addressField!.layer.borderColor = UIColor.init(red: 230, green: 230, blue: 230).cgColor
        addressField!.layer.cornerRadius = 4
        checkoutButton.isEnabled = false
    }
    
    @IBAction func toggleSameAsShippingAddress(_ sender: Any) {
        guard let address = fullAddress else {return}
        let addressComponents = address.components(separatedBy: ", ")
        let cityAndZipCode = addressComponents[1].components(separatedBy: " ")
        if sameAsShippingSwitch.isOn {
            let billingAddress = addressComponents[0]
            let billingCity = cityAndZipCode[0]
            let billingZipCode = cityAndZipCode[1]
            var billingProvince: String {
                switch billingCity {
                case "Jeddah", "Makkah", "Mekkah", "Mecca":
                    return "Makkah"
                case "Riyadh":
                    return "Riyadh"
                case "Dammam", "Dahran":
                    return "Sharqiyah"
                case "Madina", "Yanbu":
                    return "Al Madina Al Munawara"
                default:
                    return " "
                }
            }
            guard let userFullName = self.userName else {return}
            nameField.text = userFullName
            addressField.text = billingAddress
            cityField.text = billingCity
            provinceField.text = billingProvince
            zipCodeField.text = billingZipCode
            enableButton()
        } else {
            nameField.text = ""
            addressField.text = ""
            cityField.text = ""
            provinceField.text = ""
            zipCodeField.text = ""
        }
    }
    
    func enableButton() {
        if sameAsShippingSwitch.isOn {
            checkoutButton.isEnabled = true
        } else if !(nameField.text?.isEmpty)! && !((addressField.text?.isEmpty)!) && !((cityField.text?.isEmpty)!) && !((provinceField.text?.isEmpty)!) && !((zipCodeField.text?.isEmpty)!) {
            checkoutButton.isEnabled = true
        }
    }
    
    // MARK: - Action methods
    
    @IBAction func checkoutButtonAction(_ sender: UIButton) {
        self.processingView.startAnimating()
        sender.isEnabled = false
        guard let amount = self.amountOwed else {return}
        Request.requestCheckoutID(amount: amount, currency: "USD", completion: {(checkoutID) in
            DispatchQueue.main.async {
                self.processingView.stopAnimating()
                sender.isEnabled = true

                guard let checkoutID = checkoutID else {
                    Utils.showResult(presenter: self, success: false, message: "Checkout ID is empty")
                    return
                }
                
                self.checkoutProvider = self.configureCheckoutProvider(checkoutID: checkoutID)
                self.checkoutProvider?.delegate = self
                self.checkoutProvider?.presentCheckout(forSubmittingTransactionCompletionHandler: { (transaction, error) in
                    DispatchQueue.main.async {
                        self.handleTransactionSubmission(transaction: transaction, error: error)
                    }
                }, cancelHandler: nil)
            }
        })
    }
    
    // MARK: - OPPCheckoutProviderDelegate methods
    
    // This method is called right before submitting a transaction to the Server.
    func checkoutProvider(_ checkoutProvider: OPPCheckoutProvider, continueSubmitting transaction: OPPTransaction, completion: @escaping (String?, Bool) -> Void) {
        // To continue submitting you should call completion block which expects 2 parameters:
        // checkoutID - you can create new checkoutID here or pass current one
        // abort - you can abort transaction here by passing 'true'
        completion(transaction.paymentParams.checkoutID, false)
    }
    
    // MARK: - Payment helpers
    
    func handleTransactionSubmission(transaction: OPPTransaction?, error: Error?) {
        guard let transaction = transaction else {
            Utils.showResult(presenter: self, success: false, message: error?.localizedDescription)
            return
        }
        
        self.transaction = transaction
        if transaction.type == .synchronous {
            // If a transaction is synchronous, just request the payment status
            self.requestPaymentStatus()
        } else if transaction.type == .asynchronous {
            // If a transaction is asynchronous, SDK opens transaction.redirectUrl in a browser
            // Subscribe to notifications to request the payment status when a shopper comes back to the app
            NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAsynchronousPaymentCallback), name: Notification.Name(rawValue: Config.asyncPaymentCompletedNotificationKey), object: nil)
        } else {
            Utils.showResult(presenter: self, success: false, message: "Invalid transaction")
        }
    }
    
    func configureCheckoutProvider(checkoutID: String) -> OPPCheckoutProvider? {
        let provider = OPPPaymentProvider.init(mode: .test)
        let checkoutSettings = Utils.configureCheckoutSettings()
        checkoutSettings.storePaymentDetails = .prompt
        return OPPCheckoutProvider.init(paymentProvider: provider, checkoutID: checkoutID, settings: checkoutSettings)
    }
    
    func requestPaymentStatus() {
        guard let resourcePath = self.transaction?.resourcePath else {
            Utils.showResult(presenter: self, success: false, message: "Resource path is invalid")
            return
        }
        
        self.transaction = nil
        self.processingView.startAnimating()
        Request.requestPaymentStatus(resourcePath: resourcePath) { (success) in
            DispatchQueue.main.async {
                self.processingView.stopAnimating()
                let message = success ? "Your payment was successful" : "Your payment was not successful"
                let title = success ? "Success" : "Failure"
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    if success {
                        self.didSubmit = true
                        self.performSegue(withIdentifier: "SelectCharitySegue", sender: self)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Async payment callback
    
    @objc func didReceiveAsynchronousPaymentCallback() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Config.asyncPaymentCompletedNotificationKey), object: nil)
        self.checkoutProvider?.dismissCheckout(animated: true) {
            DispatchQueue.main.async {
                self.requestPaymentStatus()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectCharitySegue" {
            if let dest = segue.destination as? CharityViewController {
                dest.didSubmit = self.didSubmit
                dest.amountOwed = self.amountOwed
            }
        }
    }
}
