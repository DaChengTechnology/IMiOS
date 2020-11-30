//
//  DeleteFriendTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/21/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class DeleteFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var tittleImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
