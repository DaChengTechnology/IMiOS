//
//  AddBankCardViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/26/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class AddBankCardViewController: UIViewController,UITextFieldDelegate {
    
    lazy var bk: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = .white
        return v
    }()
    lazy var name: BankCardInputView = {
        let b = BankCardInputView()
        b.title.text = "真是姓名"
        b.textFeild.placeholder = "请输入您的真实姓名"
        return b
    }()
    lazy var cardNumber: BankCardInputView = {
        let b = BankCardInputView()
        b.title.text = "银行卡号"
        b.textFeild.placeholder = "请输入您的银行卡号"
        return b
    }()
    lazy var id_card: BankCardInputView = {
        let b = BankCardInputView()
        b.title.text = "身份证号"
        b.textFeild.placeholder = "请输入您的身份证号"
        return b
    }()
    lazy var tips: UILabel = {
        let t = UILabel(frame: .zero)
        t.text = "温馨提示：第一次绑定银行卡，请输入持卡人真实姓名"
        t.font = DCUtill.FONTX(14)
        t.textColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        return t
    }()
    lazy var ok: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = .white
        b.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        b.setTitle("确定", for: .normal)
        b.layer.cornerRadius = DCUtill.SCRATIOX(22)
        b.layer.masksToBounds = true
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#F1F1F1")
        self.navigationItem.title = "绑定银行卡"
        self.view.addSubview(bk)
        bk.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()(DCUtill.SCRATIOX(10))
            make?.left.right()?.bottom()?.offset()(0)
        }
        name.textFeild.tag = 1
        name.textFeild.delegate = self
        bk.addSubview(name)
        name.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(28))
            make?.right.offset()(DCUtill.SCRATIOX(-28))
            make?.top.offset()(DCUtill.SCRATIOX(13))
        }
        cardNumber.textFeild.tag = 2
        cardNumber.textFeild.delegate = self
        bk.addSubview(cardNumber)
        cardNumber.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(28))
            make?.right.offset()(DCUtill.SCRATIOX(-28))
            make?.top.equalTo()(name.mas_bottom)?.offset()(DCUtill.SCRATIOX(5))
        }
        id_card.textFeild.tag = 1
        id_card.textFeild.delegate = self
        bk.addSubview(id_card)
        id_card.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(28))
            make?.right.offset()(DCUtill.SCRATIOX(-28))
            make?.top.equalTo()(id_card.mas_bottom)?.offset()(DCUtill.SCRATIOX(5))
        }
        bk.addSubview(tips)
        tips.mas_makeConstraints { (make) in
            make?.top.equalTo()(id_card.mas_bottom)?.offset()(DCUtill.SCRATIOX(28))
            make?.centerX.equalTo()(bk)
        }
        ok.addTarget(self, action: #selector(onOK), for: .touchUpInside)
        bk.addSubview(ok)
        ok.mas_makeConstraints { (make) in
            make?.top.equalTo()(tips)?.offset()(DCUtill.SCRATIOX(61))
            make?.left.offset()(DCUtill.SCRATIOX(28))
            make?.right.offset()(DCUtill.SCRATIOX(-28))
            make?.height.mas_equalTo()(DCUtill.SCRATIOX(44))
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func onOK() {
        if name.textFeild.text?.isEmpty ?? true {
            self.view.makeToast("请输入您的真实姓名")
            return
        }
        if cardNumber.textFeild.text?.isEmpty ?? true {
            self.view.makeToast("请输入您的银行卡号")
            return
        }
        if id_card.textFeild.text?.isEmpty ?? true {
            self.view.makeToast("请输入您的身份证号")
            return
        }
    }

}
