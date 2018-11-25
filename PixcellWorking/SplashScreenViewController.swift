//
//  SplashScreenViewController.swift
//  PixcellWorking
//
//  Created by Nahar Alamoudi on 11/15/18.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit
import Firebase

class SplashScreenViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let currentUser = Auth.auth().currentUser
        if launch == "First launch" {
            launch = "Has launched before"
            self.walkThrough()
        } else if currentUser != nil && (currentUser?.isEmailVerified)!{
            loadHomeScreen()
        } else {
            loadLoginPage()
        }
    }
    
    func loadLoginPage() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let LoginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        // Change the above back
        self.present(LoginViewController, animated: true, completion: nil)
    }
    
    func loadHomeScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loggedInViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        // Change the above back
        self.present(loggedInViewController, animated: true, completion: nil)
    }
    
    func walkThrough() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let MainViewController = storyBoard.instantiateViewController(withIdentifier: "walkThrough")
        // Change the above back
        self.present(MainViewController, animated: false, completion: nil)
    }
        

        // Do any additional setup after loading the view.
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


