//
//  UserSettingTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

/// 旧设置cell
@available(*,deprecated)
class UserSettingTableViewCell: UITableViewCell {
    
    /// 内容
    @IBOutlet weak var dataLabel: UILabel!
    /// 箭头
    @IBOutlet weak var goToIcon: UIImageView!
    /// 图标
    @IBOutlet weak var settingImage: UIImageView!
    /// 标题
    @IBOutlet weak var settingTittle: UILabel!
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
