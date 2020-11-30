//
//  NewFriendGroupAlert.swift
//  boxin
//
//  Created by guduzhonglao on 11/14/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol NewFriendGroupDelefate {
    func CreatedFriendGroup(_ info:FriendGroupInfoData?)
}

class NewFriendGroupAlert: UIView,UITextFieldDelegate {

    var bk:UIView = UIView(frame: CGRect.zero)
    let textFeild = UITextField(frame: CGRect.zero)
    var isLoading = false
    var delegate:NewFriendGroupDelefate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupUI() {
        bk.frame = UIScreen.main.bounds
        bk.backgroundColor = UIColor.black
        bk.layer.opacity = 0.5
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = DCUtill.SCRATIO(x: 5)
        self.layer.masksToBounds = true
        let title = UILabel(frame: CGRect.zero)
        title.textColor = UIColor.hexadecimalColor(hexadecimal: "#333333")
        title.text = "添加分组"
        title.font = DCUtill.FONT(x: 17)
        self.addSubview(title)
        title.mas_makeConstraints { (make) in
            make?.top.equalTo()(self)?.offset()(DCUtill.SCRATIO(x: 25.5))
            make?.centerX.equalTo()(self)
        }
        let inputBorder = UIView(frame: .zero)
        textFeild.delegate = self
        textFeild.placeholder = "分组名"
        textFeild.borderStyle = .none
        textFeild.backgroundColor = UIColor.white
        inputBorder.layer.borderWidth = DCUtill.SCRATIO(x: 0.5)
        inputBorder.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "#CCCCCC").cgColor
        inputBorder.layer.cornerRadius = DCUtill.SCRATIO(x: 5)
        self.addSubview(inputBorder)
        inputBorder.mas_makeConstraints { (make) in
            make?.left.equalTo()(self)?.offset()(DCUtill.SCRATIO(x: 25))
            make?.top.equalTo()(title.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 20.5))
            make?.right.equalTo()(self)?.offset()(DCUtill.SCRATIO(x: -25))
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 45))
        }
        inputBorder.addSubview(textFeild)
        textFeild.mas_makeConstraints { (make) in
            make?.left.equalTo()(inputBorder)?.offset()(DCUtill.SCRATIO(x: 11))
            make?.top.equalTo()(inputBorder)
            make?.right.equalTo()(inputBorder)?.offset()(DCUtill.SCRATIO(x: -11))
            make?.bottom.equalTo()(inputBorder)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (n) in
            let userinfo = n.userInfo
            let endFrame = userinfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            let durent = userinfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            if endFrame?.origin.y == UIScreen.main.bounds.height {
                UIView.animate(withDuration: durent ?? 0) {
                    self.center = UIApplication.shared.keyWindow?.center ??  CGPoint.zero
                }
            }else{
                UIView.animate(withDuration: durent ?? 0) {
                    self.center = CGPoint(x: UIScreen.main.bounds.width/2, y: DCUtill.SCRATIO(x: 200))
                }
            }
        }
        let line = UIView(frame: CGRect.zero)
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#CCCCCC")
        self.addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.equalTo()(self)
            make?.bottom.equalTo()(self)?.offset()(DCUtill.SCRATIO(x:-54.5))
            make?.right.equalTo()(self)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 0.5))
        }
        let cancel = UIButton(type: .custom)
        cancel.setTitle(NSLocalizedString("Cancel",  comment: "Cancel"), for: .normal)
        cancel.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#333333"), for: .normal)
        cancel.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        self.addSubview(cancel)
        let ok = UIButton(type: .custom)
        ok.setTitle("添加", for: .normal)
        ok.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#333333"), for: .normal)
        ok.addTarget(self, action: #selector(onOK), for: .touchUpInside)
        self.addSubview(ok)
        cancel.mas_makeConstraints { (make) in
            make?.left.equalTo()(self)
            make?.top.equalTo()(line.mas_bottom)
            make?.right.equalTo()(ok.mas_left)
            make?.width.equalTo()(ok)
            make?.bottom.equalTo()(self)
        }
        ok.mas_makeConstraints { (make) in
            make?.left.equalTo()(cancel.mas_right)
            make?.top.equalTo()(line.mas_bottom)
            make?.right.equalTo()(self)
            make?.width.equalTo()(cancel)
            make?.bottom.equalTo()(self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func onCancel() {
        dismiss()
    }
    
    @objc func onOK() {
        self.endEditing(true)
        if textFeild.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "请填写分组名", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: nil))
            UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
            return
        }
        if textFeild.text?.count ?? 0 > 10 {
            let alert = UIAlertController(title: "分组名不能长于10个字", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: nil))
            UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
            return
        }
        if isLoading {
            return
        }
        isLoading = true
        SVProgressHUD.show()
        let model = AddFenzuSendModel()
        model.fenzu_name = textFeild.text
        BoXinProvider.request(.AddFenzu(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    if let model = AddFenzuReciveModel.deserialize(from: try? res.mapString()) {
                        if model.code == 200 {
                            self.delegate?.CreatedFriendGroup(model.data)
                            self.dismiss()
                        }else{
                            self.isLoading = false
                            SVProgressHUD.dismiss()
                            UIApplication.shared.keyWindow?.makeToast(model.message)
                        }
                    }else{
                        self.isLoading = false
                        SVProgressHUD.dismiss()
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                    }
                }else{
                    self.isLoading = false
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast("服务器连接失败")
                }
            case .failure(_):
                self.isLoading = false
                SVProgressHUD.dismiss()
                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
            }
        }
    }
    
    func show() {
        UIViewController.currentViewController()?.navigationController?.view?.addSubview(self.bk)
        bk.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.bk.superview)
            make?.top.equalTo()(self.bk.superview)
            make?.right.equalTo()(self.bk.superview)
            make?.bottom.equalTo()(self.bk.superview)
        }
        UIViewController.currentViewController()?.navigationController?.view?.addSubview(self)
        self.frame = CGRect(x: 0, y: 0, width: DCUtill.SCRATIO(x: 300), height: DCUtill.SCRATIO(x: 200))
        self.center = self.superview?.center ?? CGPoint.zero
//        self.mas_makeConstraints { (make) in
//            make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 300))
//            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 200))
//            make?.center.equalTo()(self.superview)
//        }
    }
    
    func dismiss() {
        self.endEditing(true)
        bk.removeFromSuperview()
        self.removeFromSuperview()
    }

}
