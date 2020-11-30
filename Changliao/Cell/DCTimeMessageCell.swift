//
//  DCTimeMessageCell.swift
//  boxin
//
//  Created by guduzhonglao on 8/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class DCTimeMessageCell: UITableViewCell {
    
    var timeBackView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    var timeLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        timeBackView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#DBDADA")
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        timeBackView.layer.cornerRadius = 5
        self.contentView.addSubview(timeBackView)
        timeBackView.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(self.contentView)
            make?.centerY.equalTo()(self.contentView)
        }
        timeLabel.font = DCUtill.FONT(x: 10)
        timeLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#626161")
        timeBackView.addSubview(timeLabel)
        timeLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(timeBackView)?.offset()(7)
            make?.top.equalTo()(timeBackView)?.offset()(3)
            make?.right.equalTo()(timeBackView)?.offset()(-7)
            make?.bottom.equalTo()(timeBackView)?.offset()(-4)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func cellForHeight() -> CGFloat {
        return 30
    }
    
    static func cellID() -> String {
        return "DCTime"
    }

}
