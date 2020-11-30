//
//  SelectUserTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/13/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

/// 用户选择cell
class SelectUserTableViewCell: UITableViewCell {
    
    /// 畅聊号
    @IBOutlet weak var IdLabel: UILabel!
    /// 头像
    @IBOutlet weak var headImageView: UIImageView!
    /// 选择图标
    @IBOutlet weak var selectImageView: UIImageView!
    /// 昵称
    @IBOutlet weak var nameLabel: UILabel!
    /// 下划线
    @IBOutlet weak var bottonView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
