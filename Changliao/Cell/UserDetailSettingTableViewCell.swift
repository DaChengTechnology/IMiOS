//
//  UserDetailSettingTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

/// 设置开关cell
class UserDetailSettingTableViewCell: UITableViewCell {
    /// 标题
    @IBOutlet weak var tittleLable: UILabel!
    /// 开关
    @IBOutlet weak var settingSwitch: UISwitch!
    /// 菊花
    @IBOutlet weak var setting: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setting.isHidden = true
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
