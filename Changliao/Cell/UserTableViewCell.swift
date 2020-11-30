//
//  UserTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

/// 旧联系人
class UserTableViewCell: UITableViewCell {
    
    /// 畅聊号
    @IBOutlet weak var idNumberLabel: UILabel!
    /// 昵称
    @IBOutlet weak var nickNameLabel: UILabel!
    /// 头像
    @IBOutlet weak var headImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
