//
//  GroupInfoTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class GroupInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var Jiantou: UIImageView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var contextLabel: UILabel!
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
