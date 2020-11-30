//
//  DiscoveryCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 2/19/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class DiscoveryCell: UITableViewCell {
    
    var titleLabel:UILabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        let image = UIImageView(image: UIImage(named: "friend_hide"))
        self.contentView.addSubview(image)
        image.mas_makeConstraints { (make) in
            make?.width.mas_equalTo()(DCUtill.SCRATIOX(7))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(12))
            make?.right.offset()(DCUtill.SCRATIOX(-16))
            make?.centerY.equalTo()(self.contentView)
        }
        titleLabel.font=UIFont.systemFont(ofSize: 20)
        titleLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#000527");
        self.contentView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(40))
            make?.centerY.equalTo()(self.contentView)
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
