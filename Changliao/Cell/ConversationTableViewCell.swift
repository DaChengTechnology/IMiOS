//
//  ConversationTableViewCell.swift
//  boxin
//
//  Created by guduzhonglao on 6/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

/// 会话列表cell
class ConversationTableViewCell: UITableViewCell {
    /// 未读图标
    @IBOutlet weak var unReadView: UIView!
    /// 头像
    @IBOutlet weak var headImageView: UIImageView!
    /// 昵称
    @IBOutlet weak var nickNameLabel: UILabel!
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 消息预览
    @IBOutlet weak var messageLabel: UILabel!
    /// 未读标识
    @IBOutlet weak var tipsImageView: UIImageView!
    /// 在线标识
    @IBOutlet weak var onLineImageView: UIImageView!
    
    /// 工作群标识
    @IBOutlet weak var WorkImage: UIImageView!
    /// 阅后即焚标识
    @IBOutlet weak var yhjf: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
