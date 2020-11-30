//
//  ChangeBackUpNickNameViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/16/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SVProgressHUD
@objc protocol ChangeBackUpNickNameViewControllerDelegate
{
    @objc func onNickName(Name:String)
    @objc func onBeizhuMessage(message:String)
}

@objc class ChangeBackUpNickNameViewController: UIViewController,UITextFieldDelegate {

    var nickNameTextFeild:UITextField?
    @objc var model:FriendData?
    @objc var typeID:Int = 0
    @objc var delegate:ChangeBackUpNickNameViewControllerDelegate?
    @objc var group:GroupViewModel?
    @objc var member:GroupMemberData?
    var isLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let bk = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        bk.backgroundColor = UIColor.white
        self.view.addSubview(bk)
        bk.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            make?.height.mas_equalTo()(40)
        }
        nickNameTextFeild = UITextField(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        nickNameTextFeild?.borderStyle = .none
        nickNameTextFeild?.delegate = self
        nickNameTextFeild?.backgroundColor = UIColor.white
        
        self.view.addSubview(nickNameTextFeild!)
        nickNameTextFeild?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.setOffset(16)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.setOffset(-16)
            make?.height.mas_equalTo()(40)
        })
        if typeID == 0{
            self.title = NSLocalizedString("ChangeRemarks", comment: "Change remarks")
            nickNameTextFeild?.placeholder = NSLocalizedString("PleaseInputRemarks", comment: "Please input remarks")
        }else if typeID == 1{
             self.title = NSLocalizedString("SetRemarks", comment: "Set remarks")
            nickNameTextFeild?.placeholder = NSLocalizedString("PleaseInputRemarks", comment: "Please input remarks")
        }else if typeID == 2
        {
            self.title = NSLocalizedString("VerificationApplication", comment: "Verification application")
            nickNameTextFeild?.placeholder = NSLocalizedString("PleaseInputVerification", comment: "Please input verification")
        }
        if typeID == 3 {
            self.title = NSLocalizedString("ModifyGroupMemberNickName", comment: "Modify group member nickname")
            nickNameTextFeild?.placeholder = NSLocalizedString("PleaseInputGroupMemberNickName", comment: "Please Input group member nickname")
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(onComplite))
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        
        
        
        
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    fileprivate func changeNickName() {
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let model = ChangeFriendNickNameSendModel()
        model.target_user_id = self.model?.user_id
        model.newName = nickNameTextFeild?.text
        BoXinProvider.request(.ChangeFriendNickName(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                BoXinUtil.getFriends({ (b) in
                                    SVProgressHUD.dismiss()
                                    DispatchQueue.main.async {
                                        
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                })
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
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                self.isLoading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc func onComplite() {
        if nickNameTextFeild?.text == nil {
            return
        }
        if (nickNameTextFeild?.text!.isEmpty)! {
            return
        }
        if typeID == 0 {
            if nickNameTextFeild!.text!.count > 25 {
                let alert = UIAlertController(title: self.title, message: NSLocalizedString("RemarksMaxLenth", comment: "Note cannot exceed 25 characters"), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
             changeNickName()
        }else if typeID == 1{
            if nickNameTextFeild!.text!.count > 25 {
                let alert = UIAlertController(title: self.title, message: NSLocalizedString("RemarksMaxLenth", comment: "Note cannot exceed 25 characters"), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
            delegate?.onNickName(Name: nickNameTextFeild!.text!)
            self.navigationController?.popViewController(animated: true)
        }else if typeID == 2
        {
            if nickNameTextFeild!.text!.count > 25 {
                let alert = UIAlertController(title: self.title, message: NSLocalizedString("VerficationMaxLenth", comment: "Validation information cannot exceed 25 characters"), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            delegate?.onBeizhuMessage(message: nickNameTextFeild!.text!)
            self.navigationController?.popViewController(animated: true)
        }
        if typeID == 3 {
            if nickNameTextFeild!.text!.count > 25 {
                let alert = UIAlertController(title: self.title, message: NSLocalizedString("RemarksMaxLenth", comment: "Note cannot exceed 25 characters"), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
                
                alert.addAction(okAction)
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return
            }
            changeGroupMemberNikeName()
        }
       
    }
    
    func changeGroupMemberNikeName() {
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let model = EditGroupChangeNickNameSendModel()
        model.target_user_id = member?.user_id
        model.nickname = nickNameTextFeild?.text
        model.group_id = member?.group_id
        BoXinProvider.request(.EditGroupMemberNickName(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                BoXinUtil.getGroupMember(groupID: self.member!.group_id!, Complite: { (b) in
                                    if b {
                                        SVProgressHUD.dismiss()
                                        NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }else
                                    {
                                        self.navigationController?.popToRootViewController(animated: true)
                                    }
                                    
                                })
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
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                self.isLoading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
