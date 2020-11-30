//
//  FriendCircalBackgroundCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 2/21/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class FriendCircalBackgroundCell: UITableViewCell {
    
    var BGImage:UIImageView = UIImageView(image: UIImage(named: "friend_circle_defualt_bk"))
    var avatarImage:UIImageView = UIImageView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(BGImage)
        BGImage.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.contentView)
            make?.top.equalTo()(self.contentView)
            make?.right.equalTo()(self.contentView)
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(218))
            make?.bottom.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIOX(-27));
        }
        avatarImage.layer.cornerRadius = DCUtill.SCRATIOX(38)
        avatarImage.layer.masksToBounds = true
        self.contentView.addSubview(avatarImage)
        avatarImage.mas_makeConstraints { (make) in
            make?.right.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIOX(-16))
            make?.bottom.equalTo()(BGImage)?.offset()(DCUtill.SCRATIOX(24))
            make?.width.mas_equalTo()(DCUtill.SCRATIOX(76))
            make?.height.equalTo()(make?.width)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
