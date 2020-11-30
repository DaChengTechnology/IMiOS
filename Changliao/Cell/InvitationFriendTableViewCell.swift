//
//  InvitationFriendTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/17/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class InvitationFriendTableViewCell: UITableViewCell {
    
    /// 头像
    @IBOutlet weak var headImageView: UIImageView!
    /// 昵称
    @IBOutlet weak var nickNameLabel: UILabel!
    /// 邀请信息
    @IBOutlet weak var invitationInfoLabel: UILabel!
    /// 查看按钮
    @IBOutlet weak var lookButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headImageView.layer.cornerRadius = 4
        headImageView.layer.masksToBounds = true
        lookButton.layer.cornerRadius = 4
//        lookButton.layer.shadowOpacity = 0.35
//        lookButton.layer.shadowColor = UIColor.hexadecimalColor(hexadecimal: "464646").cgColor
        lookButton.layer.borderWidth = 1
        lookButton.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "ebebeb").cgColor
        selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
