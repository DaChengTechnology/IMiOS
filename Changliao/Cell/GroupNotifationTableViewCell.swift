//
//  GroupNotifationTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 8/3/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class GroupNotifationTableViewCell: UITableViewCell {
    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var groupMSGLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
