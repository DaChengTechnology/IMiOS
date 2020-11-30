//
//  MomentFooterYearView.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/24/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class MomentFooterYearView: UICollectionReusableView {
    lazy var year: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = DCUtill.FONTX(24)
        l.textColor = .black
        return l
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.addSubview(year)
        year.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(17))
            make?.top.offset()(DCUtill.SCRATIOX(15))
            make?.bottom.offset()(DCUtill.SCRATIOX(-15))
        }
    }
}
