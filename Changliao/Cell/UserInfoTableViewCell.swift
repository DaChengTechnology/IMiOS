//
//  UserInfoTableViewCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 1/20/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var avaterImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var idCardLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avaterImageView.layer.cornerRadius = 45
        avaterImageView.layer.masksToBounds=true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
