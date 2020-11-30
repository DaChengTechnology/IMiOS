//
//  DIYFaceMessageCell.swift
//  boxin
//
//  Created by guduzhonglao on 7/19/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import Masonry

class DIYFaceMessageCell: EaseMessageCell {
    
    var gifImageView:UIImageView

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init!(style: UITableViewCell.CellStyle, reuseIdentifier: String!, model: IMessageModel!) {
        gifImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        super.init(style: style, reuseIdentifier: reuseIdentifier, model: model)
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        self.model = model
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        gifImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        super.init(coder: aDecoder)
    }
    
    override func isCustomBubbleView(_ model: Any!) -> Bool {
        return true
    }
    
    func setup() {
        if model.isSender {
            initSender()
        }else{
            initReciver()
        }
    }
    
    override func setCustomBubbleView(_ model: Any!) {
        bubbleView.setupGifBubbleView()
    }
    
    func initSender() {
        avatarView.layer.cornerRadius = 8
        avatarView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(EaseMessageCellPadding)
            make?.right.equalTo()(self.contentView.mas_right)?.offset()(0-EaseMessageCellPadding)
            make?.height.mas_equalTo()(40)
            make?.width.mas_equalTo()(40)
        }
        if model.avatarURLPath.count > 0 {
            avatarView.sd_setImage(with: URL(string: model.avatarURLPath), placeholderImage: model.avatarImage)
        }else{
            avatarView.image = model.avatarImage
        }
        bubbleView.isHidden = true
        gifImageView.removeFromSuperview()
        self.contentView.addSubview(gifImageView)
        gifImageView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(EaseMessageCellPadding + 15)
            make?.right.equalTo()(avatarView.mas_left)?.offset()(-EaseMessageCellPadding)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-EaseMessageCellPadding)
            make?.height.mas_equalTo()(150)
            make?.width.mas_equalTo()(150)
        }
        gifImageView.sd_setImage(with: URL(string: model.message.ext!["jpzim_big_expression_path"] as! String))
    }
    
    func initReciver() {
        avatarView.layer.cornerRadius = 8
        avatarView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.contentView.mas_top)?.offset()(EaseMessageCellPadding)
            make?.left.equalTo()(self.contentView.mas_left)?.offset()(EaseMessageCellPadding)
            make?.height.mas_equalTo()(40)
            make?.width.mas_equalTo()(40)
        }
        self.contentView.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.contentView.mas_top)
            make?.left.equalTo()(avatarView.mas_right)?.offset()(EaseMessageCellPadding)
            make?.height.mas_equalTo()(15)
        }
        if model.avatarURLPath.count > 0 {
            avatarView.sd_setImage(with: URL(string: model.avatarURLPath), placeholderImage: model.avatarImage)
        }else{
            avatarView.image = model.avatarImage
        }
        nameLabel.font = UIFont.systemFont(ofSize: 10)
        nameLabel.textColor = UIColor.gray
        nameLabel.text = model.nickname
        bubbleView.isHidden = true
        gifImageView.removeFromSuperview()
        self.contentView.addSubview(gifImageView)
        gifImageView.mas_makeConstraints { (make) in
            make?.top.equalTo()(nameLabel.mas_bottom)
            make?.left.equalTo()(avatarView.mas_right)?.offset()(EaseMessageCellPadding)
            make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(-EaseMessageCellPadding)
            make?.height.mas_equalTo()(150)
            make?.width.mas_equalTo()(150)
        }
        gifImageView.sd_setImage(with: URL(string: model.message.ext!["jpzim_big_expression_path"] as! String))
    }
    
    override func setCustomModel(_ model: Any!) {
//        super.setCustomModel(model)
    }
    
    override func updateCustomBubbleViewMargin(_ bubbleMargin: UIEdgeInsets, model mode: Any!) {
        
    }
    
    static func cellH(model: IMessageModel!) -> CGFloat {
        return 150 + 15 + EaseMessageCellPadding * 2
    }
    
}
