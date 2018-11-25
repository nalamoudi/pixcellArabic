//
//  LoggedInViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-17.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

//This controller is what the user sees after logging in and/or finishing picking their photos

import UIKit
import Firebase


class CreateAlbumController: UIViewController {

    @IBOutlet weak var addButtonOUtlet: UIButton!
    
    var tableViewData = [[String:(images: Int, submitted: Bool, delivered: Bool)]]()
    var tableViewDataFireBase = [NSArray]()
    var albumsCheckedOut: Double?
    var didSubmit: Bool?
    var indexPathsOfCheckOutAlbums: [Int]?
    
    // Creating Firebase Reference for Read/Write Operations
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid

    @IBOutlet var addAlbumButtonPressed: UIButton!
    @IBOutlet weak var albumsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAlbumButtonPressed.layer.cornerRadius = 10
        addAlbumButtonPressed.layer.borderWidth = 1
        addAlbumButtonPressed.layer.borderColor = UIColor.init(red: 230, green: 230, blue: 230).cgColor
        self.hideKeyboardWhenTappedAround()
        let checkoutB = NSLocalizedString("Checkout", comment: "")
        let checkoutButton = UIBarButtonItem(title: checkoutB, style: .plain, target: self, action: #selector(submit))
        self.navigationItem.rightBarButtonItem = checkoutButton
        albumsTableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let sv = UIViewController.displaySpinner(onView: self.view)
        self.ref.child("users").child(self.uid).child("Albums").child("\(Date().getMonthName())").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? [NSArray]
            guard let albumArray = value else {return}
            let firstAlbumDetails = albumArray[0]
            let firstAlbumDictionary = firstAlbumDetails[0] as? NSDictionary
            guard let firstAlbumDic = firstAlbumDictionary else {return}
            let counter = firstAlbumDic.allValues[0] as? Int
            guard let tag = counter else {return}
            if tag == 1000 {
                print("default place holder in place on Firebase, will be deleted")
            } else if !self.tableViewData.isEmpty{
                print("no need to update rows")
            } else {
                for i in 0...value!.count-1 {
                    let albumData = albumArray[i]
                    let albumNameAndImages = albumData[0] as? NSDictionary
                    let albumSubmitted = albumData[1] as? Bool
                    let albumDelivered = albumData[2] as? Bool
                    guard let albumNameAndImagesUnwrapped = albumNameAndImages, let albumSubmittedUnwrapped = albumSubmitted, let albumDeliveredUnwrapped = albumDelivered else {return}
                    let albumName = albumNameAndImagesUnwrapped.allKeys[0] as! String
                    let albumImages = albumNameAndImagesUnwrapped.allValues[0] as! Int
                    let albumDidSubmit = albumSubmittedUnwrapped
                    let albumDidDeliver = albumDeliveredUnwrapped
                    self.tableViewData.append([albumName: (images: albumImages, submitted: albumDidSubmit, delivered: albumDidDeliver)])
                }
                self.albumsTableView.reloadData()
            }
            UIViewController.removeSpinner(spinner: sv)
        })
        self.callDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let index = self.albumsTableView.indexPathForSelectedRow{
            self.albumsTableView.deselectRow(at: index, animated: true)
        }
        self.ref.child("users").child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.didSubmit = value?["Submitted"] as? Bool ?? false
        })
    }
    
    func callDelegates () {
        albumsTableView.delegate = self
        albumsTableView.dataSource = self
    }
    
    //display an error message as a UIAlertController
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
    
    
    @IBAction func addAlbumButtonPressed(_ sender: UIButton) {
        
        //TO DO: add functionality for deadline
        let today = Date().yearMonthDay()
        let today1 = today.replacedArabicDigitsWithEnglish
        let todayArray = today1.components(separatedBy: "/")
        let todayDay = todayArray[2]
        guard let todayDayNum = Int(todayDay) else {return}
        if todayDayNum >= 26 {
            sender.isEnabled = false
            displayErrorMessage(message: "You will be unable to submit for 5 days as we cannot guarantee delivery by the end of the month")
        } else {
           addTableRow()
        }
        
    }
    
    func addTableRow () {
        let nameSelectionAlert = UIAlertController(title: NSLocalizedString("Pick a name for your Album", comment: ""), message: nil, preferredStyle: .alert)
        nameSelectionAlert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Enter Album Name Here", comment: "")
            textField.enablesReturnKeyAutomatically = true
        }
        let action = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { action in
            guard let name = nameSelectionAlert.textFields![0].text else {
                return
            }
            self.tableViewData.append([name: (50, false, false)])
            self.albumsTableView.reloadData()
            self.tableViewDataFireBase.removeAll()
            for i in 0...self.tableViewData.count-1 {
                let album = self.tableViewData[i]
                let albumName = album.keys.first as! String
                let albumImagesRemaining = album[albumName]?.images as! Int
                let albumSubmitted = album[albumName]?.submitted as! Bool
                let albumDelivered = album[albumName]?.delivered as! Bool
                self.tableViewDataFireBase.insert([[albumName:albumImagesRemaining], albumSubmitted, albumDelivered], at: i)
            }
            self.ref.child("users").child(self.uid).child("Albums").child("\(Date().getMonthName())").setValue(self.tableViewDataFireBase)
            self.albumsTableView.reloadData()
        })
        nameSelectionAlert.addAction(action)
        self.present(nameSelectionAlert, animated: true, completion: nil)
    }
}

