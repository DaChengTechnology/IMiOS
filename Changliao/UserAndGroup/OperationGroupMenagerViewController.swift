//
//  OperationGroupMenagerViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/24/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import Masonry
import SVProgressHUD

class OperationGroupMenagerViewController: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    
    var model:GroupViewModel?
    var data:[GroupMemberData?]?
    var searchArr:[GroupMemberData?]?
    var menagerArr:[GroupMemberData?]?
    var memberArr:[GroupMemberData?]?
    var textSearchTextFeild:UITextField?
    var table:UITableView?
    let cancelBtn = UIButton(type: .custom)
    var isloadding = false
    let optionQueue = DispatchQueue(label: "group.queue")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
        self.view.addSubview(topView)
        topView.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.height.mas_equalTo()(40)
        }
        let searchImageView = UIImageView(image: UIImage(named: "搜索"))
        topView.addSubview(searchImageView)
        searchImageView.mas_makeConstraints { (make) in
            make?.left.equalTo()(topView.mas_left)?.offset()(16)
            make?.width.mas_equalTo()(15)
            make?.height.mas_equalTo()(17)
            make?.top.equalTo()(topView.mas_top)?.offset()(10)
        }
        cancelBtn.setImage(UIImage(named: "错误111"), for: .normal)
        cancelBtn.setImage(UIImage(named: "错误111"), for: .highlighted)
        cancelBtn.setImage(UIImage(named: "错误111"), for: .selected)
        cancelBtn.setImage(UIImage(named: "错误111"), for: .disabled)
        cancelBtn.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.mas_makeConstraints { (make) in
            make?.right.equalTo()(topView.mas_right)?.offset()(-16)
            make?.height.mas_equalTo()(40)
            make?.width.mas_equalTo()(40)
            make?.centerY.equalTo()(topView.mas_centerY)
        }
        cancelBtn.isHidden = true
        textSearchTextFeild = UITextField(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        textSearchTextFeild?.delegate = self
        textSearchTextFeild?.borderStyle = .none
        textSearchTextFeild?.placeholder = NSLocalizedString("Search", comment: "Search")
        textSearchTextFeild?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        topView.addSubview(textSearchTextFeild!)
        textSearchTextFeild?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(searchImageView.mas_right)?.offset()(8)
            make?.top.equalTo()(topView.mas_top)?.offset()(5)
            make?.right.equalTo()(cancelBtn.mas_left)?.offset()(-8)
            make?.bottom.equalTo()(topView.mas_bottom)?.offset()(-8)
        })
        let searchLine = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        topView.addSubview(searchLine)
        searchLine.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "d9d9d9")
        searchLine.mas_makeConstraints { (make) in
            make?.left.equalTo()(topView.mas_left)
            make?.bottom.equalTo()(topView.mas_bottom)
            make?.right.equalTo()(topView.mas_right)
            make?.height.mas_equalTo()(0.5)
        }
        table = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        table?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        table?.dataSource = self
        table?.delegate = self
        table?.separatorStyle = .none
        self.view.addSubview(table!)
        table?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(topView.mas_bottom)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
        })
        table?.register(UINib(nibName: "GroupMenagerTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupMenager")
        self.title = "管理员设置"
        self.memberArr = nil
        self.menagerArr = nil
        data = data?.filter({ (a) -> Bool in
            if a?.user_id == model?.administrator_id {
                return false
            }
            return true
        })
        for da in data! {
            if da?.is_administrator == 2 && da?.is_manager == 1 {
                if menagerArr == nil {
                    menagerArr = Array<GroupMemberData?>()
                }
                menagerArr?.append(da)
            }
            if da?.is_administrator == 2 && da?.is_manager == 2 {
                if memberArr == nil {
                    memberArr = Array<GroupMemberData?>()
                }
                memberArr?.append(da)
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
    
    @objc func onCancel() {
        textSearchTextFeild?.text = nil
        searchArr = nil
        cancelBtn.isHidden = true
        table?.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchArr != nil {
            return 1
        }
        if menagerArr == nil {
            return 1
        }
        if memberArr == nil {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchArr != nil {
            return 0
        }
        return 27
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        label.font = UIFont.systemFont(ofSize: 14)
        v.addSubview(label)
        label.mas_makeConstraints { (make) in
            make?.left.equalTo()(v.mas_left)?.offset()(16)
            make?.centerY.equalTo()(v.mas_centerY)
        }
        if section == 0 {
            if menagerArr == nil {
                label.text = "群成员"
            }else{
                label.text = "管理员"
            }
        }else{
            label.text = "群成员"
        }
        return v
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if searchArr != nil {
                return searchArr!.count
            }
            if menagerArr == nil {
                if memberArr == nil {
                    return 0
                }
                return memberArr!.count
            }
            return menagerArr!.count
        }
        return memberArr!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if searchArr != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMenager", for: indexPath) as! GroupMenagerTableViewCell
                cell.headImageView.sd_setImage(with: URL(string: searchArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                
                
                var text:String? = ""
                if QueryFriend.shared.checkFriend(userID: (searchArr?[indexPath.row ]!.user_id)!) {
                    
                    if searchArr?[indexPath.row ]?.friend_name != ""
                    {
                        text = searchArr?[indexPath.row ]?.friend_name
                    }else
                    {
                        text = searchArr?[indexPath.row ]?.user_name
                    }
                    
                }else{
                    if searchArr?[indexPath.row ]?.group_user_nickname != "" {
                        text = searchArr?[indexPath.row ]?.group_user_nickname;
                    }else{
                        text = searchArr?[indexPath.row ]?.user_name
                    }
                }
                cell.nickNameLabel.text = text
                if searchArr![indexPath.row]?.is_manager == 1 {
                    cell.settingSwitch.isOn = true
                }else{
                    cell.settingSwitch.isOn = false
                }
                cell.settingSwitch.tag = indexPath.row + 100000
                cell.settingSwitch.addTarget(self, action: #selector(changeSwitch(sender:)), for: .touchUpInside)
                return cell
            }
            if menagerArr == nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMenager", for: indexPath) as! GroupMenagerTableViewCell
                cell.headImageView.sd_setImage(with: URL(string: memberArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                
                
                var text:String? = ""
                if QueryFriend.shared.checkFriend(userID: (memberArr?[indexPath.row ]!.user_id)!) {
                    
                    if memberArr?[indexPath.row ]?.friend_name != ""
                    {
                        text = memberArr?[indexPath.row ]?.friend_name
                    }else
                    {
                        text = memberArr?[indexPath.row ]?.user_name
                    }
                    
                }else{
                    if memberArr?[indexPath.row ]?.group_user_nickname != "" {
                        text = memberArr?[indexPath.row ]?.group_user_nickname;
                    }else{
                        text = memberArr?[indexPath.row ]?.user_name
                    }
                }
                cell.nickNameLabel.text = text
                
                cell.settingSwitch.isOn = false

                cell.settingSwitch.tag = indexPath.row + 10000
                cell.settingSwitch.addTarget(self, action: #selector(changeSwitch(sender:)), for: .touchUpInside)
                
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMenager", for: indexPath) as! GroupMenagerTableViewCell
            cell.headImageView.sd_setImage(with: URL(string: menagerArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
            
            
            var text:String? = ""
            if QueryFriend.shared.checkFriend(userID: (menagerArr?[indexPath.row ]!.user_id)!) {
                
                if menagerArr?[indexPath.row ]?.friend_name != ""
                {
                    text = menagerArr?[indexPath.row ]?.friend_name
                }else
                {
                    text = menagerArr?[indexPath.row ]?.user_name
                }
                
            }else{
                if menagerArr?[indexPath.row ]?.group_user_nickname != "" {
                    text = menagerArr?[indexPath.row ]?.group_user_nickname;
                }else{
                    text = menagerArr?[indexPath.row ]?.user_name
                }
            }
            cell.nickNameLabel.text = text
            
            cell.settingSwitch.isOn = true
            cell.settingSwitch.tag = indexPath.row
            cell.settingSwitch.addTarget(self, action: #selector(changeSwitch(sender:)), for: .touchUpInside)

            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMenager", for: indexPath) as! GroupMenagerTableViewCell
        cell.headImageView.sd_setImage(with: URL(string: memberArr![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
        
        
        var text:String? = ""
        if QueryFriend.shared.checkFriend(userID: (memberArr?[indexPath.row ]!.user_id)!) {
            
            if memberArr?[indexPath.row ]?.friend_name != ""
            {
                text = memberArr?[indexPath.row ]?.friend_name
            }else
            {
                text = memberArr?[indexPath.row ]?.user_name
            }
            
        }else{
            if memberArr?[indexPath.row ]?.group_user_nickname != "" {
                text = memberArr?[indexPath.row ]?.group_user_nickname;
            }else{
                text = memberArr?[indexPath.row ]?.user_name
            }
        }
        cell.nickNameLabel.text = text
        
        cell.settingSwitch.isOn = false
        cell.settingSwitch.tag = indexPath.row + 10000
        cell.settingSwitch.addTarget(self, action: #selector(changeSwitch(sender:)), for: .touchUpInside)

        
        return cell
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
    @objc func changeSwitch(sender:UISwitch){
        
        if sender.isOn == true{
            let tag = sender.tag
            optionQueue.async {
                self.onAddMenager(sender: sender, tag )
            }
        }else
        {
            let tag = sender.tag
            optionQueue.async {
                self.onDeleMenager(sender: sender, tag)
            }
        }
    }
    
    func onAddMenager(sender:UISwitch, _ tag:Int) {
        if isloadding {
            return
        }
        isloadding = true
        SVProgressHUD.show()
        let model = AddGroupMenagerSendModel()
        if tag > 99999 {
            guard (searchArr?.count ?? 0) > tag - 100000 else {
                return
            }
            model.group_id = self.model?.groupId
            model.newManager_id = searchArr?[tag - 100000]?.user_id
        }else{
            guard (memberArr?.count ?? 0) > tag - 10000 else {
                return
            }
            model.group_id = self.model?.groupId
            model.newManager_id = memberArr?[tag - 10000]?.user_id
        }
        if model.newManager_id == nil {
            return
        }
        BoXinProvider.request(.AddGroupMenager(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                BoXinUtil.getGroupMember(groupID: self.model!.groupId!, Complite: { (b) in
                                    
                                    if b {
                                        var err:EMError?
                                        var dic = ["type":"qun","id":self.model?.groupId,"qun_auth":"qun_auth","auth":1] as [String : Any]
                                        if sender.tag > 99999 {
                                            EMClient.shared()?.groupManager.addAdmin(self.searchArr![sender.tag - 100000]!.user_id!, toGroup: self.model!.groupId!, error: &err)
                                            dic.updateValue(self.searchArr![sender.tag - 100000]!.user_id!, forKey: "managementid")
                                        }else{
                                            EMClient.shared()?.groupManager.addAdmin(self.memberArr![sender.tag - 10000]!.user_id!, toGroup: self.model!.groupId!, error: &err)
                                            dic.updateValue(self.memberArr![sender.tag - 10000]!.user_id!, forKey: "managementid")
                                        }
                                        let body = EMCmdMessageBody(action: "")
                                        let msg = EMMessage(conversationID: self.model!.groupId!, from: EMClient.shared()?.currentUsername, to: self.model!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                        msg?.chatType = EMChatTypeGroupChat
                                        EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                            
                                        }, completion: { (msg, err) in
                                            if err != nil {
                                                print(err?.errorDescription)
                                            }
                                            
                                        })
                                        self.data = QueryFriend.shared.getGroupMembers(groupId: self.model!.groupId!)
                                        if self.data != nil {
                                            NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                                            self.data = self.data!.filter({ (member) -> Bool in
                                                if member?.user_id == self.model?.administrator_id {
                                                    return false
                                                }
                                                return true
                                            })
                                            self.memberArr = nil
                                            self.menagerArr = nil
                                            for da in self.data! {
                                                if da?.is_administrator == 2 && da?.is_manager == 1 {
                                                    if self.menagerArr == nil {
                                                        self.menagerArr = Array<GroupMemberData?>()
                                                    }
                                                    self.menagerArr?.append(da)
                                                }
                                                if da?.is_administrator == 2 && da?.is_manager == 2 {
                                                    if self.memberArr == nil {
                                                        self.memberArr = Array<GroupMemberData?>()
                                                    }
                                                    self.memberArr?.append(da)
                                                }
                                            }
                                            DispatchQueue.main.async {
                                                if self.textSearchTextFeild?.text != "" && self.textSearchTextFeild?.text != nil {
                                                    self.sorted(keyWord: self.textSearchTextFeild!.text!)
                                                }else {
                                                    self.table?.reloadData()
                                                }
                                            }
                                        }
                                        self.isloadding = false
                                        SVProgressHUD.dismiss()
                                    }else
                                    {
                                        DispatchQueue.main.async {
                                           self.isloadding = false
                                           SVProgressHUD.dismiss()
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }
                                    
                                    
                                })
                            }else{
                                if model.message == "请重新登录" {
                                    BoXinUtil.Logout()
                                    DispatchQueue.main.async {
                                        if (UIViewController.currentViewController() as? BootViewController) != nil {
                                            let app = UIApplication.shared.delegate as! AppDelegate
                                            app.isNeedLogin = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                self.isloadding = false
                                            }
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
                                }
                                DispatchQueue.main.async {
                                    self.view.makeToast(model.message)
                                    sender.setOn(false, animated: false)
                                }
                                self.isloadding = false
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                                sender.setOn(false, animated: false)
                            }
                            Thread.sleep(forTimeInterval: 0.5)
                            self.isloadding = false
                        }
                    }catch{
                         DispatchQueue.main.async {
                                                       self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                                       SVProgressHUD.dismiss()
                            sender.setOn(false, animated: false)
                                                   }
                                                   Thread.sleep(forTimeInterval: 0.5)
                                                   self.isloadding = false
                    }
                }else{
                    DispatchQueue.main.async {
                                                   self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                                                   SVProgressHUD.dismiss()
                        sender.setOn(false, animated: false)
                                               }
                                               Thread.sleep(forTimeInterval: 0.5)
                                               self.isloadding = false
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    SVProgressHUD.dismiss()
                    sender.setOn(false, animated: false)
                }
                print(err.errorDescription!)
                Thread.sleep(forTimeInterval: 0.5)
                self.isloadding = false
            }
        }
    }
    
    func onDeleMenager(sender:UISwitch, _ tag:Int) {
        if isloadding {
            return
        }
        isloadding = true
        SVProgressHUD.show()
        let model = DeleteGroupMenagerSendModel()
        if tag > 99999 {
            guard (searchArr?.count ?? 0) > tag - 100000 else {
                isloadding = false
                SVProgressHUD.dismiss()
                return
            }
            model.group_id = self.model?.groupId
            model.oldManager_id = searchArr?[tag - 100000]?.user_id
        }else{
            guard (menagerArr?.count ?? 0) > tag else {
                isloadding = false
                SVProgressHUD.dismiss()
                return
            }
            model.group_id = self.model?.groupId
            model.oldManager_id = menagerArr?[tag]?.user_id
        }
        if model.oldManager_id == nil {
            isloadding = false
            SVProgressHUD.dismiss()
            return
        }
        BoXinProvider.request(.DeleteGroupMenager(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                BoXinUtil.getGroupMember(groupID: self.model!.groupId!, Complite: { (b) in
                                    
                                    if b {
                                        var err:EMError?
                                        var dic = ["type":"qun","id":self.model?.groupId,"qun_auth":"qun_auth","auth":2] as [String : Any]
                                        if sender.tag > 99999 {
                                            EMClient.shared()?.groupManager.removeAdmin(self.searchArr![sender.tag - 100000]!.user_id!, fromGroup: self.model!.groupId!, error: &err)
                                            dic.updateValue(self.searchArr![sender.tag - 100000]!.user_id!, forKey: "managementid")
                                        }else{
                                            EMClient.shared()?.groupManager.removeAdmin(self.menagerArr![sender.tag]!.user_id!, fromGroup: self.model!.groupId!, error: &err)
                                            dic.updateValue(self.menagerArr![sender.tag]!.user_id!, forKey: "managementid")
                                        }
                                        let body = EMCmdMessageBody(action: "")
                                        let msg = EMMessage(conversationID: self.model!.groupId!, from: EMClient.shared()?.currentUsername, to: self.model!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                        msg?.chatType = EMChatTypeGroupChat
                                        EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                            
                                        }, completion: { (msg, err) in
                                            if err != nil {
                                                print(err?.errorDescription)
                                            }
                                            
                                        })
                                        self.data = QueryFriend.shared.getGroupMembers(groupId: self.model!.groupId!)
                                        if self.data != nil {
                                            NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                                            self.data = self.data!.filter({ (member) -> Bool in
                                                if member?.user_id == self.model?.administrator_id {
                                                    return false
                                                }
                                                return true
                                            })
                                            self.memberArr = nil
                                            self.menagerArr = nil
                                            for da in self.data! {
                                                if da?.is_administrator == 2 && da?.is_manager == 1 {
                                                    if self.menagerArr == nil {
                                                        self.menagerArr = Array<GroupMemberData?>()
                                                    }
                                                    self.menagerArr?.append(da)
                                                }
                                                if da?.is_administrator == 2 && da?.is_manager == 2 {
                                                    if self.memberArr == nil {
                                                        self.memberArr = Array<GroupMemberData?>()
                                                    }
                                                    self.memberArr?.append(da)
                                                }
                                            }
                                            DispatchQueue.main.async {
                                                if self.textSearchTextFeild?.text != "" && self.textSearchTextFeild?.text != nil {
                                                    self.sorted(keyWord: self.textSearchTextFeild!.text!)
                                                }else {
                                                     self.table?.reloadData()
                                                }
                                            }
                                        }
                                        DispatchQueue.main.async {
                                            SVProgressHUD.dismiss()
                                        }
                                        Thread.sleep(forTimeInterval: 0.5)
                                        self.isloadding = false
                                    }else
                                    {
                                        DispatchQueue.main.async {
                                            self.navigationController?.popToRootViewController(animated: true)
                                            SVProgressHUD.dismiss()
                                        }
                                        Thread.sleep(forTimeInterval: 0.5)
                                        self.isloadding = false
                                    }
                                    
                                    
                                })
                            }else{
                                if model.message == "请重新登录" {
                                    BoXinUtil.Logout()
                                    DispatchQueue.main.async {
                                        if (UIViewController.currentViewController() as? BootViewController) != nil {
                                                let app = UIApplication.shared.delegate as! AppDelegate
                                                app.isNeedLogin = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    self.isloadding = false
                                                }
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
                                    }
                                self.view.makeToast(model.message)
                                sender.setOn(true, animated: false)
                                    SVProgressHUD.dismiss()
                                Thread.sleep(forTimeInterval: 0.5)
                                self.isloadding = false
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                sender.setOn(true, animated: false)
                                SVProgressHUD.dismiss()
                            }
                            Thread.sleep(forTimeInterval: 0.5)
                            self.isloadding = false
                        }
                    }catch{
                        DispatchQueue.main.async {
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            sender.setOn(true, animated: false)
                            SVProgressHUD.dismiss()
                        }
                        Thread.sleep(forTimeInterval: 0.5)
                        self.isloadding = false
                    }
                }else{
                    DispatchQueue.main.async {
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        sender.setOn(true, animated: false)
                        SVProgressHUD.dismiss()
                    }
                    Thread.sleep(forTimeInterval: 0.5)
                    self.isloadding = false
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    sender.setOn(true, animated: false)
                    SVProgressHUD.dismiss()
                }
                Thread.sleep(forTimeInterval: 0.5)
                self.isloadding = false
                print(err.errorDescription!)
            }
        }
    }
    
    @objc func textFieldDidChange(textField:UITextField) {
        if textField.markedTextRange != nil {
            return
        }
        if textField.text == nil {
            cancelBtn.isHidden = true
            searchArr = nil
            table?.reloadData()
            return
        }else if textField.text!.count == 0 {
            cancelBtn.isHidden = true
            searchArr = nil
            table?.reloadData()
            return
        }else{
            cancelBtn.isHidden = false
        }
        sorted(keyWord: textField.text!)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 > 0 {
            sorted(keyWord: textField.text!)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func sorted(keyWord:String) {
        searchArr  = Array<GroupMemberData?>()
        guard let da = data else {
            return
        }
        for con in da {
            if con?.group_user_nickname?.contains(keyWord) ?? false {
                if searchArr == nil {
                    searchArr = Array<GroupMemberData>()
                }
                searchArr?.append(con)
            }
            if con?.id_card?.contains(keyWord) ?? false {
                if searchArr == nil {
                    searchArr = Array<GroupMemberData>()
                }
                searchArr?.append(con)
            }
            if con?.user_name?.contains(keyWord) ?? false {
                if searchArr == nil {
                    searchArr = Array<GroupMemberData>()
                }
                searchArr?.append(con)
            }
            if con?.friend_name?.contains(keyWord) ?? false {
                if searchArr == nil {
                    searchArr = Array<GroupMemberData>()
                }
                searchArr?.append(con)
            }
        }
        if searchArr != nil {
            searchArr = NSSet(array: searchArr!).allObjects as! [GroupMemberData?]
        }
        table?.reloadData()
    }

}
