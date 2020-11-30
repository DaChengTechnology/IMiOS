//
//  UserDetailViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage
import SVProgressHUD

@objc class UserDetailViewController: UIViewController,ChangeBackUpNickNameViewControllerDelegate {
    var NickNameText:String?
    var BeizhuMessage:String?
    var shutUpBtn:UIButton = UIButton(type: .custom)
    var isHaveData=false
    
    func onNickName(Name: String) {
        NickNameText = Name
        
        NewNameText.text = NickNameText
        
        
    }
    
    
    func onBeizhuMessage(message: String) {
        BeizhuMessage = message
        verityLabel.text=message
    }
    
    
    /// 0 搜索添加好友里进 1 好友申请 2陌生群聊 3好友群聊  4好友详情
    var type:Int = 0
    @objc var model:FriendData?
    var newFriendModel:GetUserData?
    let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    let nickNameLabel = UILabel(frame: .zero)
    let headImageView = UIImageView(image: UIImage(named: "moren"))
    var group:GroupViewModel?
    var member:GroupMemberData?
    var loading:Bool = false
    let NewNameText = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    let idLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    let GetGroup = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    let GetGroup1 = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    var isLoading:Bool = false
    let SetBeiZhuLab = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    var verityLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    weak var lastPanl : UIView?
    var momentPic:[UIImageView] = [UIImageView]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        headImageView.layer.cornerRadius=40
        headImageView.layer.masksToBounds = true
        let headTap = UITapGestureRecognizer(target: self, action: #selector(onPreviewAvater(g:)))
        headImageView.isUserInteractionEnabled=true
        headImageView.addGestureRecognizer(headTap)
        if type == 0 {
            wantToAddFriend()
            self.title = NSLocalizedString("UserDetails", comment: "User details")
        }
        if type == 1 {
            friendInvate()
            self.title = "验证信息"
        }
        if type == 2 {
            
            DispatchQueue.global().async {
                BoXinUtil.getGroupOneMember(groupID: self.member!.group_id!, userID: self.member!.user_id!) { (b) in
                    self.member = QueryFriend.shared.getGroupUser(userId: self.member!.user_id!, groupId: self.member!.group_id!)
                    DispatchQueue.main.async {
                        if (self.group?.is_admin == 1 || self.group?.is_menager == 1) && self.member?.is_administrator == 2 && self.member?.is_manager == 2 {
                            if self.member?.is_shield == 1 {
                                self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .normal)
                                self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .selected)
                                self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .highlighted)
                                self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .disabled)
                            }else{
                                self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .normal)
                                self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .selected)
                                self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .highlighted)
                                self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .disabled)
                            }
                        }
                    }
                }
            }
            self.strongerGroupChat()
            self.title = NSLocalizedString("UserDetails", comment: "User details")
        }
        if type == 3 {
            DispatchQueue.global().async {
                BoXinUtil.getGroupOneMember(groupID: self.member!.group_id!, userID: self.member!.user_id!) { (b) in
                    self.member = QueryFriend.shared.getGroupUser(userId: self.member!.user_id!, groupId: self.member!.group_id!)
                    DispatchQueue.main.async {
                        if (self.group?.is_admin == 1 || self.group?.is_menager == 1) && self.member?.is_administrator == 2 && self.member?.is_manager == 2 {
                            if self.member?.is_shield == 1 {
                                self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .normal)
                                self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .selected)
                                self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .highlighted)
                                self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .disabled)
                            }else{
                                self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .normal)
                                self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .selected)
                                self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .highlighted)
                                self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .disabled)
                            }
                        }
                    }
                }
            }
            self.friendGroupChat()
            self.title = NSLocalizedString("UserDetails", comment: "User details")
        }
        if type == 4 {
            friendInfo()
            self.title = NSLocalizedString("UserDetails", comment: "User details")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        if type == 4 {
            let more = UIBarButtonItem(image: UIImage(named: "圆点菜单"), style: .plain, target: self, action: #selector(onMoreSetting))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = more
            if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
                for con in contact {
                    for c in con!.data! {
                        if c?.user_id == model?.user_id {
                            model = c
                            nameLabel.text = model?.target_user_nickname
                            return
                        }
                    }
                }
            }
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
                                    QueryFriend.shared.addFriend(id: md.data!.user_id!, nickName: md.data!.user_name!, portrait1: md.data!.portrait!, card: md.data!.id_card!)
                                    DispatchQueue.main.async {
                                        self.nameLabel.text = md.data?.user_name
                                        self.headImageView.sd_setImage(with: URL(string: md.data!.portrait!))
                                    }
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
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    print(err.errorDescription)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if type == 3 || type == 4 {
            getMoment()
        }
    }
    
    @objc func onTakeOut() {
        let alert = UIAlertController(title: NSLocalizedString("QuestionKick", comment: "Are you sure you want to kick him/her?"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (a) in
            if self.isLoading
            {
                return
            }
            self.isLoading = true
            SVProgressHUD.show()
            
            let  model = AddBatchSendModel()
            model.group_id = self.group?.groupId
            model.group_user_ids = self.member?.user_id
            BoXinProvider.request(.GroupRemoveBatch(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    self.isLoading = false
                                    return
                                }
                                if model.code == 200 {
                                    self.isLoading = false
                                    BoXinUtil.getGroupMember(groupID: self.group!.groupId!, Complite: { (b) in
                                        
                                        if b {
                                            DispatchQueue.main.async {
                                                let body = EMCmdMessageBody(action: "")
                                                var dic = ["type":"qun","id":self.group?.groupId]
                                                if self.group?.is_all_banned == 1 {
                                                    dic.updateValue("2", forKey: "grouptype")
                                                }else{
                                                    dic.updateValue("1", forKey: "grouptype")
                                                }
                                                let msg = EMMessage(conversationID: self.group!.groupId!, from: EMClient.shared()!.currentUsername, to: self.group!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                                msg?.chatType = EMChatTypeGroupChat
                                                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                    
                                                }, completion: { (msg, err) in
                                                    if err != nil {
                                                        print(err?.errorDescription)
                                                    }
                                                    
                                                })
                                                NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                                                self.navigationController?.popViewController(animated: true)
                                                SVProgressHUD.dismiss()
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
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
        alert.modalPresentationStyle = .overFullScreen
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onSheild() {
        if member?.is_shield == 1 {
            cancelShieldSingle()
        }else{
            setShieldSingle()
        }
    }
    
    func setShieldSingle() {
        if isLoading
        {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let  model = ShieldSigleSendModel()
        model.group_id = self.group?.groupId
        model.groupUserId = self.member!.user_id
        BoXinProvider.request(.SetShieldSingle(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                BoXinUtil.getGroupMember(groupID: self.group!.groupId!, Complite: { (b) in
                                    
                                    if b {
                                        DispatchQueue.main.async {
                                            let body = EMCmdMessageBody(action: "")
                                            let dic = ["type":"qun_shield","id":self.group?.groupId,"userid":self.member?.user_id,"qun_shield":"1"]
                                            let msg = EMMessage(conversationID: self.member!.user_id!, from: EMClient.shared()!.currentUsername, to: self.member!.user_id!, body: body, ext: dic as [AnyHashable : Any])
                                            EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                
                                            }, completion: { (msg, err) in
                                                if err != nil {
                                                    print(err?.errorDescription)
                                                }
                                                
                                            })
                                            self.member = QueryFriend.shared.getGroupUser(userId: self.member!.user_id!, groupId: self.group!.groupId!)
                                            NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                                            self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .normal)
                                            self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .selected)
                                            self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .highlighted)
                                            self.shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .disabled)
                                            SVProgressHUD.dismiss()
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
    
    func cancelShieldSingle() {
        if isLoading
        {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let  model = ShieldSigleSendModel()
        model.group_id = self.group?.groupId
        model.groupUserId = member!.user_id
        BoXinProvider.request(.CancelShieldSingle(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                BoXinUtil.getGroupMember(groupID: self.group!.groupId!, Complite: { (b) in
                                    
                                    if b {
                                        DispatchQueue.main.async {
                                            let body = EMCmdMessageBody(action: "")
                                            let dic = ["type":"qun_shield","id":self.group?.groupId,"userid":self.member!.user_id,"qun_shield":"2"]
                                            let msg = EMMessage(conversationID: self.member!.user_id!, from: EMClient.shared()!.currentUsername, to: self.member!.user_id!, body: body, ext: dic as [AnyHashable : Any])
                                            EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                
                                            }, completion: { (msg, err) in
                                                if err != nil {
                                                    print(err?.errorDescription)
                                                }
                                                
                                            })
                                            self.member = QueryFriend.shared.getGroupUser(userId: self.member!.user_id!, groupId: self.group!.groupId!)
                                            NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                                            self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .normal)
                                            self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .selected)
                                            self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .highlighted)
                                            self.shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .disabled)
                                            SVProgressHUD.dismiss()
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
    
    @objc private func onGotoAddFriend() {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
        let vc = UserDetailViewController()
        vc.model = FriendData(member: member)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func onMoreSetting() {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
        let vc = UserDetailMoreSettingTableViewController()
        vc.model = model
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func onChangeBackUpName(g:UIGestureRecognizer) {
        if g.state == .ended {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
            let vc = ChangeBackUpNickNameViewController()
            vc.model = model
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func onShare() {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
        let vc = ShareFriendViewController()
        vc.model = model
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func onAddFriend() {
        if isLoading
        {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let model = AddFriendNickNameModel()
        model.target_user_id = self.model?.user_id
        var id = self.model?.user_id
        if type == 0
        {
            model.target_user_id = self.model?.user_id
            
            model.target_user_name = NickNameText
            model.remark = BeizhuMessage
        }
        BoXinProvider.request(.ApplyForUser(model: model)) { (result) in
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
                                let err = EMClient.shared()?.contactManager.addContact(id!, message: "我想加你")
                                if err == nil {
                                    self.view.makeToast(NSLocalizedString("RequestSended", comment: "Request sent"))
                                }else{
                                    self.view.makeToast(NSLocalizedString("RequestFailed", comment: "Request send failed"))
                                }
                                SVProgressHUD.dismiss()
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
    
    @objc private func onSendMessage() {
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
        var chat = model?.user_id
        if type == 2 {
            chat = member?.user_id
        }
         let vc = ChatViewController(conversationChatter: chat!, conversationType: EMConversationTypeChat)
        if model?.target_user_nickname != nil
        {
             vc?.title = model?.target_user_nickname
        }else
        {
             vc?.title = member?.user_name
        }
       
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc private func onCallMessage() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        alert.addAction(cancel)
        let voise = UIAlertAction(title: NSLocalizedString("VoiceCall", comment: "Voice call"), style: .default) { (a) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNOTIFICATION_MAKE1V1CALL), object: ["chatter":self.model!.user_id!,"type":0], userInfo: nil)
        }
        alert.addAction(voise)
        let vedio = UIAlertAction(title: NSLocalizedString("VedioCall", comment: "Vedio call"), style: .default) { (a) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNOTIFICATION_MAKE1V1CALL), object: ["chatter":self.model!.user_id!,"type":1], userInfo: nil)
        }
        alert.addAction(vedio)
        alert.modalPresentationStyle = .overFullScreen
        self.present(alert, animated: true, completion: nil)
    }

    @objc func onFocus(sender:UISwitch) {
        if loading {
            return
        }
        loading = true
        SVProgressHUD.show()
        if !sender.isOn {
            let model = FocusSendModel()
            model.group_id = group?.groupId
            model.focusUserId = member?.user_id
            BoXinProvider.request(.CancelFocus(model: model)) { (result) in
                switch(result){
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    QueryFriend.shared.deleteFocus(userId: self.member!.user_id!, groupId: self.member!.group_id!)
                                    sender.setOn(false, animated: true)
                                    NotificationCenter.default.post(Notification(name: Notification.Name("UpdateFocus")))
                                    self.loading = false
                                    SVProgressHUD.dismiss()
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
                                    self.view.makeToast(model.message)
                                    self.loading = false
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                self.loading = false
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            self.loading = false
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        self.loading = false
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    self.loading = false
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }else{
            let model = FocusSendModel()
            model.group_id = group?.groupId
            model.focusUserId = member?.user_id
            BoXinProvider.request(.SetFocus(model: model)) { (result) in
                switch(result){
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
                                    QueryFriend.shared.addFocus(groupId: self.group!.groupId!, id: data!.db!.user_id!, target: self.member!.user_id!)
                                    sender.setOn(true, animated: true)
                                    NotificationCenter.default.post(Notification(name: Notification.Name("UpdateFocus")))
                                    SVProgressHUD.dismiss()
                                    self.loading = false
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
                                    self.view.makeToast(model.message)
                                    SVProgressHUD.dismiss()
                                    self.loading = false
                                }
                            }else{
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                                self.loading = false
                            }
                        }catch{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                            self.loading = false
                        }
                    }else{
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        SVProgressHUD.dismiss()
                        self.loading = false
                    }
                case .failure(let err):
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                    self.loading = false
                }
            }
        }
    }
    
    @objc func onHead(sender:UIImageView) {
        let data = YBIBImageData()
        if model != nil {
            data.imageURL = URL(string: model!.portrait!)
        }else{
            data.imageURL = URL(string: member!.portrait!)
        }
        data.projectiveView = headImageView
        let browser = YBImageBrowser()
        browser.dataSourceArray = [data]
        browser.currentPage = 0
        browser.show()
    }
    @objc func NameClick()
    {
        let vc = ChangeBackUpNickNameViewController()
        vc.typeID = 1
        vc.delegate = self
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        print("name")
    }
    @objc func BeizhuClick()
    {
        let vc = ChangeBackUpNickNameViewController()
        vc.typeID = 2
        vc.delegate = self
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
         self.navigationController?.pushViewController(vc, animated: true)
        print("beizhu")
    }
    
    // -MARK: - SetupUI
    // -MARK: - 添加好友
    func wantToAddFriend() {
        let userInfo = UIView(frame: .zero)
        userInfo.backgroundColor=UIColor.white
        self.view.addSubview(userInfo)
        userInfo.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(128)
        }
        if !(model?.portrait?.isEmpty ?? true) {
            headImageView.sd_setImage(with: URL(string: model?.portrait ?? ""), completed: nil)
        }
        userInfo.addSubview(headImageView)
        headImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(userInfo)?.offset()(16)
            make?.width.mas_equalTo()(80)
            make?.height.equalTo()(headImageView.mas_width)
            make?.centerY.equalTo()(userInfo)
        }
        nameLabel.font=UIFont.systemFont(ofSize: 22)
        nameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#000B2A")
        nameLabel.text=model?.friend_self_name
        userInfo.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.top.equalTo()(headImageView)?.offset()(6)
        }
        idLabel.font=UIFont.systemFont(ofSize: 16)
        idLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
        idLabel.text=String(format: NSLocalizedString("ChattingID", comment: "Chatting ID") + ":%@", model?.id_card ?? "")
        userInfo.addSubview(idLabel)
        idLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.bottom.equalTo()(headImageView)?.offset()(-6)
        }
        let nicknamePanl = UIView(frame: .zero)
        nicknamePanl.backgroundColor=UIColor.white
        nicknamePanl.isUserInteractionEnabled=true
        let tap1=UITapGestureRecognizer(target: self, action: #selector(setNickname(g:)))
        nicknamePanl.addGestureRecognizer(tap1)
        self.view.addSubview(nicknamePanl)
        nicknamePanl.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(userInfo.mas_bottom)
            make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(60)
        }
        let SetNameLab = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        SetNameLab.text = NSLocalizedString("SetRemarks", comment: "Set remarks")
         SetNameLab.font = UIFont.systemFont(ofSize: 16)
         nicknamePanl.addSubview(SetNameLab)
         SetNameLab.mas_makeConstraints { (make) in
            make?.center.equalTo()(nicknamePanl)
            make?.left.equalTo()(nicknamePanl)?.offset()(16)
         }
        let jt1 = UIImageView(image: UIImage(named: "friend_hide"))
        nicknamePanl.addSubview(jt1)
        jt1.mas_makeConstraints { (make) in
            make?.right.equalTo()(nicknamePanl.mas_right)?.offset()(-16)
            make?.height.mas_equalTo()(12)
            make?.width.mas_equalTo()(7)
            make?.centerY.equalTo()(SetNameLab)
        }
        NewNameText.font = UIFont.systemFont(ofSize: 16)
        NewNameText.textColor = UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
        NewNameText.textAlignment = .right
        NewNameText.numberOfLines = 1
        nicknamePanl.addSubview(NewNameText)
        NewNameText.mas_makeConstraints { (make) in
            make?.centerY.equalTo()(SetNameLab)
            make?.right.equalTo()(jt1.mas_left)?.offset()(-10)
            make?.left.greaterThanOrEqualTo()(SetNameLab.mas_right)?.offset()(8)
        }
         let verityPanl = UIView(frame: .zero)
         verityPanl.backgroundColor=UIColor.white
         verityPanl.isUserInteractionEnabled=true
         let tap2=UITapGestureRecognizer(target: self, action: #selector(setVerityInfo(g:)))
         verityPanl.addGestureRecognizer(tap2)
         self.view.addSubview(verityPanl)
         verityPanl.mas_makeConstraints { (make) in
             make?.left.equalTo()(self.view)
             make?.top.equalTo()(nicknamePanl.mas_bottom)
             make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(60)
         }
         SetBeiZhuLab.text = NSLocalizedString("VerificationApplication", comment: "Verification application")
         SetBeiZhuLab.font = UIFont.systemFont(ofSize: 16)
         verityPanl.addSubview(SetBeiZhuLab)
         SetBeiZhuLab.mas_makeConstraints { (make) in
             make?.top.equalTo()(verityPanl)?.offset()(20)
            make?.left.equalTo()(verityPanl)?.offset()(16)
         }
        let jt2 = UIImageView(image: UIImage(named: "friend_hide"))
        verityPanl.addSubview(jt2)
        jt2.mas_makeConstraints { (make) in
            make?.right.equalTo()(verityPanl)?.offset()(-16)
            make?.height.mas_equalTo()(12)
            make?.width.mas_equalTo()(7)
            make?.centerY.equalTo()(SetBeiZhuLab)
        }
        verityLabel.font = UIFont.systemFont(ofSize: 16)
        verityLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
        verityLabel.textAlignment = .right
        verityLabel.numberOfLines = 1
        verityPanl.addSubview(verityLabel)
        verityLabel.mas_makeConstraints { (make) in
            make?.centerY.equalTo()(SetBeiZhuLab)
            make?.right.equalTo()(jt1.mas_left)?.offset()(-10)
            make?.left.equalTo()(SetBeiZhuLab.mas_right)?.offset()(0)
        }
        let addFriendBtn = UIButton(type: .custom)
        addFriendBtn.setTitleColor(UIColor.white, for: .normal)
        addFriendBtn.setTitleColor(UIColor.white, for: .selected)
        addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
        addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
        addFriendBtn.setTitle(NSLocalizedString("AddFriends", comment: "Add friends"), for: .normal)
        addFriendBtn.setTitle(NSLocalizedString("AddFriends", comment: "Add friends"), for: .selected)
        addFriendBtn.setTitle(NSLocalizedString("AddFriends", comment: "Add friends"), for: .highlighted)
        addFriendBtn.setTitle(NSLocalizedString("AddFriends", comment: "Add friends"), for: .disabled)
        addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        addFriendBtn.layer.cornerRadius=25
        addFriendBtn.layer.masksToBounds=true
        addFriendBtn.addTarget(self, action: #selector(onAddFriend), for: .touchUpInside)
        self.view.addSubview(addFriendBtn)
        addFriendBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
            make?.top.equalTo()(verityPanl.mas_bottom)?.offset()(56)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
        }
    }
    
    @objc func setNickname(g:UIGestureRecognizer){
        if g.state == .ended {
            let vc = ChangeBackUpNickNameViewController()
            vc.typeID = 1
            vc.delegate = self
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func setVerityInfo(g:UIGestureRecognizer) {
        if g.state == .ended {
            let vc = ChangeBackUpNickNameViewController()
            vc.typeID = 2
            vc.delegate = self
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
             self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // -MARK: - 好友申请
    func friendInvate() {
        let userInfo = UIView(frame: .zero)
        userInfo.backgroundColor=UIColor.white
        self.view.addSubview(userInfo)
        userInfo.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(128)
        }
        if !(model?.portrait?.isEmpty ?? true) {
            headImageView.sd_setImage(with: URL(string: newFriendModel?.portrait ?? ""), completed: nil)
        }
        userInfo.addSubview(headImageView)
        headImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(userInfo)?.offset()(16)
            make?.width.mas_equalTo()(80)
            make?.height.equalTo()(headImageView.mas_width)
            make?.centerY.equalTo()(userInfo)
        }
        nameLabel.font=UIFont.systemFont(ofSize: 22)
        nameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#000B2A")
        nameLabel.text=newFriendModel?.user_name
        userInfo.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.top.equalTo()(headImageView)?.offset()(6)
        }
        idLabel.font=UIFont.systemFont(ofSize: 16)
        idLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
        idLabel.text=String(format: NSLocalizedString("ChattingID", comment: "Chatting ID") + ":%@", newFriendModel?.id_card ?? "")
        userInfo.addSubview(idLabel)
        idLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.bottom.equalTo()(headImageView)?.offset()(-6)
        }
        let verifyView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        verifyView.layer.borderColor = UIColor.hexadecimalColor(hexadecimal: "e5e5e5").cgColor
        verifyView.layer.borderWidth = 1
        verifyView.layer.cornerRadius = 5
        verifyView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EFEFEF")
        self.view.addSubview(verifyView)
        verifyView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)?.offset()(16)
            make?.top.equalTo()(userInfo.mas_bottom)?.offset()(10)
            make?.right.equalTo()(self.view)?.equalTo()(-16)
            make?.height.mas_equalTo()(106)
        }
        let verifyTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        verifyTitleLabel.text = NSLocalizedString("VerificationInfo", comment: "Verification infomation:")
        verifyTitleLabel.font = UIFont.systemFont(ofSize: 14)
        verifyTitleLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#9A9A9A")
        verifyView.addSubview(verifyTitleLabel)
        verifyTitleLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(verifyView.mas_left)?.offset()(21)
            make?.top.equalTo()(verifyView.mas_top)?.offset()(18)
        }
        let verifyInfoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        verifyInfoLabel.text = String(format: " %@", newFriendModel?.remark ?? "")
        verifyInfoLabel.font = UIFont.systemFont(ofSize: 14)
        verifyInfoLabel.numberOfLines = 0
        verifyInfoLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#9A9A9A")
        verifyView.addSubview(verifyInfoLabel)
        verifyInfoLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(verifyView.mas_left)?.offset()(16)
            make?.top.equalTo()(verifyTitleLabel.mas_bottom)?.offset()(12)
            make?.right.lessThanOrEqualTo()(verifyView.mas_right)?.offset()(-16)
            make?.bottom.equalTo()(verifyView.mas_bottom)?.offset()(-22)
        }
        let agreeBtn = UIButton(type: .custom)
        agreeBtn.setTitleColor(UIColor.white, for: .normal)
        agreeBtn.setTitleColor(UIColor.white, for: .selected)
        agreeBtn.setTitleColor(UIColor.white, for: .highlighted)
        agreeBtn.setTitleColor(UIColor.white, for: .disabled)
        agreeBtn.setTitle(NSLocalizedString("ThroughValdation", comment: "Through valdation"), for: .normal)
        agreeBtn.setTitle(NSLocalizedString("ThroughValdation", comment: "Through valdation"), for: .selected)
        agreeBtn.setTitle(NSLocalizedString("ThroughValdation", comment: "Through valdation"), for: .highlighted)
        agreeBtn.setTitle(NSLocalizedString("ThroughValdation", comment: "Through valdation"), for: .disabled)
        agreeBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        agreeBtn.layer.cornerRadius=25
        agreeBtn.layer.masksToBounds=true
        agreeBtn.addTarget(self, action: #selector(onAgree), for: .touchUpInside)
        self.view.addSubview(agreeBtn)
        agreeBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
            make?.top.equalTo()(verifyView.mas_bottom)?.offset()(40)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
        }
        let disagreeBtn = UIButton(type: .custom)
        disagreeBtn.setTitleColor(UIColor.white, for: .normal)
        disagreeBtn.setTitleColor(UIColor.white, for: .selected)
        disagreeBtn.setTitleColor(UIColor.white, for: .highlighted)
        disagreeBtn.setTitleColor(UIColor.white, for: .disabled)
        disagreeBtn.setTitle(NSLocalizedString("RejectThePerson", comment: "Reject the persion"), for: .normal)
        disagreeBtn.setTitle(NSLocalizedString("RejectThePerson", comment: "Reject the persion"), for: .selected)
        disagreeBtn.setTitle(NSLocalizedString("RejectThePerson", comment: "Reject the persion"), for: .highlighted)
        disagreeBtn.setTitle(NSLocalizedString("RejectThePerson", comment: "Reject the persion"), for: .disabled)
        disagreeBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
        disagreeBtn.layer.cornerRadius=25
        disagreeBtn.layer.masksToBounds=true
        disagreeBtn.addTarget(self, action: #selector(onDisagree), for: .touchUpInside)
        self.view.addSubview(disagreeBtn)
        disagreeBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
            make?.top.equalTo()(agreeBtn.mas_bottom)?.offset()(28)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
        }
    }
    
    @objc func onAgree() {
        if isLoading {
            return
        }
        isLoading = true
        let mo = ApplyForSendModel()
        mo.target_user_id = newFriendModel?.user_id
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
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
            self.isLoading = true
            let mo = ApplyForSendModel()
            mo.target_user_id = self.newFriendModel?.user_id
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
    
    // -MARK: -陌生群聊
    func strongerGroupChat() {
        let userInfo = UIView(frame: .zero)
        userInfo.backgroundColor=UIColor.white
        self.view.addSubview(userInfo)
        userInfo.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(128)
        }
        if !(member?.portrait?.isEmpty ?? true) {
            headImageView.sd_setImage(with: URL(string: member?.portrait ?? ""), completed: nil)
        }
        userInfo.addSubview(headImageView)
        headImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(userInfo)?.offset()(16)
            make?.width.mas_equalTo()(80)
            make?.height.equalTo()(headImageView.mas_width)
            make?.centerY.equalTo()(userInfo)
        }
        nameLabel.font=UIFont.systemFont(ofSize: 22)
        nameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#000B2A")
        nameLabel.text=member?.user_name
        userInfo.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.top.equalTo()(headImageView)?.offset()(6)
        }
        if group?.is_admin == 1 || group?.is_menager == 1 || member?.is_administrator == 1 || member?.is_manager == 1 {
            idLabel.font=UIFont.systemFont(ofSize: 16)
            idLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
            idLabel.text=String(format: NSLocalizedString("ChattingID", comment: "Chatting ID") + ":%@", member!.id_card!)
            userInfo.addSubview(idLabel)
            idLabel.mas_makeConstraints { (make) in
                make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
                make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
                make?.bottom.equalTo()(headImageView)?.offset()(-6)
            }
            if !(member?.group_user_nickname?.isEmpty ?? true) {
                nickNameLabel.font=UIFont.systemFont(ofSize: 16)
                nickNameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
                nickNameLabel.text=String(format: NSLocalizedString("GroupNickName", comment: "Group nickname") + ":%@", member?.group_user_nickname ?? "")
                userInfo.addSubview(nickNameLabel)
                nickNameLabel.mas_makeConstraints { (make) in
                    make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
                    make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
                    make?.bottom.equalTo()(idLabel.mas_top)?.offset()(-3)
                }
            }
        }else{
            if !(member?.group_user_nickname?.isEmpty ?? true) {
                idLabel.font=UIFont.systemFont(ofSize: 16)
                idLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
                idLabel.text=String(format: NSLocalizedString("GroupNickName", comment: "Group nickname") + ":%@", member?.group_user_nickname ?? "")
                userInfo.addSubview(idLabel)
                idLabel.mas_makeConstraints { (make) in
                    make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
                    make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
                    make?.bottom.equalTo()(headImageView)?.offset()(-6)
                }
            }
        }
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        focusView.backgroundColor = UIColor.white
        self.view.addSubview(focusView)
        focusView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(userInfo.mas_bottom)?.offset()(8)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
        }
        let focusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        focusLabel.font = UIFont.systemFont(ofSize: 16)
        focusLabel.text = NSLocalizedString("FocusInGroup", comment: "Focus in group")
        focusView.addSubview(focusLabel)
        focusLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(focusView.mas_left)?.offset()(16)
            make?.top.equalTo()(focusView)?.offset()(20)
            make?.bottom.equalTo()(focusView)?.offset()(-20)
        }
        let focusSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        focusSwitch.onTintColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
        focusSwitch.isOn = QueryFriend.shared.checkFocus(userId: member!.user_id!, groupId: group!.groupId!)
        focusSwitch.addTarget(self, action: #selector(onFocus(sender:)), for: .touchUpInside)
        focusView.addSubview(focusSwitch)
        focusSwitch.mas_makeConstraints { (make) in
            make?.right.equalTo()(focusView.mas_right)?.offset()(-30)
            make?.centerY.equalTo()(focusView.mas_centerY)
            make?.height.mas_equalTo()(31)
            make?.width.mas_equalTo()(47)
        }
        weak var tView = focusView
        if group?.is_admin == 1 {
            if !(member?.inv_name?.isEmpty ?? true) {
                let GetGroupView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GetGroupView.backgroundColor = UIColor.white
                self.view.addSubview(GetGroupView)
                GetGroupView.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                    make?.top.equalTo()(focusView.mas_bottom)?.offset()(8)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                }
                let GetGroupLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GetGroupLabel.font = UIFont.systemFont(ofSize: 16)
                GetGroupLabel.text = NSLocalizedString("JoinGroupWay", comment: "Join group way")
                GetGroupView.addSubview(GetGroupLabel)
                GetGroupLabel.mas_makeConstraints { (make) in
                    make?.left.equalTo()(GetGroupView.mas_left)?.offset()(16)
                    make?.top.equalTo()(GetGroupView)?.offset()(20)
                    make?.bottom.equalTo()(GetGroupView)?.offset()(-20)
                }
                let GetGroup = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GetGroup.textColor = UIColor.hexadecimalColor(hexadecimal: "#979797")
                GetGroup.font = UIFont.systemFont(ofSize: 14)
                GetGroup.text = String.localizedStringWithFormat(NSLocalizedString("JoinGroupThrough", comment: "Invite to group through %@"), member?.inv_name ?? "")
                GetGroup.textAlignment = .right
                GetGroupView.addSubview(GetGroup)
                GetGroup.mas_makeConstraints { (make) in
                    make?.right.equalTo()(GetGroupView.mas_right)?.offset()(-16)
                    make?.centerY.equalTo()(GetGroupLabel)
                    make?.width.equalTo()(self.view.frame.size.width * 0.7)
                }
                let groupNickName = UIView(frame: .zero)
                groupNickName.backgroundColor = UIColor.white
                let tap3 = UITapGestureRecognizer(target: self, action: #selector(changeGroupMemberName(g:)))
                groupNickName.addGestureRecognizer(tap3)
                self.view.addSubview(groupNickName)
                groupNickName.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                    make?.top.equalTo()(focusView.mas_bottom)?.offset()(8)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                }
                let GroupNickNimeTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GroupNickNimeTitleLabel.font = UIFont.systemFont(ofSize: 16)
                GroupNickNimeTitleLabel.text = NSLocalizedString("GroupNickName", comment: "Group nickname")
                groupNickName.addSubview(GroupNickNimeTitleLabel)
                GroupNickNimeTitleLabel.mas_makeConstraints { (make) in
                    make?.left.equalTo()(groupNickName.mas_left)?.offset()(16)
                    make?.top.equalTo()(groupNickName)?.offset()(20)
                    make?.bottom.equalTo()(groupNickName)?.offset()(-20)
                }
                let GroupNickNimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GroupNickNimeLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#979797")
                GroupNickNimeLabel.font = UIFont.systemFont(ofSize: 14)
                GroupNickNimeLabel.text = member?.group_user_nickname
                GroupNickNimeLabel.textAlignment = .right
                groupNickName.addSubview(GroupNickNimeLabel)
                GroupNickNimeLabel.mas_makeConstraints { (make) in
                    make?.right.equalTo()(groupNickName.mas_right)?.offset()(-16)
                    make?.centerY.equalTo()(GetGroupLabel)
                    make?.width.equalTo()(self.view.frame.size.width * 0.7)
                }
                tView = groupNickName
            }
            if member?.is_manager == 1 {
                let tickoutBtn = UIButton(type: .custom)
                tickoutBtn.setTitleColor(UIColor.white, for: .normal)
                tickoutBtn.setTitleColor(UIColor.white, for: .selected)
                tickoutBtn.setTitleColor(UIColor.white, for: .highlighted)
                tickoutBtn.setTitleColor(UIColor.white, for: .disabled)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .normal)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .selected)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .highlighted)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .disabled)
                tickoutBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EDCB01")
                tickoutBtn.layer.cornerRadius=25
                tickoutBtn.layer.masksToBounds=true
                tickoutBtn.addTarget(self, action: #selector(onTakeOut), for: .touchUpInside)
                self.view.addSubview(tickoutBtn)
                tickoutBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tView?.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let sendBtn = UIButton(type: .custom)
                sendBtn.setTitleColor(UIColor.white, for: .normal)
                sendBtn.setTitleColor(UIColor.white, for: .selected)
                sendBtn.setTitleColor(UIColor.white, for: .highlighted)
                sendBtn.setTitleColor(UIColor.white, for: .disabled)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .normal)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .selected)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .highlighted)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .disabled)
                sendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
                sendBtn.layer.cornerRadius=25
                sendBtn.layer.masksToBounds=true
                sendBtn.addTarget(self, action: #selector(onSendMessage), for: .touchUpInside)
                self.view.addSubview(sendBtn)
                sendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tickoutBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let addFriendBtn = UIButton(type: .custom)
                addFriendBtn.setTitleColor(UIColor.white, for: .normal)
                addFriendBtn.setTitleColor(UIColor.white, for: .selected)
                addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
                addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .normal)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .selected)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .highlighted)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .disabled)
                addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                addFriendBtn.layer.cornerRadius=25
                addFriendBtn.layer.masksToBounds=true
                addFriendBtn.addTarget(self, action: #selector(onGotoAddFriend), for: .touchUpInside)
                self.view.addSubview(addFriendBtn)
                addFriendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(sendBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
            }else{
                shutUpBtn.setTitleColor(UIColor.white, for: .normal)
                shutUpBtn.setTitleColor(UIColor.white, for: .selected)
                shutUpBtn.setTitleColor(UIColor.white, for: .highlighted)
                shutUpBtn.setTitleColor(UIColor.white, for: .disabled)
                if member?.is_shield == 1 {
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .normal)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .selected)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .highlighted)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .disabled)
                }else{
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .normal)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .selected)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .highlighted)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .disabled)
                }
                shutUpBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE7C08")
                shutUpBtn.layer.cornerRadius=25
                shutUpBtn.layer.masksToBounds=true
                shutUpBtn.addTarget(self, action: #selector(onSheild), for: .touchUpInside)
                self.view.addSubview(shutUpBtn)
                shutUpBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tView?.mas_bottom)?.offset()(40)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let tickoutBtn = UIButton(type: .custom)
                tickoutBtn.setTitleColor(UIColor.white, for: .normal)
                tickoutBtn.setTitleColor(UIColor.white, for: .selected)
                tickoutBtn.setTitleColor(UIColor.white, for: .highlighted)
                tickoutBtn.setTitleColor(UIColor.white, for: .disabled)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .normal)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .selected)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .highlighted)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .disabled)
                tickoutBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EDCB01")
                tickoutBtn.layer.cornerRadius=25
                tickoutBtn.layer.masksToBounds=true
                tickoutBtn.addTarget(self, action: #selector(onTakeOut), for: .touchUpInside)
                self.view.addSubview(tickoutBtn)
                tickoutBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(shutUpBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let sendBtn = UIButton(type: .custom)
                sendBtn.setTitleColor(UIColor.white, for: .normal)
                sendBtn.setTitleColor(UIColor.white, for: .selected)
                sendBtn.setTitleColor(UIColor.white, for: .highlighted)
                sendBtn.setTitleColor(UIColor.white, for: .disabled)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .normal)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .selected)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .highlighted)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .disabled)
                sendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
                sendBtn.layer.cornerRadius=25
                sendBtn.layer.masksToBounds=true
                sendBtn.addTarget(self, action: #selector(onSendMessage), for: .touchUpInside)
                self.view.addSubview(sendBtn)
                sendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tickoutBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let addFriendBtn = UIButton(type: .custom)
                addFriendBtn.setTitleColor(UIColor.white, for: .normal)
                addFriendBtn.setTitleColor(UIColor.white, for: .selected)
                addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
                addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .normal)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .selected)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .highlighted)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .disabled)
                addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                addFriendBtn.layer.cornerRadius=25
                addFriendBtn.layer.masksToBounds=true
                addFriendBtn.addTarget(self, action: #selector(onGotoAddFriend), for: .touchUpInside)
                self.view.addSubview(addFriendBtn)
                addFriendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(sendBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
            }
        }else if group?.is_menager==1 {
            if !(member?.inv_name?.isEmpty ?? true) {
                let GetGroupView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GetGroupView.backgroundColor = UIColor.white
                self.view.addSubview(GetGroupView)
                GetGroupView.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                    make?.top.equalTo()(focusView.mas_bottom)?.offset()(8)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                }
                let GetGroupLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GetGroupLabel.font = UIFont.systemFont(ofSize: 16)
                GetGroupLabel.text = NSLocalizedString("JoinGroupWay", comment: "Join group way")
                GetGroupView.addSubview(GetGroupLabel)
                GetGroupLabel.mas_makeConstraints { (make) in
                    make?.left.equalTo()(GetGroupView.mas_left)?.offset()(16)
                    make?.top.equalTo()(GetGroupView)?.offset()(20)
                    make?.bottom.equalTo()(GetGroupView)?.offset()(-20)
                }
                let GetGroup = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GetGroup.textColor = UIColor.hexadecimalColor(hexadecimal: "#979797")
                GetGroup.font = UIFont.systemFont(ofSize: 14)
                GetGroup.text = String.localizedStringWithFormat(NSLocalizedString("JoinGroupThrough", comment: "Invite to group through %@"), member?.inv_name ?? "")
                GetGroup.textAlignment = .right
                GetGroupView.addSubview(GetGroup)
                GetGroup.mas_makeConstraints { (make) in
                    make?.right.equalTo()(GetGroupView.mas_right)?.offset()(-16)
                    make?.centerY.equalTo()(GetGroupLabel)
                    make?.width.equalTo()(self.view.frame.size.width * 0.7)
                }
                let groupNickName = UIView(frame: .zero)
                groupNickName.backgroundColor = UIColor.white
                let tap3 = UITapGestureRecognizer(target: self, action: #selector(changeGroupMemberName(g:)))
                groupNickName.addGestureRecognizer(tap3)
                self.view.addSubview(groupNickName)
                groupNickName.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                    make?.top.equalTo()(focusView.mas_bottom)?.offset()(8)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                }
                let GroupNickNimeTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GroupNickNimeTitleLabel.font = UIFont.systemFont(ofSize: 16)
                GroupNickNimeTitleLabel.text = NSLocalizedString("GroupNickName", comment: "Group nickname")
                groupNickName.addSubview(GroupNickNimeTitleLabel)
                GroupNickNimeTitleLabel.mas_makeConstraints { (make) in
                    make?.left.equalTo()(groupNickName.mas_left)?.offset()(16)
                    make?.top.equalTo()(groupNickName)?.offset()(20)
                    make?.bottom.equalTo()(groupNickName)?.offset()(-20)
                }
                let GroupNickNimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                GroupNickNimeLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#979797")
                GroupNickNimeLabel.font = UIFont.systemFont(ofSize: 14)
                GroupNickNimeLabel.text = member?.group_user_nickname
                GroupNickNimeLabel.textAlignment = .right
                groupNickName.addSubview(GroupNickNimeLabel)
                GroupNickNimeLabel.mas_makeConstraints { (make) in
                    make?.right.equalTo()(groupNickName.mas_right)?.offset()(-16)
                    make?.centerY.equalTo()(GetGroupLabel)
                    make?.width.equalTo()(self.view.frame.size.width * 0.7)
                }
                tView = groupNickName
            }
            if member?.is_administrator == 1 || member?.is_manager == 1 {
                let sendBtn = UIButton(type: .custom)
                sendBtn.setTitleColor(UIColor.white, for: .normal)
                sendBtn.setTitleColor(UIColor.white, for: .selected)
                sendBtn.setTitleColor(UIColor.white, for: .highlighted)
                sendBtn.setTitleColor(UIColor.white, for: .disabled)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .normal)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .selected)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .highlighted)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .disabled)
                sendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
                sendBtn.layer.cornerRadius=25
                sendBtn.layer.masksToBounds=true
                sendBtn.addTarget(self, action: #selector(onSendMessage), for: .touchUpInside)
                self.view.addSubview(sendBtn)
                sendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tView?.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let addFriendBtn = UIButton(type: .custom)
                addFriendBtn.setTitleColor(UIColor.white, for: .normal)
                addFriendBtn.setTitleColor(UIColor.white, for: .selected)
                addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
                addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .normal)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .selected)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .highlighted)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .disabled)
                addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                addFriendBtn.layer.cornerRadius=25
                addFriendBtn.layer.masksToBounds=true
                addFriendBtn.addTarget(self, action: #selector(onGotoAddFriend), for: .touchUpInside)
                self.view.addSubview(addFriendBtn)
                addFriendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(sendBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
            }else{
                shutUpBtn.setTitleColor(UIColor.white, for: .normal)
                shutUpBtn.setTitleColor(UIColor.white, for: .selected)
                shutUpBtn.setTitleColor(UIColor.white, for: .highlighted)
                shutUpBtn.setTitleColor(UIColor.white, for: .disabled)
                if member?.is_shield == 1 {
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .normal)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .selected)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .highlighted)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .disabled)
                }else{
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .normal)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .selected)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .highlighted)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .disabled)
                }
                shutUpBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE7C08")
                shutUpBtn.layer.cornerRadius=25
                shutUpBtn.layer.masksToBounds=true
                shutUpBtn.addTarget(self, action: #selector(onSheild), for: .touchUpInside)
                self.view.addSubview(shutUpBtn)
                shutUpBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tView?.mas_bottom)?.offset()(40)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let tickoutBtn = UIButton(type: .custom)
                tickoutBtn.setTitleColor(UIColor.white, for: .normal)
                tickoutBtn.setTitleColor(UIColor.white, for: .selected)
                tickoutBtn.setTitleColor(UIColor.white, for: .highlighted)
                tickoutBtn.setTitleColor(UIColor.white, for: .disabled)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .normal)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .selected)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .highlighted)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .disabled)
                tickoutBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EDCB01")
                tickoutBtn.layer.cornerRadius=25
                tickoutBtn.layer.masksToBounds=true
                tickoutBtn.addTarget(self, action: #selector(onTakeOut), for: .touchUpInside)
                self.view.addSubview(tickoutBtn)
                tickoutBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(shutUpBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let sendBtn = UIButton(type: .custom)
                sendBtn.setTitleColor(UIColor.white, for: .normal)
                sendBtn.setTitleColor(UIColor.white, for: .selected)
                sendBtn.setTitleColor(UIColor.white, for: .highlighted)
                sendBtn.setTitleColor(UIColor.white, for: .disabled)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .normal)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .selected)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .highlighted)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .disabled)
                sendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
                sendBtn.layer.cornerRadius=25
                sendBtn.layer.masksToBounds=true
                sendBtn.addTarget(self, action: #selector(onSendMessage), for: .touchUpInside)
                self.view.addSubview(sendBtn)
                sendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tickoutBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let addFriendBtn = UIButton(type: .custom)
                addFriendBtn.setTitleColor(UIColor.white, for: .normal)
                addFriendBtn.setTitleColor(UIColor.white, for: .selected)
                addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
                addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .normal)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .selected)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .highlighted)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .disabled)
                addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                addFriendBtn.layer.cornerRadius=25
                addFriendBtn.layer.masksToBounds=true
                addFriendBtn.addTarget(self, action: #selector(onGotoAddFriend), for: .touchUpInside)
                self.view.addSubview(addFriendBtn)
                addFriendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(sendBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
            }
        }else{
            if member?.is_administrator == 1 || member?.is_manager == 1 {
                let sendBtn = UIButton(type: .custom)
                sendBtn.setTitleColor(UIColor.white, for: .normal)
                sendBtn.setTitleColor(UIColor.white, for: .selected)
                sendBtn.setTitleColor(UIColor.white, for: .highlighted)
                sendBtn.setTitleColor(UIColor.white, for: .disabled)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .normal)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .selected)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .highlighted)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .disabled)
                sendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
                sendBtn.layer.cornerRadius=25
                sendBtn.layer.masksToBounds=true
                sendBtn.addTarget(self, action: #selector(onSendMessage), for: .touchUpInside)
                self.view.addSubview(sendBtn)
                sendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tView?.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let addFriendBtn = UIButton(type: .custom)
                addFriendBtn.setTitleColor(UIColor.white, for: .normal)
                addFriendBtn.setTitleColor(UIColor.white, for: .selected)
                addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
                addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .normal)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .selected)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .highlighted)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .disabled)
                addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                addFriendBtn.layer.cornerRadius=25
                addFriendBtn.layer.masksToBounds=true
                addFriendBtn.addTarget(self, action: #selector(onGotoAddFriend), for: .touchUpInside)
                self.view.addSubview(addFriendBtn)
                addFriendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(sendBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
            }else if group?.group_type == 1 {
                let sendBtn = UIButton(type: .custom)
                sendBtn.setTitleColor(UIColor.white, for: .normal)
                sendBtn.setTitleColor(UIColor.white, for: .selected)
                sendBtn.setTitleColor(UIColor.white, for: .highlighted)
                sendBtn.setTitleColor(UIColor.white, for: .disabled)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .normal)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .selected)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .highlighted)
                sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .disabled)
                sendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
                sendBtn.layer.cornerRadius=25
                sendBtn.layer.masksToBounds=true
                sendBtn.addTarget(self, action: #selector(onSendMessage), for: .touchUpInside)
                self.view.addSubview(sendBtn)
                sendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tView?.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let addFriendBtn = UIButton(type: .custom)
                addFriendBtn.setTitleColor(UIColor.white, for: .normal)
                addFriendBtn.setTitleColor(UIColor.white, for: .selected)
                addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
                addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .normal)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .selected)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .highlighted)
                addFriendBtn.setTitle(NSLocalizedString("AddToContract", comment: "Add to contract"), for: .disabled)
                addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                addFriendBtn.layer.cornerRadius=25
                addFriendBtn.layer.masksToBounds=true
                addFriendBtn.addTarget(self, action: #selector(onGotoAddFriend), for: .touchUpInside)
                self.view.addSubview(addFriendBtn)
                addFriendBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(sendBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
            }
        }
    }
    
    // -MARK: -好友群聊
    func friendGroupChat() {
        let more = UIBarButtonItem(image: UIImage(named: "圆点菜单"), style: .plain, target: self, action: #selector(onMoreSetting))
        self.navigationItem.rightBarButtonItem = more
        let userInfo = UIView(frame: .zero)
        userInfo.backgroundColor=UIColor.white
        self.view.addSubview(userInfo)
        userInfo.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(128)
        }
        if !(model?.portrait?.isEmpty ?? true) {
            headImageView.sd_setImage(with: URL(string: member?.portrait ?? ""), completed: nil)
        }
        userInfo.addSubview(headImageView)
        headImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(userInfo)?.offset()(16)
            make?.width.mas_equalTo()(80)
            make?.height.equalTo()(headImageView.mas_width)
            make?.centerY.equalTo()(userInfo)
        }
        nameLabel.font=UIFont.systemFont(ofSize: 22)
        nameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#000B2A")
        nameLabel.text=member?.user_name
        userInfo.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.top.equalTo()(headImageView)?.offset()(6)
        }
        idLabel.font=UIFont.systemFont(ofSize: 16)
        idLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
        idLabel.text=String(format: NSLocalizedString("ChattingID", comment: "Chatting ID") + ":%@", member?.id_card ?? "")
        userInfo.addSubview(idLabel)
        idLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.bottom.equalTo()(headImageView)?.offset()(-6)
        }
        if (model?.target_user_nickname != model?.friend_self_name) && (!(model?.target_user_nickname?.isEmpty ?? true)) {
            nickNameLabel.font=UIFont.systemFont(ofSize: 16)
            nickNameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
            nickNameLabel.text=String(format: NSLocalizedString("Remarks", comment: "Remarks") + ":%@", model?.target_user_nickname ?? "")
            userInfo.addSubview(nickNameLabel)
            nickNameLabel.mas_makeConstraints { (make) in
                make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
                make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
                make?.bottom.equalTo()(idLabel.mas_top)?.offset()(-3)
            }
        }else{
            if !(member?.group_user_nickname?.isEmpty ?? true) {
                nickNameLabel.font=UIFont.systemFont(ofSize: 16)
                nickNameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
                nickNameLabel.text=String(format: NSLocalizedString("GroupNickName", comment: "Group nickname") + ":%@", member?.group_user_nickname ?? "")
                userInfo.addSubview(nickNameLabel)
                nickNameLabel.mas_makeConstraints { (make) in
                    make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
                    make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
                    make?.bottom.equalTo()(idLabel.mas_top)?.offset()(-3)
                }
            }
        }
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        focusView.backgroundColor = UIColor.white
        self.view.addSubview(focusView)
        focusView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(userInfo.mas_bottom)?.offset()(8)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
        }
        let focusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        focusLabel.font = UIFont.systemFont(ofSize: 16)
        focusLabel.text = NSLocalizedString("FocusInGroup", comment: "Focus in group")
        focusView.addSubview(focusLabel)
        focusLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(focusView.mas_left)?.offset()(16)
            make?.top.equalTo()(focusView)?.offset()(20)
            make?.bottom.equalTo()(focusView)?.offset()(-20)
        }
        let focusSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        focusSwitch.onTintColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
        focusSwitch.isOn = QueryFriend.shared.checkFocus(userId: member!.user_id!, groupId: member!.group_id!)
        focusSwitch.addTarget(self, action: #selector(onFocus(sender:)), for: .touchUpInside)
        focusView.addSubview(focusSwitch)
        focusSwitch.mas_makeConstraints { (make) in
            make?.right.equalTo()(focusView.mas_right)?.offset()(-30)
            make?.centerY.equalTo()(focusView.mas_centerY)
            make?.height.mas_equalTo()(31)
            make?.width.mas_equalTo()(47)
        }
        weak var tView = focusView
        if !(member?.inv_name?.isEmpty ?? true) {
            let GetGroupView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            GetGroupView.backgroundColor = UIColor.white
            self.view.addSubview(GetGroupView)
            GetGroupView.mas_makeConstraints { (make) in
                make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                make?.top.equalTo()(focusView.mas_bottom)?.offset()(8)
                make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            }
            let GetGroupLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            GetGroupLabel.font = UIFont.systemFont(ofSize: 16)
            GetGroupLabel.text = NSLocalizedString("JoinGroupWay", comment: "Join group way")
            GetGroupView.addSubview(GetGroupLabel)
            GetGroupLabel.mas_makeConstraints { (make) in
                make?.left.equalTo()(GetGroupView.mas_left)?.offset()(16)
                make?.top.equalTo()(GetGroupView)?.offset()(20)
                make?.bottom.equalTo()(GetGroupView)?.offset()(-20)
            }
            let GetGroup = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            GetGroup.textColor = UIColor.hexadecimalColor(hexadecimal: "#979797")
            GetGroup.font = UIFont.systemFont(ofSize: 14)
            GetGroup.text = String.localizedStringWithFormat(NSLocalizedString("JoinGroupThrough", comment: "Invite to group through %@"), member?.inv_name ?? "")
            GetGroup.textAlignment = .right
            GetGroupView.addSubview(GetGroup)
            GetGroup.mas_makeConstraints { (make) in
                make?.right.equalTo()(GetGroupView.mas_right)?.offset()(-16)
                make?.centerY.equalTo()(GetGroupLabel)
                make?.width.equalTo()(self.view.frame.size.width * 0.7)
            }
            let groupNickName = UIView(frame: .zero)
            groupNickName.backgroundColor = UIColor.white
            let tap3 = UITapGestureRecognizer(target: self, action: #selector(changeGroupMemberName(g:)))
            groupNickName.addGestureRecognizer(tap3)
            self.view.addSubview(groupNickName)
            groupNickName.mas_makeConstraints { (make) in
                make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                make?.top.equalTo()(focusView.mas_bottom)?.offset()(8)
                make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            }
            let GroupNickNimeTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            GroupNickNimeTitleLabel.font = UIFont.systemFont(ofSize: 16)
            GroupNickNimeTitleLabel.text = NSLocalizedString("GroupNickName", comment: "Group nickname")
            groupNickName.addSubview(GroupNickNimeTitleLabel)
            GroupNickNimeTitleLabel.mas_makeConstraints { (make) in
                make?.left.equalTo()(groupNickName.mas_left)?.offset()(16)
                make?.top.equalTo()(groupNickName)?.offset()(20)
                make?.bottom.equalTo()(groupNickName)?.offset()(-20)
            }
            let GroupNickNimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            GroupNickNimeLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#979797")
            GroupNickNimeLabel.font = UIFont.systemFont(ofSize: 14)
            GroupNickNimeLabel.text = member?.group_user_nickname
            GroupNickNimeLabel.textAlignment = .right
            groupNickName.addSubview(GroupNickNimeLabel)
            GroupNickNimeLabel.mas_makeConstraints { (make) in
                make?.right.equalTo()(groupNickName.mas_right)?.offset()(-16)
                make?.centerY.equalTo()(GetGroupLabel)
                make?.width.equalTo()(self.view.frame.size.width * 0.7)
            }
            tView = groupNickName
        }
        let momentPanl = UIView(frame: .zero)
         momentPanl.backgroundColor=UIColor.white
         momentPanl.isUserInteractionEnabled=true
         let tap3=UITapGestureRecognizer(target: self, action: #selector(gotoMooment(g:)))
         momentPanl.addGestureRecognizer(tap3)
         self.view.addSubview(momentPanl)
         momentPanl.mas_makeConstraints { (make) in
             make?.left.equalTo()(self.view)
            make?.top.equalTo()(tView?.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 8))
             make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(60)
         }
        let moment = UILabel(frame: .zero)
        moment.font = DCUtill.FONTX(16)
        moment.text = "朋友圈"
        momentPanl.addSubview(moment)
        moment.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(16))
            make?.centerY.equalTo()(momentPanl)
        }
        for i in 0...3 {
            let img = UIImageView(frame: .zero)
            img.layer.masksToBounds = true
            img.layer.cornerRadius = DCUtill.SCRATIOX(6)
            momentPanl.addSubview(img)
            img.mas_makeConstraints { (make) in
                make?.width.height()?.mas_equalTo()(DCUtill.SCRATIOX(50))
                make?.left.equalTo()(moment.mas_right)?.offset()(DCUtill.SCRATIOX(CGFloat(22 + i * 60)))
                make?.centerY.equalTo()(momentPanl)
            }
            momentPic.append(img)
        }
        let jt3 = UIImageView(image: UIImage(named: "friend_hide"))
        momentPanl.addSubview(jt3)
        jt3.mas_makeConstraints { (make) in
            make?.right.equalTo()(momentPanl)?.offset()(-16)
            make?.height.mas_equalTo()(12)
            make?.width.mas_equalTo()(7)
            make?.centerY.equalTo()(moment)
        }
        weak var ttView=momentPanl
        if group?.is_admin == 1 {
            if member?.is_manager == 1 {
                let tickoutBtn = UIButton(type: .custom)
                tickoutBtn.setTitleColor(UIColor.white, for: .normal)
                tickoutBtn.setTitleColor(UIColor.white, for: .selected)
                tickoutBtn.setTitleColor(UIColor.white, for: .highlighted)
                tickoutBtn.setTitleColor(UIColor.white, for: .disabled)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .normal)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .selected)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .highlighted)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .disabled)
                tickoutBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                tickoutBtn.layer.cornerRadius=25
                tickoutBtn.layer.masksToBounds=true
                tickoutBtn.addTarget(self, action: #selector(onTakeOut), for: .touchUpInside)
                self.view.addSubview(tickoutBtn)
                tickoutBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tView?.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                ttView=tickoutBtn
            }else{
                shutUpBtn.setTitleColor(UIColor.white, for: .normal)
                shutUpBtn.setTitleColor(UIColor.white, for: .selected)
                shutUpBtn.setTitleColor(UIColor.white, for: .highlighted)
                shutUpBtn.setTitleColor(UIColor.white, for: .disabled)
                if member?.is_shield == 1 {
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .normal)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .selected)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .highlighted)
                    shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .disabled)
                }else{
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .normal)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .selected)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .highlighted)
                    shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .disabled)
                }
                shutUpBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE7C08")
                shutUpBtn.layer.cornerRadius=25
                shutUpBtn.layer.masksToBounds=true
                shutUpBtn.addTarget(self, action: #selector(onSheild), for: .touchUpInside)
                self.view.addSubview(shutUpBtn)
                shutUpBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(tView?.mas_bottom)?.offset()(40)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                let tickoutBtn = UIButton(type: .custom)
                tickoutBtn.setTitleColor(UIColor.white, for: .normal)
                tickoutBtn.setTitleColor(UIColor.white, for: .selected)
                tickoutBtn.setTitleColor(UIColor.white, for: .highlighted)
                tickoutBtn.setTitleColor(UIColor.white, for: .disabled)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .normal)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .selected)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .highlighted)
                tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .disabled)
                tickoutBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EDCB01")
                tickoutBtn.layer.cornerRadius=25
                tickoutBtn.layer.masksToBounds=true
                tickoutBtn.addTarget(self, action: #selector(onTakeOut), for: .touchUpInside)
                self.view.addSubview(tickoutBtn)
                tickoutBtn.mas_makeConstraints { (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                    make?.top.equalTo()(shutUpBtn.mas_bottom)?.offset()(28)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
                }
                ttView=tickoutBtn
            }
        }else if group?.is_menager == 1 && member?.is_administrator == 2 && member?.is_manager == 2 {
            shutUpBtn.setTitleColor(UIColor.white, for: .normal)
            shutUpBtn.setTitleColor(UIColor.white, for: .selected)
            shutUpBtn.setTitleColor(UIColor.white, for: .highlighted)
            shutUpBtn.setTitleColor(UIColor.white, for: .disabled)
            if member?.is_shield == 1 {
                shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .normal)
                shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .selected)
                shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .highlighted)
                shutUpBtn.setTitle(NSLocalizedString("UnshelidMember", comment: "Unshelid"), for: .disabled)
            }else{
                shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .normal)
                shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .selected)
                shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .highlighted)
                shutUpBtn.setTitle(NSLocalizedString("ShelidMember", comment: "Shelid"), for: .disabled)
            }
            shutUpBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE7C08")
            shutUpBtn.layer.cornerRadius=25
            shutUpBtn.layer.masksToBounds=true
            shutUpBtn.addTarget(self, action: #selector(onSheild), for: .touchUpInside)
            self.view.addSubview(shutUpBtn)
            shutUpBtn.mas_makeConstraints { (make) in
                make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                make?.top.equalTo()(tView?.mas_bottom)?.offset()(40)
                make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
            }
            let tickoutBtn = UIButton(type: .custom)
            tickoutBtn.setTitleColor(UIColor.white, for: .normal)
            tickoutBtn.setTitleColor(UIColor.white, for: .selected)
            tickoutBtn.setTitleColor(UIColor.white, for: .highlighted)
            tickoutBtn.setTitleColor(UIColor.white, for: .disabled)
            tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .normal)
            tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .selected)
            tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .highlighted)
            tickoutBtn.setTitle(NSLocalizedString("KickOut", comment: "Kick out"), for: .disabled)
            tickoutBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EDCB01")
            tickoutBtn.layer.cornerRadius=25
            tickoutBtn.layer.masksToBounds=true
            tickoutBtn.addTarget(self, action: #selector(onTakeOut), for: .touchUpInside)
            self.view.addSubview(tickoutBtn)
            tickoutBtn.mas_makeConstraints { (make) in
                make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
                make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
                make?.top.equalTo()(shutUpBtn.mas_bottom)?.offset()(28)
                make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
            }
            ttView=tickoutBtn
        }
        let sendBtn = UIButton(type: .custom)
        sendBtn.setTitleColor(UIColor.white, for: .normal)
        sendBtn.setTitleColor(UIColor.white, for: .selected)
        sendBtn.setTitleColor(UIColor.white, for: .highlighted)
        sendBtn.setTitleColor(UIColor.white, for: .disabled)
        sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .normal)
        sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .selected)
        sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .highlighted)
        sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .disabled)
        sendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        sendBtn.layer.cornerRadius=25
        sendBtn.layer.masksToBounds=true
        sendBtn.addTarget(self, action: #selector(onSendMessage), for: .touchUpInside)
        self.view.addSubview(sendBtn)
        sendBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
            make?.top.equalTo()(ttView?.mas_bottom)?.offset()(28)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
        }
        let addFriendBtn = UIButton(type: .custom)
        addFriendBtn.setTitleColor(UIColor.white, for: .normal)
        addFriendBtn.setTitleColor(UIColor.white, for: .selected)
        addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
        addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
        addFriendBtn.setTitle(NSLocalizedString("MakeCall", comment: "Make call"), for: .normal)
        addFriendBtn.setTitle(NSLocalizedString("MakeCall", comment: "Make call"), for: .selected)
        addFriendBtn.setTitle(NSLocalizedString("MakeCall", comment: "Make call"), for: .highlighted)
        addFriendBtn.setTitle(NSLocalizedString("MakeCall", comment: "Make call"), for: .disabled)
        addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
        addFriendBtn.layer.cornerRadius=25
        addFriendBtn.layer.masksToBounds=true
        addFriendBtn.addTarget(self, action: #selector(onCallMessage), for: .touchUpInside)
        self.view.addSubview(addFriendBtn)
        addFriendBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
            make?.top.equalTo()(sendBtn.mas_bottom)?.offset()(28)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
        }
    }
    
    // -MARK: -好友信息
    func friendInfo() {
        let more = UIBarButtonItem(image: UIImage(named: "圆点菜单"), style: .plain, target: self, action: #selector(onMoreSetting))
        self.navigationItem.rightBarButtonItem = more
        let userInfo = UIView(frame: .zero)
        userInfo.backgroundColor=UIColor.white
        self.view.addSubview(userInfo)
        userInfo.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(128)
        }
        if !(model?.portrait?.isEmpty ?? true) {
            headImageView.sd_setImage(with: URL(string: model?.portrait ?? ""), completed: nil)
        }
        userInfo.addSubview(headImageView)
        headImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(userInfo)?.offset()(16)
            make?.width.mas_equalTo()(80)
            make?.height.equalTo()(headImageView.mas_width)
            make?.centerY.equalTo()(userInfo)
        }
        nameLabel.font=UIFont.systemFont(ofSize: 22)
        nameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#000B2A")
        nameLabel.text=model?.friend_self_name
        userInfo.addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.top.equalTo()(headImageView)?.offset()(6)
        }
        idLabel.font=UIFont.systemFont(ofSize: 16)
        idLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
        idLabel.text=String(format: NSLocalizedString("ChattingID", comment: "Chatting ID") + ":%@", model?.id_card ?? "")
        userInfo.addSubview(idLabel)
        idLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
            make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
            make?.bottom.equalTo()(headImageView)?.offset()(-6)
        }
        if (model?.target_user_nickname != model?.friend_self_name) && (!(model?.target_user_nickname?.isEmpty ?? true)) {
            nickNameLabel.font=UIFont.systemFont(ofSize: 16)
            nickNameLabel.textColor=UIColor.hexadecimalColor(hexadecimal: "#ACACAC")
            nickNameLabel.text=String(format: NSLocalizedString("Remarks", comment: "Remarks") + ":%@", model?.target_user_nickname ?? "")
            userInfo.addSubview(nickNameLabel)
            nickNameLabel.mas_makeConstraints { (make) in
                make?.left.equalTo()(headImageView.mas_right)?.offset()(18)
                make?.right.greaterThanOrEqualTo()(userInfo)?.offset()(-16)
                make?.bottom.equalTo()(idLabel.mas_top)?.offset()(-3)
            }
        }
        let nicknamePanl = UIView(frame: .zero)
        nicknamePanl.backgroundColor=UIColor.white
        nicknamePanl.isUserInteractionEnabled=true
        let tap1=UITapGestureRecognizer(target: self, action: #selector(onChangeBackUpName(g:)))
        nicknamePanl.addGestureRecognizer(tap1)
        self.view.addSubview(nicknamePanl)
        nicknamePanl.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(userInfo.mas_bottom)
            make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(60)
        }
        let SetNameLab = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
         SetNameLab.text = NSLocalizedString("ChangeRemarks", comment: "Change remarks")
         SetNameLab.font = UIFont.systemFont(ofSize: 16)
         nicknamePanl.addSubview(SetNameLab)
         SetNameLab.mas_makeConstraints { (make) in
            make?.center.equalTo()(nicknamePanl)
            make?.left.equalTo()(nicknamePanl)?.offset()(16)
         }
        let jt1 = UIImageView(image: UIImage(named: "friend_hide"))
        nicknamePanl.addSubview(jt1)
        jt1.mas_makeConstraints { (make) in
            make?.right.equalTo()(nicknamePanl.mas_right)?.offset()(-16)
            make?.height.mas_equalTo()(12)
            make?.width.mas_equalTo()(7)
            make?.centerY.equalTo()(SetNameLab)
        }
         let verityPanl = UIView(frame: .zero)
         verityPanl.backgroundColor=UIColor.white
         verityPanl.isUserInteractionEnabled=true
         let tap2=UITapGestureRecognizer(target: self, action: #selector(moveFriendGroup(g:)))
         verityPanl.addGestureRecognizer(tap2)
         self.view.addSubview(verityPanl)
         verityPanl.mas_makeConstraints { (make) in
             make?.left.equalTo()(self.view)
             make?.top.equalTo()(nicknamePanl.mas_bottom)
             make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(60)
         }
         SetBeiZhuLab.text = NSLocalizedString("SetFriendGroup", comment: "Set friend to group")
         SetBeiZhuLab.font = UIFont.systemFont(ofSize: 16)
         verityPanl.addSubview(SetBeiZhuLab)
         SetBeiZhuLab.mas_makeConstraints { (make) in
             make?.top.equalTo()(verityPanl)?.offset()(20)
            make?.left.equalTo()(verityPanl)?.offset()(16)
         }
        let jt2 = UIImageView(image: UIImage(named: "friend_hide"))
        verityPanl.addSubview(jt2)
        jt2.mas_makeConstraints { (make) in
            make?.right.equalTo()(verityPanl)?.offset()(-16)
            make?.height.mas_equalTo()(12)
            make?.width.mas_equalTo()(7)
            make?.centerY.equalTo()(SetBeiZhuLab)
        }
        let momentPanl = UIView(frame: .zero)
         momentPanl.backgroundColor=UIColor.white
         momentPanl.isUserInteractionEnabled=true
         let tap3=UITapGestureRecognizer(target: self, action: #selector(gotoMooment(g:)))
         momentPanl.addGestureRecognizer(tap3)
         self.view.addSubview(momentPanl)
         momentPanl.mas_makeConstraints { (make) in
             make?.left.equalTo()(self.view)
            make?.top.equalTo()(verityPanl.mas_bottom)?.offset()(DCUtill.SCRATIO(x: 8))
             make?.right.equalTo()(self.view)
            make?.height.mas_equalTo()(60)
         }
        let moment = UILabel(frame: .zero)
        moment.font = DCUtill.FONTX(16)
        moment.text = "朋友圈"
        momentPanl.addSubview(moment)
        moment.mas_makeConstraints { (make) in
            make?.left.offset()(DCUtill.SCRATIOX(16))
            make?.centerY.equalTo()(momentPanl)
        }
        for i in 0...3 {
            let img = UIImageView(frame: .zero)
            img.layer.masksToBounds = true
            img.layer.cornerRadius = DCUtill.SCRATIOX(6)
            momentPanl.addSubview(img)
            img.mas_makeConstraints { (make) in
                make?.width.height()?.mas_equalTo()(DCUtill.SCRATIOX(50))
                make?.left.equalTo()(moment.mas_right)?.offset()(DCUtill.SCRATIOX(CGFloat(22 + i * 60)))
                make?.centerY.equalTo()(momentPanl)
            }
            momentPic.append(img)
        }
        let jt3 = UIImageView(image: UIImage(named: "friend_hide"))
        momentPanl.addSubview(jt3)
        jt3.mas_makeConstraints { (make) in
            make?.right.equalTo()(momentPanl)?.offset()(-16)
            make?.height.mas_equalTo()(12)
            make?.width.mas_equalTo()(7)
            make?.centerY.equalTo()(moment)
        }
        let sendBtn = UIButton(type: .custom)
        sendBtn.setTitleColor(UIColor.white, for: .normal)
        sendBtn.setTitleColor(UIColor.white, for: .selected)
        sendBtn.setTitleColor(UIColor.white, for: .highlighted)
        sendBtn.setTitleColor(UIColor.white, for: .disabled)
        sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .normal)
        sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .selected)
        sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .highlighted)
        sendBtn.setTitle(NSLocalizedString("SendMessage", comment: "Send message"), for: .disabled)
        sendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#FE0846")
        sendBtn.layer.cornerRadius=25
        sendBtn.layer.masksToBounds=true
        sendBtn.addTarget(self, action: #selector(onSendMessage), for: .touchUpInside)
        self.view.addSubview(sendBtn)
        sendBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
            make?.top.equalTo()(momentPanl.mas_bottom)?.offset()(28)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
        }
        let addFriendBtn = UIButton(type: .custom)
        addFriendBtn.setTitleColor(UIColor.white, for: .normal)
        addFriendBtn.setTitleColor(UIColor.white, for: .selected)
        addFriendBtn.setTitleColor(UIColor.white, for: .highlighted)
        addFriendBtn.setTitleColor(UIColor.white, for: .disabled)
        addFriendBtn.setTitle(NSLocalizedString("MakeCall", comment: "Make call"), for: .normal)
        addFriendBtn.setTitle(NSLocalizedString("MakeCall", comment: "Make call"), for: .selected)
        addFriendBtn.setTitle(NSLocalizedString("MakeCall", comment: "Make call"), for: .highlighted)
        addFriendBtn.setTitle(NSLocalizedString("MakeCall", comment: "Make call"), for: .disabled)
        addFriendBtn.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#0148ED")
        addFriendBtn.layer.cornerRadius=25
        addFriendBtn.layer.masksToBounds=true
        addFriendBtn.addTarget(self, action: #selector(onCallMessage), for: .touchUpInside)
        self.view.addSubview(addFriendBtn)
        addFriendBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(50)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-50)
            make?.top.equalTo()(sendBtn.mas_bottom)?.offset()(28)
            make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 50))
        }
    }
    
    @objc func onPreviewAvater(g:UIGestureRecognizer){
        if g.state == .ended {
            let data = DCImageData()
            if type==1 {
                data.imageURL = URL(string: String(newFriendModel?.portrait?.split(separator: "?")[0] ?? Substring(newFriendModel!.portrait!)))
            }else if type == 2 || type == 3 {
                data.imageURL = URL(string: String(member?.portrait?.split(separator: "?")[0] ?? Substring(member!.portrait!)))
            }else{
                data.imageURL = URL(string: String(model?.portrait?.split(separator: "?")[0] ?? Substring(model!.portrait!)))
            }
            data.projectiveView=headImageView
            let browser = YBImageBrowser()
            browser.dataSourceArray = [data]
            browser.currentPage = 0
            browser.show(to: self.navigationController!.view)
        }
    }
    
    @objc func changeGroupMemberName(g:UIGestureRecognizer){
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
        let vc = ChangeBackUpNickNameViewController()
        vc.typeID = 3
        vc.group = group
        vc.member = member
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func moveFriendGroup(g:UIGestureRecognizer){
        if g.state == .ended {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
            let vc = MoveFriendToGroupViewController()
            vc.userId = model?.user_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func gotoMooment(g:UIGestureRecognizer) {
        if g.state == .ended {
            let vc = PersonalMomentViewController()
            if type == 3 {
                vc.userid = member?.user_id
                vc.headURL = member?.portrait
            }
            if type == 4 {
                vc.userid = model?.user_id
                vc.headURL = model?.portrait
            }
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getMoment() {
        DispatchQueue.global().async {
            let m = GetMomentByUserIdSendModel()
            if self.type == 3 {
                m.target_user_id = self.member?.user_id
            }else{
                m.target_user_id = self.model?.user_id
            }
            BoXinProvider.request(.GetMomentByUserId(model: m), callbackQueue: .main, progress: nil) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = GetMomentByUserIdReciveModel.deserialize(from: try? res.mapString()) {
                            if model.code == 200 {
                                if let data = model.data {
                                    for mm in data {
                                        if !(mm?.pic1?.isEmpty ?? true) {
                                            if mm?.pic1?.hasSuffix(".mp4") ?? false {
                                                for (idx,img) in self.momentPic.enumerated() {
                                                    if img.image == nil {
                                                        img.sd_setImage(with: URL(string: mm?.pic2 ?? ""), completed: nil)
                                                        if idx == 3 {
                                                            return
                                                        }
                                                    }
                                                }
                                                continue
                                            }
                                            for (idx,img) in self.momentPic.enumerated() {
                                                if img.image == nil {
                                                    img.sd_setImage(with: URL(string: mm?.pic1 ?? ""), completed: nil)
                                                    if idx == 3 {
                                                        return
                                                    }
                                                }
                                            }
                                            if !(mm?.pic2?.isEmpty ?? true) {
                                                for (idx,img) in self.momentPic.enumerated() {
                                                    if img.image == nil {
                                                        img.sd_setImage(with: URL(string: mm?.pic2 ?? ""), completed: nil)
                                                        if idx == 3 {
                                                            return
                                                        }
                                                    }
                                                }
                                                if !(mm?.pic3?.isEmpty ?? true) {
                                                    for (idx,img) in self.momentPic.enumerated() {
                                                        if img.image == nil {
                                                            img.sd_setImage(with: URL(string: mm?.pic3 ?? ""), completed: nil)
                                                            if idx == 3 {
                                                                return
                                                            }
                                                        }
                                                    }
                                                    if !(mm?.pic4?.isEmpty ?? true) {
                                                        for (idx,img) in self.momentPic.enumerated() {
                                                            if img.image == nil {
                                                                img.sd_setImage(with: URL(string: mm?.pic4 ?? ""), completed: nil)
                                                                if idx == 3 {
                                                                    return
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                self.view.makeToast(model.message)
                            }
                        }else{
                            self.view.makeToast("数据解析失败")
                        }
                    }else{
                        self.view.makeToast("服务器链接失败")
                    }
                case .failure(_):
                    self.view.makeToast("网络连接失败")
                }
            }
        }
    }
}
