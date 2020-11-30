//
//  FriendGroupTitleCell.swift
//  boxin
//
//  Created by guduzhonglao on 11/13/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class FriendGroupTitleCell: UITableViewCell {
    
    var groupImage:UIImageView = UIImageView(image: UIImage(named: "friend_hide"))
    var groupTitle:UILabel = UILabel(frame: CGRect.zero)
    var groupCount:UILabel = UILabel(frame: CGRect.zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(groupImage)
        groupImage.mas_makeConstraints { (make) in
            make?.right.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: -23))
            make?.centerY.equalTo()(self.contentView)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 17))
            make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 17))
        }
        groupTitle.font = DCUtill.FONT(x: 17)
        groupTitle.textColor = UIColor.hexadecimalColor(hexadecimal: "#000527")
        self.contentView.addSubview(groupTitle)
        groupTitle.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: 23))
            make?.centerY.equalTo()(self.contentView)
        }
        groupCount.font = DCUtill.FONT(x: 13)
        groupCount.textColor = UIColor.hexadecimalColor(hexadecimal: "#979797")
        self.contentView.addSubview(groupCount)
        groupCount.mas_makeConstraints { (make) in
            make?.right.equalTo()(groupImage.mas_left)?.offset()(DCUtill.SCRATIO(x: -8))
            make?.centerY.equalTo()(self.contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setShow(show:Bool){
        if show {
            groupImage.image = UIImage(named: "friend_show")
            groupImage.mas_remakeConstraints { (make) in
                make?.right.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: -23))
                make?.centerY.equalTo()(self.contentView)
                make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 7))
                make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 12))
            }
        }else{
            groupImage.image = UIImage(named: "friend_hide")
            groupImage.mas_remakeConstraints { (make) in
                make?.right.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: -23))
                make?.centerY.equalTo()(self.contentView)
                make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 12))
                make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 7))
            }
        }
    }

}
