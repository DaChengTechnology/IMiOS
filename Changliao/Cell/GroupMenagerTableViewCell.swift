//
//  GroupMenagerTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/24/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class GroupMenagerTableViewCell: UITableViewCell {
    @IBOutlet weak var headImageView: UIImageView!
    
    
    
   
    @IBOutlet weak var settingSwitch: UISwitch!
    
    @IBOutlet weak var setting: UIActivityIndicatorView!
    @IBOutlet weak var nickNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 5
        setting.isHidden = true
        selectionStyle = .none
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
