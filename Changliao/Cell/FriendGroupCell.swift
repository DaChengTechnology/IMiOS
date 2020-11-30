//
//  FriendGroupCell.swift
//  boxin
//
//  Created by guduzhonglao on 11/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

class FriendGroupCell: UITableViewCell {
    
    var groupNameLable:UILabel = UILabel(frame: .zero)
    
    var haveImage:UIImageView = UIImageView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        groupNameLable.font = DCUtill.FONT(x: 17)
        groupNameLable.textColor = UIColor.black
        self.contentView.addSubview(groupNameLable)
        groupNameLable.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: 15))
            make?.centerY.equalTo()(self.contentView)
        }
        self.contentView.addSubview(haveImage)
        haveImage.mas_makeConstraints { (make) in
            make?.right.equalTo()(self.contentView)?.offset()(DCUtill.SCRATIO(x: -15))
            make?.centerY.equalTo()(self.contentView)
            make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 21))
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 15))
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