extension CreateAlbumController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! AlbumCell
        cell.layer.cornerRadius = 14
        tableView.rowHeight = 80
        if indexPath.row == 0 || indexPath.row == 3 || indexPath.row ==  6 {
            cell.backgroundColor = UIColor(alpha: 1, red: 170, green: 226, blue: 242)
        } else if indexPath.row  == 1 || indexPath.row == 4 || indexPath.row == 7 {
            cell.backgroundColor = UIColor(alpha: 1, red: 243, green: 232, blue: 191)
        } else if indexPath.row  == 2 || indexPath.row == 5 || indexPath.row == 8 {
            cell.backgroundColor = UIColor(alpha: 1, red: 237, green: 151, blue: 160)
        }
        self.albumsTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let albumName = tableViewData[indexPath.row].keys
        if let albumCellLabelText = albumName.first {
            cell.albumNameLabel!.text = albumCellLabelText
            let albumProperties = tableViewData[indexPath.row][albumCellLabelText]
            if let albumProp = albumProperties {
                if albumProp.submitted == true {
                    cell.albumRemainingImagesLabel!.text = "Delivery ongoing"
                } else if albumProp.submitted == false {
                    cell.albumRemainingImagesLabel!.text = "\(50-albumProp.images)/50"
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row == 0 && tableViewData.count == 1 {
                self.ref.child("users").child(self.uid).child("Albums").setValue(["\(Date().getMonthName())":[[["empty":1000],false, false],[["empty":1000], false, false]]])
                tableViewData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            } else {
                let deleteInstance = self.ref.child("users").child(self.uid).child("Albums").child("\(Date().getMonthName())").child("\(indexPath.row)")
                deleteInstance.removeValue()
                tableViewData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc private func submit(_ sender: UIBarButtonItem) {
        if(self.albumsTableView.isEditing == false) {
            self.albumsTableView.isEditing = true
            addButtonOUtlet.isEnabled = false
            let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .disabled)
            self.navigationItem.leftBarButtonItem = cancelButton
            self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Submit", comment: "")
            let ac = UIAlertController(title: NSLocalizedString("Checkout alert title", comment: ""), message: NSLocalizedString("Checkout message", comment: ""), preferredStyle: .alert)
            let action = UIAlertAction(title: NSLocalizedString("Proceed", comment: ""), style: .default, handler: nil)
            ac.addAction(action)
            present(ac, animated: true)
        } else {
            let indexPaths = albumsTableView.indexPathsForSelectedRows
            guard let indexArray = indexPaths else {return}
            if !indexArray.isEmpty{
                var indexPathRowArray = [Int]()
                for index in indexArray {
                    indexPathRowArray.append(index.row)
                }
                guard let checkoutItems = indexPaths?.count else {return}
                self.albumsCheckedOut = Double(checkoutItems)
                self.indexPathsOfCheckOutAlbums = indexPathRowArray
                performSegue(withIdentifier: "CheckOutSegue", sender: self)
                self.albumsTableView.isEditing = false
                self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Checkout", comment: "")
        
            }
        }
    }
    
    @objc private func cancel(_ sender: UIBarButtonItem) {
        self.albumsTableView.isEditing = false
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Checkout", comment: "")
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = albumsTableView.cellForRow(at: indexPath) as! AlbumCell
        if !tableView.isEditing && cell.albumRemainingImagesLabel.text != "Delivery ongoing"{
            performSegue(withIdentifier: "AlbumPickImagesSegue", sender: self)
        } else if !tableView.isEditing && cell.albumRemainingImagesLabel.text == "Delivery ongoing" {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        } else if tableView.isEditing && cell.albumRemainingImagesLabel.text == "Delivery ongoing"{
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AlbumPickImagesSegue" {
            if let dest = segue.destination as? CustomAssetCellController,
                let indexPath = albumsTableView.indexPathForSelectedRow {
                let albumInfo = tableViewData[(indexPath as NSIndexPath).row]
                guard let albumName = albumInfo.keys.first else {return}
                guard let imagesRemaining = albumInfo[albumName]?.images else {return}
                dest.albumName = albumName
                dest.imagesRemaining = imagesRemaining
                dest.albumIndex = indexPath.row
            }
        } else if segue.identifier == "CheckOutSegue" {
            let dest = segue.destination as! AddressPaymentViewController
            guard let checkOutItems = self.albumsCheckedOut else {return}
            dest.albumsCheckedOut = checkOutItems
            dest.didSubmit = true
            dest.indexPathsOfCheckedOutAlbums = self.indexPathsOfCheckOutAlbums
        }
    }
    
}
