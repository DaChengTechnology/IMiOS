//
//  AddContentTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 7/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class AddContentTableViewCell: UITableViewCell {
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var tittleImageView: UIImageView!
    @IBOutlet weak var tittleLable: UILabel!
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
