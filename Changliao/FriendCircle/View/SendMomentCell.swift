//
//  SendMomentCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/22/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class SendMomentCell: UICollectionViewCell {
    
    lazy var image:UIImageView = {
        let iv = UIImageView(frame: CGRect(x: DCUtill.SCRATIOX(9), y: DCUtill.SCRATIOX(9), width: DCUtill.SCRATIOX(108), height: DCUtill.SCRATIOX(108)))
        return iv
    }()
    
    lazy var close:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "deletePic"), for: .normal)
        return btn
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
        self.contentView.addSubview(image)
        self.contentView.addSubview(close)
        resetCell()
    }
    
    func resetCell() {
        close.isHidden = false
        close.setImage(UIImage(named: "deletePic"), for: .normal)
        close.mas_remakeConstraints { (makw) in
            makw?.top.right()?.offset()(0)
            makw?.width.height()?.mas_equalTo()(DCUtill.SCRATIOX(18))
        }
    }
    
}
