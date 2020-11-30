//
//  NewGroupUnmemberTableViewCell.swift
//  boxin
//
//  Created by Sea on 2019/7/8.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class NewGroupUnmemberTableViewCell: UITableViewCell {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var groupOwnerLable: UILabel!
    @IBOutlet weak var nickNameLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        groupOwnerLable.layer.masksToBounds = true
        groupOwnerLable.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
