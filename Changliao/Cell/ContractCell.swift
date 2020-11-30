//
//  ContractCell.swift
//  boxin
//
//  Created by guduzhonglao on 8/3/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class ContractCell: UITableViewCell {

    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var bottonView: UIView!
    @IBOutlet weak var shortBottonView: UIView!
    @IBOutlet weak var idCaardLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 22
        idCaardLabel.font = DCUtill.FONT(x: 13)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
