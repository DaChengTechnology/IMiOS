//
//  MomentFooterView.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/26/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class MomentFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let line = UIView(frame: .zero)
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EBEBEB")
        self.addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.offset()(0)
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(1))
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let line = UIView(frame: .zero)
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EBEBEB")
        self.addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.offset()(0)
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(1))
        }
    }
}
