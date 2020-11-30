//
//  BankCardInputView.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/26/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class BankCardInputView: UIView {

    lazy var title: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = DCUtill.FONTX(16)
        l.textColor = .black
        return l
    }()
    
    lazy var textFeild: UITextField = {
        let t = UITextField(frame: .zero)
        t.font = DCUtill.FONTX(16)
        t.textAlignment = .right
        t.textColor = .black
        return t
    }()
    
    lazy var line: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#DFDFDF")
        return v
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.offset()(0)
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(1))
        }
        addSubview(title)
        title.mas_makeConstraints { (make) in
            make?.top.offset()(DCUtill.SCRATIOX(15))
            make?.bottom.equalTo()(line.mas_top)
            make?.left.offset()(0)
        }
        addSubview(textFeild)
        textFeild.mas_makeConstraints { (make) in
            make?.right.right()?.bottom()?.top()?.offset()(0)
            make?.left.equalTo()(title.mas_left)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.offset()(0)
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(1))
        }
        addSubview(title)
        title.mas_makeConstraints { (make) in
            make?.top.offset()(DCUtill.SCRATIOX(15))
            make?.bottom.equalTo()(line.mas_top)
            make?.left.offset()(0)
        }
        addSubview(textFeild)
        textFeild.mas_makeConstraints { (make) in
            make?.right.right()?.bottom()?.top()?.offset()(0)
            make?.left.equalTo()(title.mas_left)
        }
    }
    
}
