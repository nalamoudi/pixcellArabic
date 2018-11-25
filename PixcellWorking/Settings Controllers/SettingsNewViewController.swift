//
//  SettingsNewViewController.swift
//  PixcellWorking
//
//  Created by Nahar Alamoudi on 11/14/18.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class SettingsNewViewController: UIViewController {

    //Outlets
    @IBOutlet weak var settingsTableView: UITableView!
    
    // Constants
    let cellTableCellID = "settingsCell"
    
    let settingsMenu = [
        NSLocalizedString("Change Language", comment: "Language Cell"), NSLocalizedString("Terms & Conditions", comment: "Terms Cell"), NSLocalizedString("Privacy Policy", comment: "Privacy Cell"), NSLocalizedString("Contact Us", comment: "Contact Cell"), NSLocalizedString("FAQs", comment: "FAQs Cell")]
    
    // Variables
    //var settingsMenu = ["Change Language", "Terms & Conditions", "Privacy Policy", "Contact Us","FAQs"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let index = self.settingsTableView.indexPathForSelectedRow{
            self.settingsTableView.deselectRow(at: index, animated: true)
        }
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            loadLoginScreen()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func loadLoginScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "LoginNavController") as! UINavigationController
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    func callDelegates () {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }


}

extension SettingsNewViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsMenu.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: cellTableCellID) as! settingsCellView
            settingsTableView.isScrollEnabled = false
            cell.configureCell(name:self.settingsMenu[indexPath.row])
            self.settingsTableView.tableFooterView = UIView(frame: CGRect.zero)
            return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let settingsTitle = NSLocalizedString("Settings", comment: "Settings Title")
            return settingsTitle
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("it is executing till here")
        if segue.identifier != "settingsPasser" { return }
        if let dest = segue.destination as? SettingsDetailViewController,
            let indexPath = settingsTableView.indexPathForSelectedRow {
            dest.settingsString = settingsMenu[(indexPath as NSIndexPath).row]
        }
    }
    
}
