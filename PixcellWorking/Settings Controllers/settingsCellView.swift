//
//  settingsCellViewTableViewCell.swift
//  PixcellWorking
//
//  Created by Nahar Alamoudi on 11/14/18.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

import UIKit

class settingsCellView: UITableViewCell {

    @IBOutlet weak var settingsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(name: String){
        settingsLabel?.text = name
    }

}
