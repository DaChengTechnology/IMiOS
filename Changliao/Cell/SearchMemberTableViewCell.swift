//
//  SearchMemberTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 7/6/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class SearchMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        headImageView.layer.cornerRadius = 5
        headImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
