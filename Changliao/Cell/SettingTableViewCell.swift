//
//  SettingTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

/// 旧设置
class SettingTableViewCell: UITableViewCell {
    
    /// 图标
    @IBOutlet weak var settingImage: UIImageView!
    /// 标题
    @IBOutlet weak var settingLable: UILabel!
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
