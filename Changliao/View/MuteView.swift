//
//  MuteView.swift
//  boxin
//
//  Created by guduzhonglao on 6/21/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class MuteView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let muteLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        muteLabel.font = UIFont.systemFont(ofSize: 15)
        muteLabel.text = "禁言"
        self.addSubview(muteLabel)
        muteLabel.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(self.mas_centerX)
            make?.centerY.equalTo()(self.mas_centerY)
        }
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
