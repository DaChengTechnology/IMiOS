//
//  InvitationFriendDetailViewController.swift
//  boxin
//
//  Created by guduzhonglao on 8/22/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage

class InvitationFriendDetailViewController: UIViewController {
    var model:GetUserData?
    var idCardLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var agreeBtn = UIButton(type: .custom)
    var disagreeBtn = UIButton(type: .custom)
    var buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        topView.backgroundColor = UIColor.white
        self.view.addSubview(topView)
        topView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_left)
            if #available(iOS 11.0, *) {
                make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            } else {
                // Fallback on earlier versions
                make?.top.equalTo()(self.view)
            }
            make?.right.equalTo()(self.view.mas_right)
        }
        let headImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        headImageView.sd_setImage(with: URL(string: model?.portrait ?? ""), placeholderImage: UIImage(named: "moren"), options: .retryFailed, context: nil)
        headImageView.layer.cornerRadius = 10
        headImageView.layer.masksToBounds = true
        topView.addSubview(headImageView)
        headImageView.mas_makeConstraints { (make) in
            make?.top.equalTo()(topView.mas_top)?.offset()(DCUtill.SCRATIO(x: 19))
            make?.left.equalTo()(topView.mas_left)?.offset()(DCUtill.SCRATIO(x: 22))
            make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 64))
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 64))
        }
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.textColor = UIColor.black
        nameLabel.text = model?.user_name
        nameLabel.numberOfLines = 1
        topView.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(DCUtill.SCRATIO(x: 13))
            make?.top.equalTo()(headImageView.mas_top)?.offset()(DCUtill.SCRATIO(x: 13))
            make?.right.lessThanOrEqualTo()(topView.mas_right)?.offset()(DCUtill.SCRATIO(x: -22))
        }
        idCardLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#8A8888")
        idCardLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", model?.id_card ?? "")
        idCardLabel.font = UIFont.systemFont(ofSize: 13)
        topView.addSubview(idCardLabel)
        idCardLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(14)
            make?.top.equalTo()(nameLabel.mas_bottom)?.offset()(11)
        }
        let verifyView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        verifyView.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "e5e5e5").cgColor
        verifyView.layer.borderWidth = 1
        verifyView.layer.cornerRadius = 5
        verifyView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        topView.addSubview(verifyView)
        verifyView.mas_makeConstraints { (make) in
            make?.left.equalTo()(topView.mas_left)?.offset()(DCUtill.SCRATIO(x: 38))
            make?.top.equalTo()(headImageView.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 20))
            make?.right.equalTo()(topView.mas_right)?.equalTo()(DCUtill.SCRATIO(x: -38))
            make?.bottom.equalTo()(topView.mas_bottom)?.offset()(DCUtill.SCRATIO(x: -32))
        }
        let verifyTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        verifyTitleLabel.text = "验证信息:"
        verifyTitleLabel.font = UIFont.systemFont(ofSize: 14)
        verifyTitleLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "797979")
        verifyView.addSubview(verifyTitleLabel)
        verifyTitleLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(verifyView.mas_left)?.offset()(15)
            make?.top.equalTo()(verifyView.mas_top)?.offset()(12)
        }
        let verifyInfoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        verifyInfoLabel.text = String(format: " %@", model?.remark ?? "")
        verifyInfoLabel.font = UIFont.systemFont(ofSize: 14)
        verifyInfoLabel.numberOfLines = 0
        verifyInfoLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#ACABAB")
        verifyView.addSubview(verifyInfoLabel)
        verifyInfoLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(verifyView.mas_left)?.offset()(16)
            make?.top.equalTo()(verifyTitleLabel.mas_bottom)?.offset()(12)
            make?.right.lessThanOrEqualTo()(verifyView.mas_right)?.offset()(-16)
            make?.bottom.equalTo()(verifyView.mas_bottom)?.offset()(-22)
        }
        
        agreeBtn.backgroundColor = UIColor.white
        agreeBtn.setTitle("通过验证", for: .normal)
        agreeBtn.titleLabel?.font = DCUtill.FONT(x: 17)
        agreeBtn.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "#EC582E"), for: .normal)
        agreeBtn.addTarget(self, action: #selector(onAgree), for: .touchUpInside)
        self.view.addSubview(agreeBtn)
        let line = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#d8d8d8")
        self.view.addSubview(line)
        disagreeBtn.backgroundColor = UIColor.white
        disagreeBtn.titleLabel?.font = DCUtill.FONT(x: 17)
        disagreeBtn.setTitle("拒绝此人", for: .normal)
        disagreeBtn.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "ec582e"), for: .normal)
        disagreeBtn.addTarget(self, action: #selector(onDisagree), for: .touchUpInside)
        self.view.addSubview(disagreeBtn)
        agreeBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_left)
            make?.top.equalTo()(topView.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 10))
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 55))
            make?.right.equalTo()(self.view.mas_right)
        }
        line.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(agreeBtn.mas_bottom)
            make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 1))
        }
        disagreeBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_left)
            make?.top.equalTo()(line.mas_bottom)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 55))
            make?.right.equalTo()(self.view.mas_right)
        }
        self.title = "验证信息"
        self.navigationItem.title = self.title
        if model?.id_card == nil {
            loadNumber()
        }
    }
    
    func loadNumber() {
        let model = GetUserByIDSendModel()
        model.user_id = self.model?.user_id
        BoXinProvider.request(.GetUserByID(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let md = GetUserByIDReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(md.code ?? 0) else {
                                return
                            }
                            if md.code == 200 {
                                self.idCardLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", md.data?.id_card ?? "")
                            }else{
                                if md.message == "请重新登录" {
                                    BoXinUtil.Logout()
                                    if (UIViewController.currentViewController() as? BootViewController) != nil {
                                        let app = UIApplication.shared.delegate as! AppDelegate
                                        app.isNeedLogin = true
                                        return
                                    }
                                    if let vc = UIViewController.currentViewController() as? WelcomeViewController {
                                        return
                                    }
                                    if UIViewController.currentViewController() is LoginPhoneViewController {
                                        return
                                    }
                                    if UIViewController.currentViewController() is LoginPasswordViewController {
                                        return
                                    }
                                    if UIViewController.currentViewController() is RegisterViewController {
                                        return
                                    }
                                    let sb = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                    vc.modalPresentationStyle = .overFullScreen
                                    self.present(vc, animated: false, completion: nil)
                                }
                                self.view.makeToast(md.message)
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                    }
                }else{
                    print(res.statusCode)
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                print(err.errorDescription)
            }
        }
    }
    
    @objc func onAgree() {
        if isLoading {
            return
        }
        isLoading = true
        let mo = ApplyForSendModel()
        mo.target_user_id = model?.user_id
        BoXinProvider.request(.AgreeApplyForUser(model: mo)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                let err = EMClient.shared()?.contactManager.acceptInvitation(forUsername: mo.target_user_id!)
                                if err == nil {
                                    BoXinUtil.getFriends(nil)
                                    self.view.makeToast(NSLocalizedString("AddSuccessed", comment: "Add successed"))
                                    self.navigationController?.popViewController(animated: true)
                                    self.isLoading = false
                                }else{
                                    self.view.makeToast(NSLocalizedString("AddFalied", comment: "Add falied"))
                                    self.isLoading = false
                                }
                                let app = UIApplication.shared.delegate as! AppDelegate
                                if app.addFriendCount > 0 {
                                    app.addFriendCount -= 1
                                }
                                self.isLoading = false
                            }else{
                                if model.message == "请重新登录" {
                                    BoXinUtil.Logout()
                                    if (UIViewController.currentViewController() as? BootViewController) != nil {
                                        let app = UIApplication.shared.delegate as! AppDelegate
                                        app.isNeedLogin = true
                                        return
                                    }
                                    if let vc = UIViewController.currentViewController() as? WelcomeViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is LoginPhoneViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is LoginPasswordViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is RegisterViewController {
                                                    return
                                                }
                                    let sb = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                    vc.modalPresentationStyle = .overFullScreen
                                    self.present(vc, animated: false, completion: nil)
                                }
                                self.isLoading = false
                                UIApplication.shared.keyWindow?.makeToast(model.message)
                            }
                        }else{
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }catch{
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                    }
                }else{
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                }
            case .failure(let err):
                self.isLoading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
            }
        }
    }
    
    @objc func onDisagree() {
        if self.isLoading
        {
            return
        }
        let alert = UIAlertController(title: nil, message: NSLocalizedString("QuestionRefuse", comment: "Are you sure you want to reject him/her?"), preferredStyle: .alert)
        let ok = UIAlertAction(title: "确认", style: .default) { (a) in
            self.isLoading = true
            let mo = ApplyForSendModel()
            mo.target_user_id = self.model?.user_id
            BoXinProvider.request(.RefuseApplyForUser(model: mo)) { (result) in
                switch(result){
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    let err = EMClient.shared()?.contactManager.declineInvitation(forUsername: mo.target_user_id!)
                                    if err == nil {
                                        self.view.makeToast(NSLocalizedString("RejectSuccessed", comment: "Rejected successfully"))
                                        self.navigationController?.popViewController(animated: true)
                                    }else{
                                        self.view.makeToast(NSLocalizedString("RejectFailed", comment: "Rejected failed"))
                                    }
                                    let app = UIApplication.shared.delegate as! AppDelegate
                                    if app.addFriendCount > 0 {
                                        app.addFriendCount -= 1
                                    }
                                    self.isLoading = false
                                }else{
                                    if model.message == "请重新登录" {
                                        BoXinUtil.Logout()
                                        if (UIViewController.currentViewController() as? BootViewController) != nil {
                                            let app = UIApplication.shared.delegate as! AppDelegate
                                            app.isNeedLogin = true
                                            return
                                        }
                                        if let vc = UIViewController.currentViewController() as? WelcomeViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is LoginPhoneViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is LoginPasswordViewController {
                                                    return
                                                }
                                                if UIViewController.currentViewController() is RegisterViewController {
                                                    return
                                                }
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        self.present(vc, animated: false, completion: nil)
                                    }
                                    self.isLoading = false
                                    self.view.makeToast(model.message)
                                }
                            }else{
                                self.isLoading = false
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }catch{
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }else{
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                case .failure(let err):
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                }
            }
        }
        alert.addAction(ok)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.modalPresentationStyle = .overFullScreen
        self.present(alert, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
