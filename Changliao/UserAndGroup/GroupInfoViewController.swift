//
//  GroupInfoViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage
import SVProgressHUD

class GroupInfoViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,MGAvatarImageViewDelegate {

    var model:GroupViewModel?
    var data:[GroupMemberData?]?
    var me:GroupMemberData?
    var table:UITableView?
    var exitBtn:UIButton?
    var menagerCount:Int = 0
    let da = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
    var groupId:String?
    var GroupNumber:String?
    var sectionNum:Int = 0
    var isLoading:Bool = false
    var isFirst:Bool = true
    var updateQueue = DispatchQueue(label: "group.info.update")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        title = NSLocalizedString("GroupInfo", comment: "Group info")
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        exitBtn = UIButton(type: .custom)
        if model?.administrator_id != da!.db!.user_id! {
            exitBtn?.setTitle(NSLocalizedString("ExitGroup", comment: "Exit group"), for: .normal)
            exitBtn?.setTitle(NSLocalizedString("ExitGroup", comment: "Exit group"), for: .disabled)
            exitBtn?.setTitle(NSLocalizedString("ExitGroup", comment: "Exit group"), for: .highlighted)
            exitBtn?.setTitle(NSLocalizedString("ExitGroup", comment: "Exit group"), for: .selected)
        }else{
            exitBtn?.setTitle(NSLocalizedString("DestoryGroup", comment: "Destory group"), for: .normal)
            exitBtn?.setTitle(NSLocalizedString("DestoryGroup", comment: "Destory group"), for: .selected)
            exitBtn?.setTitle(NSLocalizedString("DestoryGroup", comment: "Destory group"), for: .highlighted)
            exitBtn?.setTitle(NSLocalizedString("DestoryGroup", comment: "Destory group"), for: .disabled)
        }
        exitBtn?.backgroundColor = UIColor.white
        exitBtn?.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "DB633D"), for: .normal)
        exitBtn?.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "DB633D"), for: .normal)
        exitBtn?.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "DB633D"), for: .normal)
        exitBtn?.setTitleColor(UIColor.hexadecimalColor(hexadecimal: "DB633D"), for: .normal)
        exitBtn?.addTarget(self, action: #selector(onExit), for: .touchUpInside)
        view.addSubview(exitBtn!)
        let line = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        line.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "d9d9d9")
        view.addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(exitBtn?.mas_top)
            make?.height.mas_equalTo()(0.5)
        }
        exitBtn?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
            make?.height.mas_equalTo()(55)
        })
        table = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        table?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        table?.separatorStyle = .none
        table?.dataSource = self
        table?.delegate = self
        
        groupId = model?.groupId
        view.addSubview(table!)
        table?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            if model?.is_admin == 1 || model?.is_menager == 1 {
                make?.bottom.equalTo()(exitBtn?.mas_top)
            }else{
                make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdate), name: Notification.Name("UpdateGroup"), object: nil)
        table?.register(UINib(nibName: "GroupNameTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupName")
        table?.register(UINib(nibName: "ChangeGroupHeadImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ChangeGroupHeadImage")
        table?.register(UINib(nibName: "GroupInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupInfo")
        table?.register(UINib(nibName: "AddGroupMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "AddGroupMember")
        table?.register(UINib(nibName: "GroupMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupMember")
        table?.register(UINib(nibName: "UserDetailSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailSetting")
        
        table?.register(UINib(nibName: "NewGroupUnmemberTableViewCell", bundle: nil), forCellReuseIdentifier: "NewGroupMember")
        if groupId != nil
        {
            data = QueryFriend.shared.getGroupMembers(groupId: groupId!)
            if data == nil
            {
                onUpdate()
                return
            }
            if data?.count == 0 {
                onUpdate()
                return
            }
            if data![0]?.is_administrator == 2 {
                var i = 0
                for da in data! {
                    if da?.is_administrator == 1 {
                        break
                    }
                    i += 1
                }
                if data!.count > i {
                    let d = data![i]
                    data?.remove(at: i)
                    data?.insert(d, at: 0)
                }
            }
            var i = 0
            for da in data! {
                if da?.is_manager == 1 {
                    data?.remove(at: i)
                    data?.insert(da, at: 1)
                    menagerCount += 1
                }
                i += 1
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        if isFirst {
            isFirst = false
            BoXinUtil.getGroupMember(groupID: groupId!) { (b) in
                if b {
                    self.data = QueryFriend.shared.getGroupMembers(groupId: self.groupId!)
                    self.me = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: self.groupId!)
                    DispatchQueue.main.async {
                        self.table?.reloadData()
                    }
                }
            }
            return
        }
        if( model == nil && groupId != nil){
            BoXinUtil.getGroupInfo(groupId: groupId!) { (a) in
                self.model = QueryFriend.shared.queryGroup(id: self.groupId!)
                self.data = QueryFriend.shared.getGroupMembers(groupId: self.groupId!)
                self.me = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: self.groupId!)
                DispatchQueue.main.async {
                    self.table?.reloadData()
                }
            }
            return
        }
        if model?.groupId == nil {
            if groupId != nil
            {
                BoXinUtil.getGroupInfo(groupId: groupId!) { (a) in
                    self.model = QueryFriend.shared.queryGroup(id: self.groupId!)
                    self.data = QueryFriend.shared.getGroupMembers(groupId: self.groupId!)
                    self.me = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: self.groupId!)
                    DispatchQueue.main.async {
                        self.table?.reloadData()
                    }
                }
            }
            
            return
        }
        model = QueryFriend.shared.queryGroup(id: model!.groupId!)
        data = QueryFriend.shared.getGroupMembers(groupId: model!.groupId!)
        self.me = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: self.groupId!)
        if data  == nil {
            BoXinUtil.getGroupInfo(groupId: groupId!) { (a) in
                self.model = QueryFriend.shared.queryGroup(id: self.groupId!)
                self.data = QueryFriend.shared.getGroupMembers(groupId: self.groupId!)
                self.me = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: self.groupId!)
                DispatchQueue.main.async {
                    self.table?.reloadData()
                }
            }
            return
        }
        if data?.count == 0 {
            QueryFriend.shared.deleteGroup(id: model!.groupId!)
            BoXinUtil.getGroupInfo(groupId: groupId!) { (a) in
                self.model = QueryFriend.shared.queryGroup(id: self.groupId!)
                self.data = QueryFriend.shared.getGroupMembers(groupId: self.groupId!)
                self.me = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: self.groupId!)
                DispatchQueue.main.async {
                    self.table?.reloadData()
                }
            }
            return
        }
        if data![0]?.is_administrator == 2 {
            var i = 0
            for da in data! {
                if da?.is_administrator == 1 {
                    break
                }
                i += 1
            }
            let d = data![i]
            data?.remove(at: i)
            data?.insert(d, at: 0)
        }
        var i = 0
        for da in data! {
            if da?.is_manager == 1 {
                data?.remove(at: i)
                data?.insert(da, at: 1)
            }
            i += 1
        }
        table?.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onUpdate() {
        weak var weakSelf = self
        updateQueue.async {
            guard let gid = weakSelf?.groupId else {
                return
            }
            weakSelf?.model = QueryFriend.shared.queryGroup(id: gid)
            weakSelf?.data = QueryFriend.shared.getGroupMembers(groupId: gid)
            if weakSelf?.data == nil {
                BoXinUtil.getGroupMember(groupID: gid) { (b) in
                    
                    
                    if b {
                        self.data = QueryFriend.shared.getGroupMembers(groupId: gid)
                        if self.data != nil && self.data?.count ?? 0 > 0 {
                            if self.data![0]?.is_administrator == 2 {
                                var i = 0
                                var ishave = false
                                for da in stride(from: 0, to: self.data!.count, by: 1) {
                                    if self.data![da]?.is_administrator == 1 {
                                        ishave =  true
                                        break
                                    }
                                    i += 1
                                }
                                if ishave {
                                    let d = self.data![i]
                                    self.data?.remove(at: i)
                                    self.data?.insert(d, at: 0)
                                }
                            }
                            var i = 0
                            for da in self.data! {
                                if da?.is_manager == 1 {
                                    self.data?.remove(at: i)
                                    self.data?.insert(da, at: 1)
                                }
                                i += 1
                            }
                            DispatchQueue.main.async {
                                self.table?.reloadData()
                            }
                        }
                    }else
                    {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                }
                return
            }
            if weakSelf?.data?[0]?.is_administrator == 2 {
                var i = 0
                var ishave = false
                for da in stride(from: 0, to: weakSelf?.data?.count ?? 0, by: 1) {
                    if weakSelf?.data?[da]?.is_administrator == 1 {
                        ishave =  true
                        break
                    }
                    i += 1
                }
                if ishave {
                    let d = weakSelf?.data?[i]
                    weakSelf?.data?.remove(at: i)
                    weakSelf?.data?.insert(d, at: 0)
                }
            }
            var i = 0
            for da in weakSelf!.data! {
                if da?.is_manager == 1 {
                    weakSelf?.data?.remove(at: i)
                    weakSelf?.data?.insert(da, at: 1)
                }
                i += 1
            }
            DispatchQueue.main.async {
                weakSelf?.table?.reloadData()
            }
        }
    }
    
    @objc private func onExit() {
        let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
        if model?.administrator_id != data!.db!.user_id {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("QuestionExitGroup", comment: "Are you sure you want to quit the group."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (a) in
                SVProgressHUD.show()
                let model = DeleteGroupSendModel()
                model.group_id = self.model?.groupId
                BoXinProvider.request(.ExitGroup(model: model)) { (result) in
                    switch(result){
                    case .success(let res):
                        if res.statusCode == 200 {
                            do{
                                if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                    guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                        return
                                    }
                                    if model.code == 200 {
                                        BoXinUtil.getMyGroup({(b) in
                                            
                                        })
                                        EMClient.shared()?.chatManager.deleteConversation(self.model!.groupId!, isDeleteMessages: true, completion: { (a, e) in
                                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                        })
                                        DispatchQueue.main.async {
                                            SVProgressHUD.dismiss()
                                            self.navigationController?.popToRootViewController(animated: true)
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
                                            let nav = UINavigationController(rootViewController: WelcomeViewController())
                                            nav.modalPresentationStyle = .overFullScreen
                                            UIViewController.currentViewController()?.present(nav, animated: false, completion: nil)
                                        }
                                        self.view.makeToast(model.message)
                                        SVProgressHUD.dismiss()
                                    }
                                }else{
                                    self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    SVProgressHUD.dismiss()
                                }
                            }catch{
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            SVProgressHUD.dismiss()
                        }
                    case .failure(let err):
                        self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                        print(err.errorDescription!)
                        SVProgressHUD.dismiss()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: nil, message: NSLocalizedString("QuestionDestoryGroup", comment: "Are you sure you want to destory the group."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (A) in
                SVProgressHUD.show()
                let model = DeleteGroupSendModel()
                model.group_id = self.model?.groupId
                BoXinProvider.request(.DeleteGroup(model: model)) { (result) in
                    switch(result){
                    case .success(let res):
                        if res.statusCode == 200 {
                            do{
                                if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                    guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                        return
                                    }
                                    if model.code == 200 {
                                        BoXinUtil.getMyGroup({(b) in
                                            
                                        })
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                        SVProgressHUD.dismiss()
                                        self.navigationController?.popToRootViewController(animated: true)
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
                                            let nav = UINavigationController(rootViewController: WelcomeViewController())
                                            nav.modalPresentationStyle = .overFullScreen
                                            self.present(nav, animated: false, completion: nil)
                                        }
                                        self.view.makeToast(model.message)
                                        SVProgressHUD.dismiss()
                                    }
                                }else{
                                    self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    SVProgressHUD.dismiss()
                                }
                            }catch{
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            SVProgressHUD.dismiss()
                        }
                    case .failure(let err):
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
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if model?.is_admin == 2 && model?.is_menager == 2 {
            sectionNum = 3
            return sectionNum
        }
        sectionNum = 4
        return sectionNum
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            if model?.is_admin == 2 && model?.is_menager == 2 {
                return 4
            }
            return 5
        }
        if section == 1 {
            if (model?.is_admin == 2 && model?.is_menager == 2)
            {
                return 4
            }
            
            return 1
        }
        if section == 2 {
            if model?.is_menager == 1 || model?.is_admin == 1 {
                return 4
            }
            return data?.count ?? 0
        }
        return (data?.count ?? 0) + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 70
            }
        }
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupName", for: indexPath) as! GroupNameTableViewCell
                if model != nil {
                    if model?.portrait != nil {
                        cell.headImageView.sd_setImage(with: URL(string: model!.portrait!), placeholderImage: UIImage(named: "群聊11111"))
                    }
                    cell.click = {(img) in
                        let data = YBIBImageData()
                        data.projectiveView = img
                        data.imageURL = URL(string: String(self.model?.portrait?.split(separator: "?")[0] ?? ""))
                        let browser = YBImageBrowser()
                        browser.dataSourceArray = [data]
                        browser.currentPage = 0
                        browser.show(to: self.navigationController!.view)
                    }
                    cell.Workimage1.isHidden = true
                    cell.nameLabel.text = model?.groupName
                    cell.headImageView.delegate = self
                    if model!.group_type == 1
                    {
                        cell.WrokImage.isHidden = false
                    }else
                    {
                        cell.WrokImage.isHidden = true
                    }
                    if model!.is_admin == 2{
                        cell.WrokImage.isHidden = true
                        if model!.group_type == 1
                        {
                            cell.Workimage1.isHidden = false
                        }else
                        {
                            cell.Workimage1.isHidden = true
                        }
                        cell.jiantou.isHidden = true
                    }
                }
                return cell
            }
            if indexPath.row == 1 && (model?.is_admin == 1 || model?.is_menager == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeGroupHeadImage", for: indexPath) as! ChangeGroupHeadImageTableViewCell
                cell.tittleLabel.text = NSLocalizedString("ModifyGroupAvatar", comment: "Modiffy the group avatar")
                cell.tittleLabel.font = UIFont.systemFont(ofSize: 14)
                cell.tittleLabel.textColor = UIColor.black
                return cell
            }
            if indexPath.row == 1 && model?.is_admin == 2 && model?.is_menager == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
                cell.tittleLabel.text = NSLocalizedString("MyGroupNickName", comment: "My group nickname")
                var name = ""
                if me != nil {
                    if me?.group_user_nickname == "" {
                        name = me!.user_name!
                    }else{
                        name = me!.group_user_nickname!
                    }
                }
                cell.contextLabel.text = name
                return cell
            }
            if indexPath.row == 2 && (model?.is_admin == 1 || model?.is_menager == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
                cell.tittleLabel.text = NSLocalizedString("MyGroupNickName", comment: "My group nickname")
                var name = ""
                if me != nil {
                    if me?.group_user_nickname == "" {
                        name = me!.user_name!
                    }else{
                        name = me!.group_user_nickname!
                    }
                }
                cell.contextLabel.text = name
                return cell
            }
            if indexPath.row == 2 && model?.is_admin == 2 && model?.is_menager == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailSetting", for: indexPath) as! UserDetailSettingTableViewCell
                cell.tittleLable.text = NSLocalizedString("GroupShield", comment: "Group shield")
                if model?.is_pingbi == 1 {
                    cell.settingSwitch.isOn = true
                }else{
                    cell.settingSwitch.isOn = false
                }
                cell.settingSwitch.addTarget(self, action: #selector(onGroupSheild(sender:)), for: .touchUpInside)
                return cell
            }
            if indexPath.row == 3 && (model?.is_admin == 1 || model?.is_menager == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailSetting", for: indexPath) as! UserDetailSettingTableViewCell
                cell.tittleLable.text = NSLocalizedString("GroupShield", comment: "Group shield")
                if model?.is_pingbi == 1 {
                    cell.settingSwitch.isOn = true
                }else{
                    cell.settingSwitch.isOn = false
                }
                cell.settingSwitch.addTarget(self, action: #selector(onGroupSheild(sender:)), for: .touchUpInside)
                return cell
            }
            if indexPath.row == 3 && model?.is_admin == 2 && model?.is_menager == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailSetting", for: indexPath) as! UserDetailSettingTableViewCell
                cell.tittleLable.text = NSLocalizedString("TopConversation", comment: "Top conversation")
                if BoXinUtil.checkChatTop(id: model?.groupId) {
                    cell.settingSwitch.isOn = true
                }else{
                    cell.settingSwitch.isOn = false
                }
                cell.settingSwitch.addTarget(self, action: #selector(onGroupTop(sender:)), for: .touchUpInside)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailSetting", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.text = NSLocalizedString("TopConversation", comment: "Top conversation")
            if BoXinUtil.checkChatTop(id: model?.groupId) {
                cell.settingSwitch.isOn = true
            }else{
                cell.settingSwitch.isOn = false
            }
            cell.settingSwitch.addTarget(self, action: #selector(onGroupTop(sender:)), for: .touchUpInside)
            return cell
        }
        if indexPath.section == 1 {
            if model?.is_menager == 2 && model?.is_admin == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
                if indexPath.row == 0
                {
                cell.tittleLabel.text = NSLocalizedString("GroupAnnouncement", comment: "Group announcement")
                cell.contextLabel.text = ""
                }else if indexPath.row == 1 {
                    cell.tittleLabel.text = NSLocalizedString("ChangeChatBK", comment: "Change chat background")
                    cell.contextLabel.isHidden = true
                    cell.Jiantou.isHidden = true
                } else if indexPath.row == 2
                {
                    cell.tittleLabel.text = NSLocalizedString("ClearChat", comment: "Clear chat")
                    cell.contextLabel.isHidden = true
                    cell.Jiantou.isHidden = true
                    
                }else if indexPath.row == 3 {
                    cell.tittleLabel.text = NSLocalizedString("Report", comment: "Report")
                    cell.contextLabel.isHidden = true
                    cell.Jiantou.isHidden = true
                }
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
            cell.tittleLabel.text = "群管理"
            cell.contextLabel.text = ""
            return cell
        }
        if indexPath.section == 2 {
            
            if( model?.group_type == 1 && model?.is_admin != 1 && model?.is_menager != 1)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMember", for: indexPath) as! GroupMemberTableViewCell
                if data == nil {
                    cell.headImageView.image = UIImage(named: "moren")
                    return cell
                }
                cell.groupOwnerLabel.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                if data![indexPath.row]?.is_administrator == 1 {
                    cell.groupOwnerLabel.text = "群主"
                    cell.groupOwnerLabel.isHidden = false
                    
                }
                if data![indexPath.row]?.is_manager == 1 {
                    cell.groupOwnerLabel.text = "管理员"
                    cell.groupOwnerLabel.isHidden = false
                }
                if data![indexPath.row]?.is_administrator == 2 && data![indexPath.row]?.is_manager == 2 {
                    cell.groupOwnerLabel.isHidden = true
                    
                }
                if data != nil
                {
                    GroupNumber = String(format: "%d%@", model?.groupUserSum ?? 0,NSLocalizedString("NumOfGroupMember", comment: "group members"))
                    cell.IDlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", data![indexPath.row]!.id_card!)
                    cell.headImageView.sd_setImage(with: URL(string: data![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                }
                
                var text:String? = ""
                if QueryFriend.shared.checkFriend(userID: (data?[indexPath.row ]!.user_id)!) {
                    
                    if data?[indexPath.row ]?.friend_name != ""
                    {
                        text = data?[indexPath.row ]?.friend_name
                    }else
                    {
                        text = data?[indexPath.row ]?.user_name
                    }
                    
                    
                    
                }else{
                    if data?[indexPath.row ]?.group_user_nickname != "" {
                        text = data?[indexPath.row ]?.group_user_nickname;
                    }else{
                        text = data?[indexPath.row ]?.user_name
                    }
                }
                cell.nickNameLabel.text = text
                
                
                return cell
                
                
            }else if model?.group_type ?? 2 > 1
            {
                if model?.is_admin == 2 && model?.is_menager == 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NewGroupMember", for: indexPath) as! NewGroupUnmemberTableViewCell
                    
                    if data != nil
                    {
                        GroupNumber = String(format: "%d%@", model?.groupUserSum ?? 0,NSLocalizedString("NumOfGroupMember", comment: "group members"))
                        cell.headImageView.sd_setImage(with: URL(string: data![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                    }
                    
                    
                    
                    var text:String? = ""
                    if QueryFriend.shared.checkFriend(userID: data?[indexPath.row ]?.user_id ?? "") {
                        
                        if data?[indexPath.row ]?.friend_name != ""
                        {
                            text = data?[indexPath.row ]?.friend_name
                        }else
                        {
                            text = data?[indexPath.row ]?.user_name
                        }
                        
                        
                        
                    }else{
                        if data?[indexPath.row ]?.group_user_nickname != "" {
                            text = data?[indexPath.row ]?.group_user_nickname;
                        }else{
                            text = data?[indexPath.row ]?.user_name
                        }
                    }
                    cell.nickNameLable.text = text
                    cell.groupOwnerLable.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#0148ED")
                    if data![indexPath.row]?.is_administrator == 1{
                        cell.groupOwnerLable.text = "群主"
                        cell.groupOwnerLable.isHidden = false
                    }
                    
                    
                    if data![indexPath.row]?.is_manager == 1 {
                        cell.groupOwnerLable.text = "管理员"
                        cell.groupOwnerLable.isHidden = false
                        
                    }
                    if data![indexPath.row]?.is_administrator == 2 && data![indexPath.row]?.is_manager == 2 {
                        cell.groupOwnerLable.isHidden = true
                    }
                    
                    return cell
                    
                }
                
                

                
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
            if indexPath.row == 0{
                cell.tittleLabel.text = NSLocalizedString("GroupAnnouncement", comment: "Group announcement")
                cell.contextLabel.text = NSLocalizedString("GroupAnnouncement", comment: "Group announcement")
            }else if indexPath.row == 1 {
                cell.tittleLabel.text = NSLocalizedString("ChangeChatBK", comment: "Change chat background")
                cell.contextLabel.isHidden = true
                cell.Jiantou.isHidden = true
            }else if indexPath.row == 2
            {
                cell.tittleLabel.text = NSLocalizedString("ClearChat", comment: "Clear chat")
                cell.contextLabel.isHidden = true
                cell.Jiantou.isHidden = true
                
            }else if indexPath.row == 3 {
                cell.tittleLabel.text = NSLocalizedString("Report", comment: "Report")
                cell.contextLabel.isHidden = true
                cell.Jiantou.isHidden = true
            }
            return cell
            
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroupMember", for: indexPath) as! AddGroupMemberTableViewCell
            cell.tittleImageView.image = UIImage(named: "new_group_member")
            cell.tittleLabelView.text = NSLocalizedString("InvateMember", comment: "Invate member")
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroupMember", for: indexPath) as! AddGroupMemberTableViewCell
            cell.tittleImageView.image = UIImage(named: "all_group_member")
            cell.tittleLabelView.text = NSLocalizedString("AllMember", comment: "All member")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMember", for: indexPath) as! GroupMemberTableViewCell
        if data == nil {
            cell.headImageView.image = UIImage(named: "moren")
            return cell
        }
        cell.groupOwnerLabel.backgroundColor=UIColor.hexadecimalColor(hexadecimal: "#0148ED")
        if data![indexPath.row - 2]?.is_administrator == 1 {
            cell.groupOwnerLabel.text = "群主"
            cell.groupOwnerLabel.isHidden = false
            
        }
        if data![indexPath.row - 2]?.is_manager == 1 {
            cell.groupOwnerLabel.text = "管理员"
            cell.groupOwnerLabel.isHidden = false
        }
        if data![indexPath.row - 2]?.is_administrator == 2 && data![indexPath.row - 2]?.is_manager == 2 {
            cell.groupOwnerLabel.isHidden = true
            
        }
        if data != nil
        {
            GroupNumber = String(format: "%d%@", model?.groupUserSum ?? 0,NSLocalizedString("NumOfGroupMember", comment: "group members"))
            cell.IDlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", data![indexPath.row - 2]!.id_card!)
            cell.headImageView.sd_setImage(with: URL(string: data![indexPath.row - 2]!.portrait!), placeholderImage: UIImage(named: "moren"))
        }
        
        var text:String? = ""
        if QueryFriend.shared.checkFriend(userID: (data?[indexPath.row - 2]!.user_id)!) {
            
            if data?[indexPath.row - 2 ]?.friend_name != ""
            {
                text = data?[indexPath.row - 2 ]?.friend_name
            }else
            {
                text = data?[indexPath.row - 2]?.user_name
            }
            
            
            
        }else{
            if data?[indexPath.row - 2]?.group_user_nickname != "" {
                text = data?[indexPath.row  - 2]?.group_user_nickname;
            }else{
                text = data?[indexPath.row - 2]?.user_name
            }
        }
        cell.nickNameLabel.text = text

        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section==0  {
            return 0.1
        }
        if section==1 {
            return 0.1
        }
        return 27
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 8, width:4, height: 4))
        headerView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        
        let titleLabel = UILabel()
        
        titleLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "8a8888")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.frame = headerView.frame
        headerView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(headerView.mas_left)?.offset()(16)
            make?.centerY.equalTo()(headerView.mas_centerY)
        }
        
        if sectionNum == 3
        {
            if section == 2 {
            titleLabel.text = GroupNumber
//                return headerView
            }
        }else if sectionNum == 4
        {
            if section == 3 {
                titleLabel.text = GroupNumber
//                return headerView
            }
            
        }
       return headerView
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 {
            if model?.is_admin == 1 {
                if indexPath.row > 2 {
                    return true
                }
            }
            if  model?.is_menager == 1 {
                if indexPath.row > menagerCount + 2 {
                    return true
                }
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var text = ""
        if data![indexPath.row - 2]!.is_shield == 1 {
            text = "解除禁言"
        }else{
            text = "禁言"
        }
        let muteAction = UITableViewRowAction(style: .normal, title: text) { (action, indexpath) in
            self.onJinyan(indexPath: indexpath)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "移除") { (action, indexpath) in
            self.onMoveOut(indexPath: indexpath)
        }
        return [deleteAction,muteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if model?.administrator_id == da?.db?.user_id {
                    let vc = ChangeGroupNameViewController()
                    vc.groupId = model?.groupId
                    vc.model = model
                    self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            }
            if indexPath.row == 1 {
                if model?.is_menager == 1 || model?.is_admin == 1 {
                    updateGroupHeadImage()
                    return
                }
                let vc = ChangeGroupNameViewController()
                vc.groupId = model?.groupId
                vc.model = model
                vc.me = me
                vc.type = 1
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            if indexPath.row == 2 {
                if model?.is_menager == 1 || model?.is_admin == 1 {
                    let vc = ChangeGroupNameViewController()
                    vc.groupId = model?.groupId
                    vc.model = model
                    vc.me = me
                    vc.type = 1
                    self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            }
            return
        }
        if indexPath.section == 1 {
            if model?.is_admin == 1 || model?.is_menager == 1 {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let vc = GroupMenagerTableViewController()
                vc.model = model
                vc.data = data
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            if indexPath.row == 0{
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = GroupNoticeViewController()
            vc.model = model
            self.navigationController?.pushViewController(vc, animated: true)
            }else if indexPath.row == 1 {
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
            }else if indexPath.row == 2
            {
                //清空聊天记录
                
                let alertController = UIAlertController(title: nil,message: "确定删除群组聊天记录吗", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {
                    action in

                //删除群组聊天记录
                EMClient.shared()?.chatManager.deleteConversation(self.model!.groupId!, isDeleteMessages: true, completion: { (s, e) in
                    DispatchQueue.main.async {
                        
                        let MessageText = EMTextMessageBody(text:"")
                        let message = EMMessage.init(conversationID: self.model!.groupId, from: EMClient.shared()?.currentUsername, to: self.model!.groupId, body: MessageText, ext: ["em_recall":true])
                        message?.chatType = EMChatTypeGroupChat
                        let conversation = EMClient.shared()?.chatManager.getConversation(self.model!.groupId, type: EMConversationTypeGroupChat, createIfNotExist: true)
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
                
            }else if indexPath.row == 3 {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
                           let vc = ReportGroupOrUserViewController()
                vc.id=model?.groupId
                vc.type=2
                           self.navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        if indexPath.section == 2  {
            if model?.is_admin == 1 || model?.is_menager == 1 {
                if indexPath.row == 0{
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let vc = GroupNoticeViewController()
                vc.model = model
                self.navigationController?.pushViewController(vc, animated: true)
                }else if indexPath.row == 1 {
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
                }else if indexPath.row == 2
                {
                    //清空聊天记录
                    
                    let alertController = UIAlertController(title: nil,message: "确定删除群组聊天记录吗", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {
                        action in
                 
                    //删除群组聊天记录
                    EMClient.shared()?.chatManager.deleteConversation(self.model!.groupId!, isDeleteMessages: true, completion: { (s, e) in
                        DispatchQueue.main.async {
                            
                            let MessageText = EMTextMessageBody(text:"")
                            let message = EMMessage.init(conversationID: self.model!.groupId, from: EMClient.shared()?.currentUsername, to: self.model!.groupId, body: MessageText, ext: ["em_recall":true])
                            message?.chatType = EMChatTypeGroupChat
                            let conversation = EMClient.shared()?.chatManager.getConversation(self.model!.groupId, type: EMConversationTypeGroupChat, createIfNotExist: true)
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
                }else if indexPath.row == 3 {
                    self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "      ", style: .plain, target: nil, action: nil)
                               let vc = ReportGroupOrUserViewController()
                    vc.id=model?.groupId
                    vc.type=2
                               self.navigationController?.pushViewController(vc, animated: true)
                }
                return
            }
            jumpToPersonPage(m: data![indexPath.row]!)
            return
        }
        if indexPath.row == 0 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddGroup") as! AddGroupChatViewController
            vc.type = 1
            vc.model = model
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        if indexPath.row == 1 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = SearchGroupMemberViewController()
            vc.model = model
            vc.data = data
            vc.me = me
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        jumpToPersonPage(m: data![indexPath.row - 2]!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.table {
            if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 27 {
                scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
            }else if scrollView.contentOffset.y >= 27 {
                scrollView.contentInset = UIEdgeInsets(top: -27, left: 0, bottom: 0, right: 0)
            }else{
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    func setChatBackground(fileName:String) {
        let model = SetChatBackgroundSendModel()
        model.target_id=self.model?.groupId
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
    
    func updateGroupHeadImage() {
        let cell = table?.cellForRow(at: IndexPath(row: 0, section: 0)) as! GroupNameTableViewCell
        cell.headImageView.show()
    }
    
    func imageView(_ imageView: MGAvatarImageView!, didSelect image: UIImage!) {
        let data = image!.pngData()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        let savePath = path + String(format: "/signal/%@.png", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        do{
            if !FileManager.default.fileExists(atPath: path + "/signal") {
                try FileManager.default.createDirectory(atPath: path + "/signal", withIntermediateDirectories: true, attributes: nil)
            }
            FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
            self.uploadHeadImage(filePath: savePath)
        }catch{
            return
        }
    }
    
    func uploadHeadImage(filePath:String?) {
        if filePath == nil {
            UIApplication.shared.keyWindow?.makeToast("获取文件失败")
        }
        SVProgressHUD.show()
        let put = OSSPutObjectRequest()
        put.bucketName = "hgjt-oss"
        put.uploadingFileURL = URL(fileURLWithPath: filePath!)
        put.objectKey = String(format: "im19060501/%@", (filePath! as NSString).lastPathComponent)
        let app = UIApplication.shared.delegate as! AppDelegate
        let task = app.ossClient?.putObject(put)
        task?.continue({ (t) -> Any? in
            if t.error == nil {
                self.updateHeadImage(fileName: (filePath! as NSString).lastPathComponent)
            }else{
                print(t.error.debugDescription)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                }
            }
            return nil
        })
    }
    
    func updateHeadImage(fileName:String?) {
        if isLoading {
            return
        }
        self.isLoading = true
        let model = ChangeGroupInfoSendModel()
        model.group_id = self.model?.groupId
        model.group_portrait = fileName
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
                                BoXinUtil.getGroupInfo(groupId: self.model!.groupId!, Complite: { (b) in
                                    
                                    
                                    if b {
                                        let body = EMCmdMessageBody(action: "")
                                        var dic = ["type":"qun","id":self.model?.groupId]
                                        if self.model?.is_all_banned == 1 {
                                            dic.updateValue("2", forKey: "grouptype")
                                        }else{
                                            dic.updateValue("1", forKey: "grouptype")
                                        }
                                        let msg = EMMessage(conversationID: self.model!.groupId!, from: self.da!.db!.user_id!, to: self.model!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                        msg?.chatType = EMChatTypeGroupChat
                                        EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                            
                                        }, completion: { (msg, err) in
                                            if err != nil {
                                                print(err?.errorDescription)
                                            }
                                        })
                                        self.model = QueryFriend.shared.queryGroup(id: self.model!.groupId!)
                                        self.view.makeToast("修改成功")
                                        self.table?.reloadData()
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
    
    func jumpToPersonPage(m:GroupMemberData) {
        if m.user_id == da?.db?.user_id {
            return
        }
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
//        let vc = UserDetailViewController()
        let vc = UserDetailViewController()
        let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
        if contact == nil {
            BoXinUtil.getFriends { (b) in
                if b {
                    let con  = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
                    if con != nil {
                        for c in con! {
                            for d in c!.data! {
                                if d?.user_id == m.user_id {
                                    vc.type=3
                                    vc.model = d
                                    vc.group=self.model
                                    vc.member = m
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    return
                                }
                            }
                        }
                        vc.type=2
                        vc.group=self.model
                        vc.member = m
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }else{
                        UIApplication.shared.keyWindow?.makeToast("网络请求失败")
                    }
                }else{
                    UIApplication.shared.keyWindow?.makeToast("网络请求失败")
                }
            }
            return
        }
        for c in contact! {
            for d in c!.data! {
                if d?.user_id == m.user_id {
                    vc.type=3
                    vc.model = d
                    vc.group=self.model
                    vc.member = m
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            }
        }
       vc.type=2
       vc.group=self.model
       vc.member = m
       self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onGroupTop(sender:UISwitch) {
        if sender.isOn {
            if isLoading
            {
                return
            }
            self.isLoading = true
            let model = ChatTopSendModel()
            model.type = 2
            model.target_id = self.model?.groupId
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
                                                NotificationCenter.default.post(Notification(name: Notification.Name("UpdateMessage")))
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
        }else{
            if isLoading
            {
                return
            }
            self.isLoading = true
            let model = ChatTopSendModel()
            model.type = 2
            model.target_id = self.model?.groupId
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
                                                NotificationCenter.default.post(Notification(name: Notification.Name("UpdateMessage")))
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
    }
    
    @objc func onGroupSheild(sender:UISwitch) {
        
        if sender.isOn {
            if isLoading
            {
                return
            }
            self.isLoading = true
            let model = DeleteGroupSendModel()
            model.group_id = self.model?.groupId
            BoXinProvider.request(.SetGroupSheild(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    
                                    EMClient.shared()?.groupManager.ignoreGroupPush(self.model!.groupId!, ignore: true)
                                    self.model?.is_pingbi = 1
                                    QueryFriend.shared.addGroup(id: self.model!.groupId!, nickName: self.model!.groupName!, portrait1: self.model!.portrait!, admin_id: self.model!.administrator_id!, is_admin1: self.model!.is_admin, is_mg: self.model!.is_menager, notice1: self.model?.notice, type: self.model!.group_type, allMute: self.model!.is_all_banned, pingbi: self.model!.is_pingbi, userSum: self.model?.groupUserSum ?? 0)
                                    NotificationCenter.default.post(Notification(name: Notification.Name("UpdateMessage")))
                                    self.isLoading = false
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
        }else{
            if isLoading
            {
                return
            }
            self.isLoading = true
            let model = DeleteGroupSendModel()
            model.group_id = self.model?.groupId
            BoXinProvider.request(.CancelGroupSheild(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    
                                    EMClient.shared()?.groupManager.ignoreGroupPush(self.model!.groupId!, ignore: false)
                                    self.model?.is_pingbi = 2
                                    QueryFriend.shared.addGroup(id: self.model!.groupId!, nickName: self.model!.groupName!, portrait1: self.model!.portrait!, admin_id: self.model!.administrator_id!, is_admin1: self.model!.is_admin, is_mg: self.model!.is_menager, notice1: self.model?.notice, type: self.model!.group_type, allMute: self.model!.is_all_banned, pingbi: self.model!.is_pingbi, userSum: self.model?.groupUserSum ?? 0)
                                    NotificationCenter.default.post(Notification(name: Notification.Name("UpdateMessage")))
                                    self.isLoading = false
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
    }
    
    func onJinyan(indexPath:IndexPath) {
        if data![indexPath.row - 2]!.is_shield == 2 {
            setShieldSingle(row: indexPath.row - 2)
        }else{
            cancelShieldSingle(row: indexPath.row - 2)
        }
    }
    
    func onMoveOut(indexPath:IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("QuestionKick", comment: "Are you sure you want to kick him/her?"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (a) in
            if self.isLoading
            {
                return
            }
            self.isLoading = true
            SVProgressHUD.show()
            let  model = AddBatchSendModel()
            model.group_id = self.model?.groupId
            model.group_user_ids = self.data![indexPath.row - 2]!.user_id
            BoXinProvider.request(.GroupRemoveBatch(model: model)) { (result) in
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
                                    BoXinUtil.getGroupMember(groupID: self.model!.groupId!, Complite: { (b) in
                                        
                                        if b {
                                            DispatchQueue.main.async {
                                                let body = EMCmdMessageBody(action: "")
                                                var dic = ["type":"qun","id":self.model?.groupId]
                                                if self.model?.is_all_banned == 1 {
                                                    dic.updateValue("2", forKey: "grouptype")
                                                }else{
                                                    dic.updateValue("1", forKey: "grouptype")
                                                }
                                                let msg = EMMessage(conversationID: self.model!.groupId!, from: self.da!.db!.user_id!, to: self.model!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                                msg?.chatType = EMChatTypeGroupChat
                                                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                    
                                                }, completion: { (msg, err) in
                                                    if err != nil {
                                                        print(err?.errorDescription)
                                                    }
                                                    
                                                })
                                                self.onUpdate()
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
    
    func setShieldSingle(row:Int) {
        if isLoading
        {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let  model = ShieldSigleSendModel()
        model.group_id = self.model?.groupId
        model.groupUserId = data![row]!.user_id
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
                                BoXinUtil.getGroupMember(groupID: self.model!.groupId!, Complite: { (b) in
                                    
                                    if b {
                                        DispatchQueue.main.async {
                                            let body = EMCmdMessageBody(action: "")
                                            let dic = ["type":"qun_shield","id":self.model?.groupId,"userid":self.data![row]!.user_id,"qun_shield":"1"]
                                            let msg = EMMessage(conversationID: self.data![row]!.group_id!, from: self.da!.db!.user_id!, to: self.data![row]!.group_id!, body: body, ext: dic as [AnyHashable : Any])
                                            msg?.chatType = EMChatTypeGroupChat
                                            EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                
                                            }, completion: { (msg, err) in
                                                if err != nil {
                                                    print(err?.errorDescription)
                                                }
                                                
                                            })
                                            
                                            self.onUpdate()
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
    
    func cancelShieldSingle(row:Int) {
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let  model = ShieldSigleSendModel()
        model.group_id = self.model?.groupId
        model.groupUserId = data![row]!.user_id
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
                                BoXinUtil.getGroupMember(groupID: self.model!.groupId!, Complite: { (b) in
                                    
                                    if b {
                                        DispatchQueue.main.async {
                                            let body = EMCmdMessageBody(action: "")
                                            let dic = ["type":"qun_shield","id":self.model?.groupId,"userid":self.data![row]!.user_id,"qun_shield":"2"]
                                            let msg = EMMessage(conversationID: self.data![row]!.group_id!, from: self.da!.db!.user_id!, to: self.data![row]!.group_id!, body: body, ext: dic as [AnyHashable : Any])
                                            msg?.chatType = EMChatTypeGroupChat
                                            EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                
                                            }, completion: { (msg, err) in
                                                if err != nil {
                                                    print(err?.errorDescription)
                                                }
                                                
                                            })
                                            self.onUpdate()
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

}
