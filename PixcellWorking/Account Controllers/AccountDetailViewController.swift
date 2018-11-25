//
//  AccountDetailViewController.swift
//  PixcellWorking
//
//  Created by Nahar Alamoudi on 11/6/18.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController {
    
    var accountString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    


}
