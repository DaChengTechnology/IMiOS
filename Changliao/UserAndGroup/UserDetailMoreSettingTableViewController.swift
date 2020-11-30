//
//  UserDetailMoreSettingTableViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SVProgressHUD

@objc class UserDetailMoreSettingTableViewController: UITableViewController {
    
    @objc var model:FriendData?
    var isChatTop:Bool = false
    var isLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "更多设置"
        tableView.register(UINib(nibName: "UserDetailSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDDetailSettingMore")
        tableView.register(UINib(nibName: "DeleteFriendTableViewCell", bundle: nil), forCellReuseIdentifier: "DeleteFriend")
        tableView.bounces = false
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        tableView.separatorStyle = .none
        NotificationCenter.default.addObserver(forName: NSNotification.Name("fireUpdateFromFriend"), object: nil, queue: OperationQueue.main) { (no) in
            if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
                for c in contact {
                    if c != nil && c?.data != nil {
                        for co in c!.data! {
                            if co?.user_id == self.model?.user_id {
                                self.model = co
                                self.tableView.reloadData()
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        SVProgressHUD.setDefaultMaskType(.clear)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.setDefaultMaskType(.none)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section==6 {
            return 2
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDDetailSettingMore", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = NSLocalizedString("TopConversation", comment: "Top conversation")
            if checkChatTop() {
                cell.settingSwitch.isOn = true
            }else{
                cell.settingSwitch.isOn = false
            }
            cell.settingSwitch.addTarget(self, action: #selector(onTop), for: .touchUpInside)
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDDetailSettingMore", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = NSLocalizedString("MessageNoTips", comment: "Message no tips")
            if model?.is_shield == 1 {
                cell.settingSwitch.isOn = true
            }else{
                cell.settingSwitch.isOn = false
            }
            cell.settingSwitch.addTarget(self, action: #selector(onNotips), for: .touchUpInside)
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDDetailSettingMore", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = NSLocalizedString("BurnAfterRead", comment: "Burn after reading")
            if model?.is_yhjf == 1 {
                cell.settingSwitch.isOn = true
            }else{
                cell.settingSwitch.isOn = false
            }
            cell.settingSwitch.addTarget(self, action: #selector(onYhjf), for: .touchUpInside)
            return cell
        }
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDDetailSettingMore", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = NSLocalizedString("Report", comment: "Report")
            cell.settingSwitch.isHidden = true
            return cell
        }
        if indexPath.section == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDDetailSettingMore", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = NSLocalizedString("ChangeChatBK", comment: "Change chat background")
            cell.settingSwitch.isHidden = true
            return cell
        }
        if indexPath.section == 5{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDDetailSettingMore", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = NSLocalizedString("ClearChat", comment: "Clear chat")
            cell.settingSwitch.isHidden = true
            return cell
        }
        if indexPath.section == 6  {
            if indexPath.row==0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteFriend", for: indexPath) as! DeleteFriendTableViewCell
                cell.tittleLabel.text = NSLocalizedString("ShareToFriend", comment: "Share to friend")
                return cell

            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteFriend", for: indexPath) as! DeleteFriendTableViewCell
        cell.tittleLabel.text = NSLocalizedString("DeleteFriend", comment: "Delete")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        return v
    }
    
    func checkChatTop() -> Bool {
        if let chatTop = [ChatTapData].deserialize(from: UserDefaults.standard.string(forKey: "ChatTop")) {
            for top in chatTop {
                if top?.target_id == model?.user_id {
                    isChatTop = true
                    return true
                }
            }
        }
        isChatTop = false
        return false
    }
    
    @objc func onYhjf() {
        if isLoading {
            return
        }
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! UserDetailSettingTableViewCell
        cell.settingSwitch.isHidden = true
        cell.setting.isHidden = false
        cell.setting.startAnimating()
        let model = YhjfSendModel()
        model.target_user_id = self.model?.user_id
        if self.model?.is_yhjf == 1 {
            DispatchQueue.global().async {
                BoXinProvider.request(.CancelYhjf(model: model)) { (result) in
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
                                        let cmdMSG = EMMessage(conversationID: self.model?.user_id, from: EMClient.shared()?.currentUsername, to: self.model?.user_id, body: EMCmdMessageBody(action: ""), ext: ["type":"fire","cmdFireStatus":2])
                                        EMClient.shared()?.chatManager.send(cmdMSG, progress: nil, completion: nil)
                                        BoXinUtil.getFriends { (b) in
                                            if b {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fireUpdate"), object: nil)
                                                DispatchQueue.main.async {
                                                    
                                                    self.model?.is_yhjf = 2
                                                    cell.setting.stopAnimating()
                                                    cell.setting.isHidden = true
                                                    cell.settingSwitch.isHidden = false
                                                    cell.settingSwitch.setOn(false, animated: false)
                                                }
                                            }else{
                                                DispatchQueue.main.async {
                                                    self.navigationController?.popToRootViewController(animated: true)
                                                }
                                            }
                                        }
                                    }else{
                                        DispatchQueue.main.async {
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
                                            cell.setting.stopAnimating()
                                            cell.setting.isHidden = true
                                            cell.settingSwitch.isHidden = false
                                            self.isLoading = false
                                            cell.settingSwitch.setOn(false, animated: false)
                                            self.view.makeToast(model.message)
                                        }
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        cell.setting.stopAnimating()
                                        cell.setting.isHidden = true
                                        cell.settingSwitch.isHidden = false
                                        self.isLoading = false
                                        cell.settingSwitch.setOn(false, animated: false)
                                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    }
                                }
                            }catch{
                                DispatchQueue.main.async {
                                    cell.setting.stopAnimating()
                                    cell.setting.isHidden = true
                                    cell.settingSwitch.isHidden = false
                                    self.isLoading = false
                                    cell.settingSwitch.setOn(false, animated: false)
                                    self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                }
                            }
                        }else if(res.statusCode == 404){
                            cell.setting.stopAnimating()
                            cell.setting.isHidden = true
                            cell.settingSwitch.isHidden = false
                            cell.settingSwitch.setOn(false, animated: false)
                            self.isLoading = false
                            self.view.makeToast("服务升级中，请稍后再试")
                        }else{
                            DispatchQueue.main.async {
                                cell.setting.stopAnimating()
                                cell.setting.isHidden = true
                                cell.settingSwitch.isHidden = false
                                self.isLoading = false
                                cell.settingSwitch.setOn(false, animated: false)
                                self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            }
                        }
                    case .failure(let err):
                        DispatchQueue.main.async {
                            cell.setting.stopAnimating()
                            cell.setting.isHidden = true
                            cell.settingSwitch.isHidden = false
                            self.isLoading = false
                            cell.settingSwitch.setOn(false, animated: false)
                            self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                        }
                        print(err.errorDescription!)
                    }
                }
            }
        }else{
            DispatchQueue.global().async {
                BoXinProvider.request(.SetYhjf(model: model)) { (result) in
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
                                        let cmdMSG = EMMessage(conversationID: self.model?.user_id, from: EMClient.shared()?.currentUsername, to: self.model?.user_id, body: EMCmdMessageBody(action: ""), ext: ["type":"fire","cmdFireStatus":1])
                                        EMClient.shared()?.chatManager.send(cmdMSG, progress: nil, completion: nil)
                                        BoXinUtil.getFriends { (b) in
                                            if b {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fireUpdate"), object: nil)
                                                DispatchQueue.main.async {
                                                    self.model?.is_yhjf = 1
                                                    cell.setting.stopAnimating()
                                                    cell.setting.isHidden = true
                                                    cell.settingSwitch.isHidden = false
                                                    cell.settingSwitch.setOn(true, animated: false)
                                                }
                                            }else{
                                                DispatchQueue.main.async {
                                                    self.navigationController?.popToRootViewController(animated: true)
                                                }
                                            }
                                        }
                                    }else{
                                        DispatchQueue.main.async {
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
                                            cell.setting.stopAnimating()
                                            cell.setting.isHidden = true
                                            cell.settingSwitch.isHidden = false
                                            self.isLoading = false
                                            cell.settingSwitch.setOn(true, animated: false)
                                            self.view.makeToast(model.message)
                                        }
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        cell.setting.stopAnimating()
                                        cell.setting.isHidden = true
                                        cell.settingSwitch.isHidden = false
                                        self.isLoading = false
                                        cell.settingSwitch.setOn(true, animated: false)
                                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    }
                                }
                            }catch{
                                DispatchQueue.main.async {
                                    cell.setting.stopAnimating()
                                    cell.setting.isHidden = true
                                    cell.settingSwitch.isHidden = false
                                    self.isLoading = false
                                    cell.settingSwitch.setOn(true, animated: false)
                                    self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                }
                            }
                        }else if(res.statusCode == 404){
                            cell.setting.stopAnimating()
                            cell.setting.isHidden = true
                            cell.settingSwitch.isHidden = false
                            cell.settingSwitch.setOn(false, animated: false)
                            self.isLoading = false
                            self.view.makeToast("服务升级中，请稍后再试")
                        }else{
                            DispatchQueue.main.async {
                                cell.setting.stopAnimating()
                                cell.setting.isHidden = true
                                cell.settingSwitch.isHidden = false
                                self.isLoading = false
                                cell.settingSwitch.setOn(true, animated: false)
                                self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            }
                        }
                    case .failure(let err):
                        DispatchQueue.main.async {
                            cell.setting.stopAnimating()
                            cell.setting.isHidden = true
                            cell.settingSwitch.isHidden = false
                            self.isLoading = false
                            cell.settingSwitch.setOn(true, animated: false)
                            self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                        }
                        print(err.errorDescription!)
                    }
                }
            }
        }
    }
    
    @objc func onTop() {
        if isLoading {
            return
        }
        self.isLoading = true
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! UserDetailSettingTableViewCell
        cell.settingSwitch.isHidden = true
        cell.setting.isHidden = false
        cell.setting.startAnimating()
        let model = ChatTopSendModel()
        model.type = 1
        model.target_id = self.model?.user_id
        if !isChatTop {
            SVProgressHUD.show()
            BoXinProvider.request(.SetChatTop(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = CheckChatTopReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.isLoading = false
                                    BoXinUtil.getChatTop(Complite: { (b) in
                                        if b {
                                            DispatchQueue.main.async {
                                                self.isChatTop = true
                                                cell.setting.stopAnimating()
                                                cell.setting.isHidden = true
                                                cell.settingSwitch.isHidden = false
                                                cell.settingSwitch.setOn(self.isChatTop, animated: false)
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
                                    cell.setting.stopAnimating()
                                    cell.setting.isHidden = true
                                    cell.settingSwitch.isHidden = false
                                    self.isLoading = false
                                    self.view.makeToast(model.message)
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                cell.setting.stopAnimating()
                                cell.setting.isHidden = true
                                cell.settingSwitch.isHidden = false
                                self.isLoading = false
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            cell.setting.stopAnimating()
                            cell.setting.isHidden = true
                            cell.settingSwitch.isHidden = false
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        cell.setting.stopAnimating()
                        cell.setting.isHidden = true
                        cell.settingSwitch.isHidden = false
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    cell.setting.stopAnimating()
                    cell.setting.isHidden = true
                    cell.settingSwitch.isHidden = false
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }else{
            SVProgressHUD.show()
            BoXinProvider.request(.CancelChatTop(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = CheckChatTopReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.isLoading = false
                                    BoXinUtil.getChatTop(Complite: { (b) in
                                        if b {
                                            DispatchQueue.main.async {
                                                self.isChatTop = !self.isChatTop
                                                cell.setting.stopAnimating()
                                                cell.setting.isHidden = true
                                                cell.settingSwitch.isHidden = false
                                                cell.settingSwitch.setOn(self.isChatTop, animated: false)
                                            }
                                            SVProgressHUD.dismiss()
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
                                    cell.setting.stopAnimating()
                                    cell.setting.isHidden = true
                                    cell.settingSwitch.isHidden = false
                                    self.isLoading = false
                                    self.view.makeToast(model.message)
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                cell.setting.stopAnimating()
                                cell.setting.isHidden = true
                                cell.settingSwitch.isHidden = false
                                self.isLoading = false
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            cell.setting.stopAnimating()
                            cell.setting.isHidden = true
                            cell.settingSwitch.isHidden = false
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        cell.setting.stopAnimating()
                        cell.setting.isHidden = true
                        cell.settingSwitch.isHidden = false
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    cell.setting.stopAnimating()
                    cell.setting.isHidden = true
                    cell.settingSwitch.isHidden = false
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @objc func onNotips() {
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let model = ApplyForSendModel()
        model.target_user_id = self.model?.user_id
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! UserDetailSettingTableViewCell
        cell.settingSwitch.isHidden = true
        cell.setting.isHidden = false
        cell.setting.startAnimating()
        BoXinProvider.request(.ChangeShield(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = CheckChatTopReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                DispatchQueue.main.async {
                                    if self.model?.is_shield == 1{
                                        self.model?.is_shield = 2
                                    }else{
                                        self.model?.is_shield = 1
                                    }
                                    cell.setting.stopAnimating()
                                    cell.setting.isHidden = true
                                    cell.settingSwitch.isHidden = false
                                    BoXinUtil.getFriends({ (b) in
                                        SVProgressHUD.showSuccess(withStatus:"")
                                        SVProgressHUD.dismiss()
                                    })
                                }
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
                                cell.setting.stopAnimating()
                                cell.setting.isHidden = true
                                cell.settingSwitch.isHidden = false
                                self.isLoading = false
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            cell.setting.stopAnimating()
                            cell.setting.isHidden = true
                            cell.settingSwitch.isHidden = false
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        cell.setting.stopAnimating()
                        cell.setting.isHidden = true
                        cell.settingSwitch.isHidden = false
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    cell.setting.stopAnimating()
                    cell.setting.isHidden = true
                    cell.settingSwitch.isHidden = false
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                cell.setting.stopAnimating()
                cell.setting.isHidden = true
                cell.settingSwitch.isHidden = false
                self.isLoading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc func onStar(){
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let model = ApplyForSendModel()
        model.target_user_id = self.model?.user_id
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! UserDetailSettingTableViewCell
        cell.settingSwitch.isHidden = true
        cell.setting.isHidden = false
        cell.setting.startAnimating()
        BoXinProvider.request(.ChangeStar(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = CheckChatTopReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                DispatchQueue.main.async {
                                    if self.model?.is_star == 1{
                                        self.model?.is_star = 2
                                    }else{
                                        self.model?.is_star = 1
                                    }
                                    cell.setting.stopAnimating()
                                    cell.setting.isHidden = true
                                    cell.settingSwitch.isHidden = false
                                    BoXinUtil.getFriends({ (b) in
                                        SVProgressHUD.showSuccess(withStatus:"")
                                        SVProgressHUD.dismiss()
                                    })
                                }
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
                                cell.setting.stopAnimating()
                                cell.setting.isHidden = true
                                cell.settingSwitch.isHidden = false
                                self.isLoading = false
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            cell.setting.stopAnimating()
                            cell.setting.isHidden = true
                            cell.settingSwitch.isHidden = false
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        cell.setting.stopAnimating()
                        cell.setting.isHidden = true
                        cell.settingSwitch.isHidden = false
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    cell.setting.stopAnimating()
                    cell.setting.isHidden = true
                    cell.settingSwitch.isHidden = false
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                cell.setting.stopAnimating()
                cell.setting.isHidden = true
                cell.settingSwitch.isHidden = false
                self.isLoading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
                       let vc = ReportGroupOrUserViewController()
            vc.id=model?.user_id
            vc.type=1
                       self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 4 {
            let picker = ZZQAvatarPicker()
            picker.onlyPic = true
            picker.startSelected { (image) in
                guard image != nil else {
                    return
                }
                DispatchQueue.main.async {
                    let v = UIView(frame: UIScreen.main.bounds)
                    v.backgroundColor = UIColor.clear
                    UIApplication.shared.keyWindow?.addSubview(v)
                    SVProgressHUD.show()
                    let app = UIApplication.shared.delegate as! AppDelegate
                    reqquestQueue.addOperation {
                        let put = OSSPutObjectRequest()
                        put.bucketName = "hgjt-oss"
                        put.uploadingData = image.jpegData(compressionQuality: 1)!
                        let filename = String(format: "%@.jpg", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
                        put.objectKey = String(format: "im19060501/%@", filename)
                        let task = app.ossClient?.putObject(put)
                        task?.continue({ (t) -> Any? in
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                v.removeFromSuperview()
                            }
                            if t.error == nil {
                                reqquestQueue.addOperation {
                                    self.setChatBackground(fileName: filename)
                                }
                            }else{
                                print(t.error.debugDescription)
                                DispatchQueue.main.async {
                                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                                }
                            }
                            return nil
                        })
                    }
                }
            }
        }
        if indexPath.section == 5 {
            //好友清空消息
            
            let alertController = UIAlertController(title: nil,message: NSLocalizedString("QuestionDeleteChat", comment: "Are you sure delete chat?"), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: {a in
                
            })
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {
                action in
                //删除好友聊天记录
                EMClient.shared()?.chatManager.deleteConversation(self.model!.user_id!, isDeleteMessages: true, completion: { (s, e) in
                    DispatchQueue.main.async {
                        
                        let MessageText = EMTextMessageBody(text:"")
                        let message = EMMessage.init(conversationID: self.model!.user_id, from: EMClient.shared()?.currentUsername, to: self.model!.user_id, body: MessageText, ext: ["em_recall":true])
                        message?.chatType = EMChatTypeChat
                        let conversation = EMClient.shared()?.chatManager.getConversation(self.model!.user_id, type: EMConversationTypeChat, createIfNotExist: true)
                        var err:EMError?
                        conversation?.insert(message, error: &err)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                })
                
                })
            
            alertController.addAction(cancelAction)
            
            alertController.addAction(okAction)
            alertController.modalPresentationStyle = .overFullScreen
            self.present(alertController, animated: true, completion: nil)
       
          
        }
        if indexPath.section == 6 {
            if indexPath.row == 0 {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let vc = ShareFriendViewController()
                vc.model = model
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            if isLoading
            {
                return
            }
            self.isLoading = true
            let alert = UIAlertController(title: nil, message: NSLocalizedString("QuestionDelete", comment: "Are you sure delete?"), preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
                let m =  ApplyForSendModel()
                m.target_user_id =  self.model?.user_id
                SVProgressHUD.show()
                BoXinProvider.request(.DeleteFriend(model: m)) { (result) in
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            do{
                                if let model = FriendListReciveModel.deserialize(from: try res.mapString()) {
                                    guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                        return
                                    }
                                    if model.code == 200 {
                                        self.isLoading = false
                                        BoXinUtil.getFriends({ (b) in
                                            if b {
                                                EMClient.shared()?.chatManager.deleteConversation(m.target_user_id, isDeleteMessages: true, completion: { (s, e) in
                                                    SVProgressHUD.dismiss()
                                                    self.navigationController?.popToRootViewController(animated: true)
                                                })
                                            }else
                                            {
                                                self.navigationController?.popToRootViewController(animated: true)
                                            }
                                        })
                                    }else{
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
                                        if (model.message?.contains("请重新登录"))! {
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
                                            self.present(sb.instantiateViewController(withIdentifier: "LoginNavigation"), animated: false, completion: nil)
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
            alert.addAction(ok)
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: {(a) in
                self.isLoading = false
            })
            alert.addAction(cancel)
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    func setChatBackground(fileName:String) {
        let model = SetChatBackgroundSendModel()
        model.target_id=self.model?.user_id
        model.img_path = fileName
        BoXinProvider.request(.SetChatBackground(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                guard let data = model.data else {
                                    return
                                }
                                DispatchQueue.main.async {
                                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("SetChatBKSuccessfully", comment: "Set chat background successfully"))
                                }
                            }else{
                                if (model.message?.contains("请重新登录"))! {
                                    BoXinUtil.Logout()
                                    DispatchQueue.main.async {
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
                                        self.present(sb.instantiateViewController(withIdentifier: "LoginNavigation"), animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    UIApplication.shared.keyWindow?.makeToast(model.message)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
            }
        }
    }
    
    func getFriends() {
        if isLoading {
            return
        }
        self.isLoading = true
        BoXinProvider.request(.FriendList(model: UserInfoSendModel())) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = FriendListReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                self.sorted(model: model.data)
                            }else{
                                if (model.message?.contains("请重新登录"))! {
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
    
    
    func sorted(model :[FriendData?]?) {
        var dataArray = Array<FriendViewModel?>()
        var data = model
        var star:FriendViewModel?
        var isEnd = false
        while !isEnd {
            if let m = data {
                for ms in 0 ..< data!.count {
                    if data![ms]?.is_star == 1 {
                        if star == nil{
                            star = FriendViewModel()
                            star?.tittle = "*"
                            star?.data = Array<FriendData>()
                            star?.data?.append(m[ms])
                        }else{
                            star?.data?.append(m[ms])
                        }
                        data?.remove(at: ms)
                        break
                    }
                    if ms == data!.count - 1 {
                        isEnd = true
                        if star != nil {
                            dataArray.append(star)
                            star =  nil
                        }
                    }
                }
            }else{
                isEnd = true
                if star != nil {
                    dataArray.append(star)
                    star =  nil
                }
            }
        }
        
        star = nil
        let arr = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R",
                   "S","T","U","V","W","X","Y","Z"]
        for s in arr {
            var isEnd = false
            while !isEnd {
                if data?.count != 0 {
                    for ms in 0 ..< data!.count {
                        let first = String((data![ms]?.target_user_nickname!.first)!)
                        if first.isIncludeChinese() {
                            if String(first.getPinyinHead().first!).uppercased() == s {
                                if star == nil{
                                    star = FriendViewModel()
                                    star?.tittle = s
                                    star?.data = Array<FriendData>()
                                    star?.data?.append(data![ms])
                                }else{
                                    star?.data?.append(data![ms])
                                }
                                data?.remove(at: ms)
                                break
                            }
                        }else{
                            if first.uppercased() == s {
                                if star == nil{
                                    star = FriendViewModel()
                                    star?.tittle = s
                                    star?.data = Array<FriendData>()
                                    star?.data?.append(data![ms])
                                }else{
                                    star?.data?.append(data![ms])
                                }
                                data?.remove(at: ms)
                                break
                            }
                        }
                        if ms == data!.count - 1 {
                            isEnd = true
                            if star != nil {
                                dataArray.append(star)
                                star =  nil
                            }
                        }
                    }
                    if star != nil {
                        dataArray.append(star)
                        star =  nil
                    }
                }else{
                    isEnd = true
                    if star != nil {
                        dataArray.append(star)
                        star =  nil
                    }
                }
            }
        }
        
        if data?.count != 0 {
            star = FriendViewModel()
            star?.tittle = "#"
            star?.data = data
            dataArray.append(star)
        }
        let d = dataArray as? [FriendViewModel]
        let s = d?.toJSONString()
        UserDefaults.standard.setValue(s, forKey: "Contact")
        tableView.reloadData()
    }

}
