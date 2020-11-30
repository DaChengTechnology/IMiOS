//
//  NewGroupListTableViewCell.swift
//  boxin
//
//  Created by Sea on 2019/7/7.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class NewGroupListTableViewCell: UITableViewCell {

    @IBOutlet weak var NameLab: UILabel!
    @IBOutlet weak var WorkImage: UIImageView!
    @IBOutlet weak var HeadImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        HeadImage.layer.cornerRadius = 25
        HeadImage.layer.masksToBounds = true
        self.selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
