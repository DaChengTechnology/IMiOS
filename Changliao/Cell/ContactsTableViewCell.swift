//
//  ContactsTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/9/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

/// 联系人cell
class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var shortBottonView: UIView!
    @IBOutlet weak var Idlabel: UILabel!
    @IBOutlet weak var bottonView: UIView!
    @IBOutlet weak var headImgView: MGAvatarImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var Jiantou: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        headImgView.layer.cornerRadius = 5
        headImgView.layer.masksToBounds = true
        shortBottonView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
