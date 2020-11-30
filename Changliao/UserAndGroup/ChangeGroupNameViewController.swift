//
//  ChangeGroupNameViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChangeGroupNameViewController: UIViewController,UITextFieldDelegate {
    
     var nickNameTextFeild:UITextField?
    var type:Int = 0
    var groupId:String?
    var model:GroupViewModel?
    var me:GroupMemberData?
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
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.setOffset(0)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.setOffset(-16)
            make?.height.mas_equalTo()(40)
        })
        if type == 0 {
            self.title = NSLocalizedString("EditGroupName", comment: "Edit group name")
            nickNameTextFeild?.placeholder = NSLocalizedString("PlzInputGroupName", comment: "Please input group name")
        }
        if type == 1 {
            title = NSLocalizedString("EditMyGroupNickName", comment: "Edit my group nickname")
            nickNameTextFeild?.placeholder = "请输入内容"
            nickNameTextFeild?.text = (me?.group_user_nickname?.isEmpty ?? true) ? me?.user_name : me?.group_user_nickname
        }
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        let complite = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(onComplite))
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = complite
    }
    
    fileprivate func changeGroupName() {
        if nickNameTextFeild?.text == nil {
            let alert = UIAlertController(title: NSLocalizedString("EditGroupName", comment: "Edit group name"), message: NSLocalizedString("GroupNameInvalid", comment: "Group name is invalid"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (nickNameTextFeild?.text!.isEmpty)! {
            let alert = UIAlertController(title: NSLocalizedString("EditGroupName", comment: "Edit group name"), message: NSLocalizedString("GroupNameInvalid", comment: "Group name is invalid"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if nickNameTextFeild!.text!.count > 25 {
            let alert = UIAlertController(title: NSLocalizedString("EditGroupName", comment: "Edit group name"), message: NSLocalizedString("GroupNameMin",  comment: "Group name cannot exceed 25 characters"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let model = ChangeGroupInfoSendModel()
        model.group_id = groupId
        model.group_name = nickNameTextFeild?.text
        BoXinProvider.request(.ChangeGroup(model: model)) { (result) in
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
                                SVProgressHUD.dismiss()
                                BoXinUtil.getGroupInfo(groupId: self.groupId!, Complite: { (b) in
                                    let body = EMCmdMessageBody(action: "")
                                    var dic = ["type":"qun","id":self.groupId]
                                    var err:EMError?
                                    if self.model?.is_all_banned == 1 {
                                        dic.updateValue("2", forKey: "grouptype")
                                    }else{
                                        dic.updateValue("1", forKey: "grouptype")
                                    }
                                    let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
                                    let msg = EMMessage(conversationID: self.groupId, from: data!.db!.user_id!, to: self.groupId, body: body, ext: dic as [AnyHashable : Any])
                                    msg?.chatType = EMChatTypeGroupChat
                                    EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                        
                                    }, completion: { (msg, err) in
                                        if err != nil {
                                            print(err?.errorDescription)
                                        }
                                    })
                                    self.navigationController?.popViewController(animated: true)
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
        if type == 0 {
            changeGroupName()
        }
        if type == 1 {
            changeGroupNickName()
        }
    }
    
    func changeGroupNickName() {
        if nickNameTextFeild?.text == nil {
            let alert = UIAlertController(title: NSLocalizedString("EditMyGroupNickName", comment: "Edit my group nickname"), message: NSLocalizedString("MyGroupNicknameInvalid", comment: "My group nickname is invalid"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (nickNameTextFeild?.text!.isEmpty)! {
            let alert = UIAlertController(title: NSLocalizedString("EditMyGroupNickName", comment: "Edit my group nickname"), message: NSLocalizedString("MyGroupNicknameInvalid", comment: "My group nickname is invalid"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if nickNameTextFeild!.text!.count > 25  {
            let alert = UIAlertController(title: NSLocalizedString("EditMyGroupNickName", comment: "Edit my group nickname"), message: NSLocalizedString("MyGroupNicknameMaxLenth", comment: "My nickname in this group cannot exceed 25 characters"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let model = ChangeGroupNickNameSendModel()
        model.group_id = groupId
        model.nickname = nickNameTextFeild?.text
        BoXinProvider.request(.ChangeGroupNickName(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                BoXinUtil.getGroupInfo(groupId: self.groupId!, Complite: { (b) in
                                    self.isLoading = false
                                    let body = EMCmdMessageBody(action: "")
                                    var dic = ["type":"qun","id":self.groupId]
                                    if self.model?.is_all_banned == 1 {
                                        dic.updateValue("2", forKey: "grouptype")
                                    }else{
                                        dic.updateValue("1", forKey: "grouptype")
                                    }
                                    let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
                                    let msg = EMMessage(conversationID: self.groupId, from: data!.db!.user_id!, to: self.groupId, body: body, ext: dic as [AnyHashable : Any])
                                    msg?.chatType = EMChatTypeGroupChat
                                    EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                        
                                    }, completion: { (msg, err) in
                                        if err != nil {
                                            print(err?.errorDescription)
                                        }
                                        
                                    })
                                    DispatchQueue.main.async {
                                        SVProgressHUD.dismiss()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
