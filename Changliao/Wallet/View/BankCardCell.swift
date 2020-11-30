//
//  BankCardCell.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/25/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class BankCardCell: UITableViewCell {

    var model:BankCardData?{
        didSet{
            setModel()
        }
    }
    
    lazy var bankImaage: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.layer.cornerRadius = DCUtill.SCRATIOX(25)
        iv.layer.masksToBounds = true
        return iv
    }()
    
    lazy var bankName: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = DCUtill.FONT(x: 16)
        l.textColor = .white
        return l
    }()
    
    lazy var cardNumber: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = UIFont.boldSystemFont(ofSize: DCUtill.SCRATIOX(16))
        l.textColor = .white
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.contentView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "a8452e")
        self.selectionStyle = .none
        self.contentView.addSubview(bankImaage)
        bankImaage.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(50))
            make?.top.offset()(DCUtill.SCRATIOX(5))
            make?.bottom.offset()(DCUtill.SCRATIOX(-5))
            make?.width.height()?.mas_equalTo()(DCUtill.SCRATIOX(50))
        }
        self.contentView.addSubview(bankName)
        bankName.mas_makeConstraints { (make) in
            make?.left.equalTo()(bankImaage.mas_right)?.offset()(DCUtill.SCRATIOX(10))
            make?.top.equalTo()(bankImaage)
        }
        self.contentView.addSubview(cardNumber)
        cardNumber.mas_makeConstraints { (make) in
            make?.left.equalTo()(bankImaage.mas_right)?.offset()(DCUtill.SCRATIOX(10))
            make?.bottom.equalTo()(bankImaage)
        }
    }
    
    func setModel() {
        bankImaage.sd_setImage(with: URL(string: model?.bank_pic ?? ""), completed: nil)
        bankName.text = model?.bank_name
        cardNumber.text = model?.bank_card_number?.addBlank()
    }

}
