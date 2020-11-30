//
//  MomentCommentView.swift
//  Chaangliao
//
//  Created by guduzhonglao on 5/20/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

typealias MomentCommentBlock = (String?) -> Void

class MomentCommentView: UIView,UITextFieldDelegate {
    
    var textFeild:UITextField = UITextField(frame: .zero)
    var bk:UIView = UIView(frame: .zero)
    var block:MomentCommentBlock?
    var cancel = false

    init(_ b:MomentCommentBlock?, plat:String? = nil) {
        super.init(frame: UIScreen.main.bounds)
        block = b
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dismiss)))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        bk.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "efefef")
        bk.frame = CGRect(x: 0, y: bounds.maxY - DCUtill.SCRATIOX(50), width: bounds.width, height: DCUtill.SCRATIOX(50))
        self.addSubview(bk)
        textFeild.font = DCUtill.FONTX(16)
        textFeild.textColor = .black
        if (plat?.isEmpty ?? true) {
            textFeild.placeholder = "说点什么吧"
        }else{
           textFeild.placeholder = "回复 \(plat ?? "")"
        }
        textFeild.delegate = self
        textFeild.returnKeyType = .send
        textFeild.backgroundColor = .white
        bk.addSubview(textFeild)
        textFeild.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(16))
            make?.top.offset()(DCUtill.SCRATIOX(5))
            make?.right.offset()(DCUtill.SCRATIOX(-16))
            make?.bottom.offset()(DCUtill.SCRATIOX(-5))
        }
//        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillShowNotification, object: nil, queue: .main) { (n) in
//            n.userInfo[
//        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func dismiss() {
        if textFeild.isFirstResponder {
            cancel = true
            textFeild.endEditing(true)
        }
        self.removeFromSuperview()
    }
    
    func show() {
        if let nav = UIViewController.currentViewController()?.navigationController {
            nav.view.addSubview(self)
        }else{
            UIViewController.currentViewController()?.view.addSubview(self)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.textFeild.becomeFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if cancel {
            return
        }
        if let b = block {
            b(textField.text)
        }
        dismiss()
    }
}
