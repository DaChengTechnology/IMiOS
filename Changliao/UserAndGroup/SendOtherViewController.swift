//
//  SendOtherViewController.swift
//  boxin
//
//  Created by guduzhonglao on 8/8/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD
import Masonry

class SendOtherViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    var dataArr:[BoXinConversationModel] = Array<BoXinConversationModel>()
    var message:EMMessage?
    var IastId:String?
    var onTap = false
    var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    var searchTextFeild:UITextField  = UITextField(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
    var cancelBtn:UIButton = UIButton(type: .custom)
    let queue = DispatchQueue(label: "updateConversation")
    let contract = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
    let allGroup = QueryFriend.shared.getAllGroup()
    var searchedContract:[FriendData]?
    var searchedGroup:[GroupViewModel]?

    override func viewDidLoad() {
        super.viewDidLoad()

        let topView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        topView.backgroundColor = UIColor.white
        self.view.addSubview(topView)
        topView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.height.mas_equalTo()(50)
        }
        let searchImage = UIImageView(image: UIImage(named: "搜索"))
        topView.addSubview(searchImage)
        searchImage.mas_makeConstraints { (make) in
            make?.left.equalTo()(topView.mas_left)?.offset()(16)
            make?.width.mas_equalTo()(16)
            make?.height.mas_equalTo()(18)
            make?.centerY.equalTo()(topView.mas_centerY)
        }
        cancelBtn.setImage(UIImage(named: "错误111"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        topView.addSubview(cancelBtn)
        cancelBtn.mas_makeConstraints { (make) in
            make?.right.equalTo()(topView.mas_right)?.offset()(-16)
            make?.width.mas_equalTo()(30)
            make?.height.mas_equalTo()(30)
            make?.centerY.equalTo()(topView.mas_centerY)
        }
        searchTextFeild.placeholder = NSLocalizedString("Search", comment: "Search")
        searchTextFeild.borderStyle = .none
        searchTextFeild.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        searchTextFeild.delegate = self
        topView.addSubview(searchTextFeild)
        searchTextFeild.mas_makeConstraints { (make) in
            make?.left.equalTo()(searchImage.mas_right)?.offset()(8)
            make?.top.equalTo()(topView)?.offset()(3)
            make?.right.equalTo()(cancelBtn.mas_right)?.offset()(-8)
            make?.bottom.equalTo()(topView)?.offset()(-3)
        }
        tableView.register(UINib(nibName: "SendOtherTableViewCell", bundle: nil), forCellReuseIdentifier: "SendOther")
        tableView.rowHeight = 64
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        self.title = "消息转发"
        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        self.view.addSubview(tableView)
        tableView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(topView.mas_bottom)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.bottom.equalTo()(self.view.mas_bottom)
        }
        cancelBtn.isHidden = true
        onTap = false
        queue.async {
            self.loadConversation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if searchedContract != nil && searchedGroup != nil {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 27))
        headerView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        headerView.addSubview(lable)
        lable.font = UIFont.systemFont(ofSize: 14)
        if searchedContract == nil && searchedGroup == nil {
            if !(searchTextFeild.text?.isEmpty ?? true) {
                lable.text = ""
            }else{
                lable.text = "最近聊天"
            }
        }
        if searchedContract != nil && searchedGroup != nil {
            if section == 0 {
                lable.text = "联系人"
            }else{
                lable.text = "群组"
            }
        }
        if searchedContract != nil && searchedGroup == nil {
            lable.text = "联系人"
        }
        if searchedContract == nil && searchedGroup != nil {
            lable.text = "群组"
        }
        lable.mas_makeConstraints { (make) in
            make?.left.equalTo()(headerView.mas_left)?.setOffset(16)
            make?.centerY.equalTo()(headerView)
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (searchedContract != nil && searchedGroup != nil) || !(searchTextFeild.text?.isEmpty ?? true) {
            if section == 0 {
                return searchedContract?.count ?? 0
            }else{
                return searchedGroup?.count ?? 0
            }
        }
        if searchedContract != nil && searchedGroup == nil {
            return searchedContract?.count ?? 0
        }
        if searchedContract == nil && searchedGroup != nil {
            return searchedGroup?.count ?? 0
        }
        return dataArr.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendOther", for: indexPath) as! SendOtherTableViewCell

        // Configure the cell...
        if searchedContract == nil && searchedGroup == nil && (searchTextFeild.text?.isEmpty ?? true) {
            let model = dataArr[indexPath.row]
            if model.avatarURLPath != nil {
                cell.headImageView.sd_setImage(with: URL(string: model.avatarURLPath), placeholderImage: model.avatarImage, options: .allowInvalidSSLCertificates, completed: nil)
            }else{
                cell.headImageView.image = model.avatarImage
            }
            cell.nameLabel.text = model.title
        }
        if searchedContract != nil && searchedGroup != nil {
            if indexPath.section == 0 {
                let model = searchedContract![indexPath.row]
                if model.portrait != nil {
                    cell.headImageView.sd_setImage(with: URL(string: model.portrait!), placeholderImage: UIImage(named: "moren"), options: .allowInvalidSSLCertificates, completed: nil)
                }else{
                    cell.headImageView.image = UIImage(named: "moren")
                }
                cell.nameLabel.text = model.target_user_nickname ?? model.friend_self_name
            }else{
                let model = searchedGroup![indexPath.row]
                if model.portrait != nil {
                    cell.headImageView.sd_setImage(with: URL(string: model.portrait!), placeholderImage: UIImage(named: "moren"), options: .allowInvalidSSLCertificates, completed: nil)
                }else{
                    cell.headImageView.image = UIImage(named: "moren")
                }
                cell.nameLabel.text = model.groupName
            }
        }
        if searchedContract != nil && searchedGroup == nil {
            let model = searchedContract![indexPath.row]
            if model.portrait != nil {
                cell.headImageView.sd_setImage(with: URL(string: model.portrait!), placeholderImage: UIImage(named: "moren"), options: .allowInvalidSSLCertificates, completed: nil)
            }else{
                cell.headImageView.image = UIImage(named: "moren")
            }
            cell.nameLabel.text = model.target_user_nickname ?? model.friend_self_name
        }
        if searchedContract == nil && searchedGroup != nil {
            let model = searchedGroup![indexPath.row]
            if model.portrait != nil {
                cell.headImageView.sd_setImage(with: URL(string: model.portrait!), placeholderImage: UIImage(named: "moren"), options: .allowInvalidSSLCertificates, completed: nil)
            }else{
                cell.headImageView.image = UIImage(named: "moren")
            }
            cell.nameLabel.text = model.groupName
        }
        if indexPath.row == 0 {
            cell.topView.isHidden = false
        }else{
            cell.topView.isHidden = true
        }
        if indexPath.row >= 0 &&  indexPath.row < dataArr.count - 1 {
            cell.shortView.isHidden = false
            cell.bottonView.isHidden = true
        }
        if indexPath.row == dataArr.count - 1 {
            cell.shortView.isHidden = true
            cell.bottonView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if onTap {
            return
        }
        onTap = true
        searchTextFeild.resignFirstResponder()
        SVProgressHUD.show()
        if let b = message?.body as? EMFileMessageBody {
            if !FileManager.default.fileExists(atPath: b.localPath) {
                let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                var dic = path[path.endIndex - 1]
                dic.appendPathComponent("temp", isDirectory: true)
                dic.appendPathComponent(b.displayName, isDirectory: false)
                BoXinProvider.request(.DownLoad(url: b.remotePath, filepath: dic.path)) { (_) in
                    if FileManager.default.fileExists(atPath: dic.path) {
                        if self.message!.body.type == EMMessageBodyTypeVideo {
                            if let body = self.message?.body as? EMVideoMessageBody {
                                body.localPath = dic.path
                                if self.searchedContract == nil && self.searchedGroup == nil {
                                    let model = self.dataArr[indexPath.row]
                                    if model.conversation.type == EMConversationTypeGroupChat {
                                        self.sendOther(conversationId: model.conversation.conversationId, body: body, isPerson: false)
                                    }else{
                                        self.sendOther(conversationId: model.conversation.conversationId, body: body, isPerson: true)
                                    }
                                }
                                if self.searchedContract != nil && self.searchedGroup != nil {
                                    if indexPath.section == 0 {
                                        self.sendOther(conversationId: self.searchedContract![indexPath.row].user_id!, body: body, isPerson: true)
                                    }else{
                                        self.sendOther(conversationId: self.searchedGroup![indexPath.row].groupId!, body: body, isPerson: false)
                                    }
                                }
                                if self.searchedContract != nil && self.searchedGroup == nil {
                                    self.sendOther(conversationId: self.searchedContract![indexPath.row].user_id!, body: body, isPerson: true)
                                }
                                if self.searchedContract == nil && self.searchedGroup != nil {
                                    self.sendOther(conversationId: self.searchedGroup![indexPath.row].groupId!, body: body, isPerson: false)
                                }
                                return
                            }else{
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    UIApplication.shared.keyWindow?.makeToast("发送失败")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                }
                            }
                        }
                        if self.message!.body.type == EMMessageBodyTypeImage {
                            if let body = self.message?.body as? EMImageMessageBody {
                                body.localPath = dic.path
                                if self.searchedContract == nil && self.searchedGroup == nil {
                                    let model = self.dataArr[indexPath.row]
                                    if model.conversation.type == EMConversationTypeGroupChat {
                                        self.sendOther(conversationId: model.conversation.conversationId, body: body, isPerson: false)
                                    }else{
                                        self.sendOther(conversationId: model.conversation.conversationId, body: body, isPerson: true)
                                    }
                                }
                                if self.searchedContract != nil && self.searchedGroup != nil {
                                    if indexPath.section == 0 {
                                        self.sendOther(conversationId: self.searchedContract![indexPath.row].user_id!, body: body, isPerson: true)
                                    }else{
                                        self.sendOther(conversationId: self.searchedGroup![indexPath.row].groupId!, body: body, isPerson: false)
                                    }
                                }
                                if self.searchedContract != nil && self.searchedGroup == nil {
                                    self.sendOther(conversationId: self.searchedContract![indexPath.row].user_id!, body: body, isPerson: true)
                                }
                                if self.searchedContract == nil && self.searchedGroup != nil {
                                    self.sendOther(conversationId: self.searchedGroup![indexPath.row].groupId!, body: body, isPerson: false)
                                }
                                return
                            }else{
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    UIApplication.shared.keyWindow?.makeToast("发送失败")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                }
                            }
                        }
                        if  self.message!.body.type == EMMessageBodyTypeFile {
                            if let body = self.message?.body as? EMFileMessageBody {
                                body.localPath = dic.path
                                if self.searchedContract == nil && self.searchedGroup == nil {
                                    let model = self.dataArr[indexPath.row]
                                    if model.conversation.type == EMConversationTypeGroupChat {
                                        self.sendOther(conversationId: model.conversation.conversationId, body: body, isPerson: false)
                                    }else{
                                        self.sendOther(conversationId: model.conversation.conversationId, body: body, isPerson: true)
                                    }
                                }
                                if self.searchedContract != nil && self.searchedGroup != nil {
                                    if indexPath.section == 0 {
                                        self.sendOther(conversationId: self.searchedContract![indexPath.row].user_id!, body: body, isPerson: true)
                                    }else{
                                        self.sendOther(conversationId: self.searchedGroup![indexPath.row].groupId!, body: body, isPerson: false)
                                    }
                                }
                                if self.searchedContract != nil && self.searchedGroup == nil {
                                    self.sendOther(conversationId: self.searchedContract![indexPath.row].user_id!, body: body, isPerson: true)
                                }
                                if self.searchedContract == nil && self.searchedGroup != nil {
                                    self.sendOther(conversationId: self.searchedGroup![indexPath.row].groupId!, body: body, isPerson: false)
                                }
                                return
                            }else{
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    UIApplication.shared.keyWindow?.makeToast("发送失败")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                }
                            }
                        }
                    }
                }
                return
            }
        }
        if searchedContract == nil && searchedGroup == nil {
            let model = dataArr[indexPath.row]
            if model.conversation.type == EMConversationTypeGroupChat {
                sendOther(conversationId: model.conversation.conversationId, body: message!.body, isPerson: false)
            }else{
                sendOther(conversationId: model.conversation.conversationId, body: message!.body, isPerson: true)
            }
        }
        if searchedContract != nil && searchedGroup != nil {
            if indexPath.section == 0 {
                sendOther(conversationId: searchedContract![indexPath.row].user_id!, body: message!.body, isPerson: true)
            }else{
                sendOther(conversationId: searchedGroup![indexPath.row].groupId!, body: message!.body, isPerson: false)
            }
        }
        if searchedContract != nil && searchedGroup == nil {
            sendOther(conversationId: searchedContract![indexPath.row].user_id!, body: message!.body, isPerson: true)
        }
        if searchedContract == nil && searchedGroup != nil {
            sendOther(conversationId: searchedGroup![indexPath.row].groupId!, body: message!.body, isPerson: false)
        }
    }
    
    func sendOther(conversationId:String,body:EMMessageBody,isPerson:Bool) {
        if isPerson {
            if let friend = BoXinUtil.getFriendModel(conversationId) {
                message?.ext?["JPZReceivePortrait"] = friend.portrait
                message?.ext?["JPZReceiveNikeName"] = friend.friend_self_name
                message?.ext?["isFired"] = friend.is_yhjf
            }else{
                let data = QueryFriend.shared.queryStronger(id: conversationId)
                message?.ext?["JPZReceivePortrait"] = data?.portrait
                message?.ext?["JPZReceiveNikeName"] = data?.name
                message?.ext?["isFired"] = 0
            }
            message?.ext?["JPZIsFrom"] = "Chat"
            let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            message?.ext?["JPZUserPortrait"] = data?.db?.portrait
            message?.ext?["JPZUserNikeName"] = data?.db?.user_name
            let msg = EMMessage(conversationID: conversationId, from: EMClient.shared()?.currentUsername, to: conversationId, body: body, ext: message?.ext)
            EMClient.shared()?.chatManager.send(msg, progress: { (p) in
            }, completion: { (m, e) in
                if e == nil {
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateSendOtherMessage"), object: msg)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        UIApplication.shared.keyWindow?.makeToast("已发送")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }else{
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        UIApplication.shared.keyWindow?.makeToast("发送失败")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            })
        }else{
            if message?.ext?["type"] as? String == "person" {
                self.view.makeToast("不能向群组发送名片")
                return
            }
            let group = QueryFriend.shared.queryGroup(id: conversationId)
            let member = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: conversationId)
            let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
            message?.ext?["JPZUserPortrait"] = data?.db?.portrait
            message?.ext?["JPZUserNikeName"] = data?.db?.user_name
            message?.ext?["JPZIsFrom"] = "GroupChat"
            message?.ext?["JPZReceivePortrait"] = group?.portrait
            message?.ext?["JPZReceiveNikeName"] = group?.groupName
            message?.ext?["isFired"] = 0
            if group?.is_admin == 1 || group?.is_menager == 1 {
                let msg = EMMessage(conversationID: conversationId, from: EMClient.shared()?.currentUsername, to: conversationId, body: body, ext: message?.ext)
                msg?.chatType = EMChatTypeGroupChat
                EMClient.shared()?.chatManager.send(msg, progress: { (p) in
                    
                }, completion: { (m, e) in
                    if e == nil {
                        NotificationCenter.default.post(name: NSNotification.Name("UpdateSendOtherMessage"), object: msg)
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            UIApplication.shared.keyWindow?.makeToast("已发送")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }else{
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            UIApplication.shared.keyWindow?.makeToast("发送失败")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                })
                return
            }else if member?.is_shield == 1 && member?.is_manager == 2 && member?.is_administrator == 2 {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    UIApplication.shared.keyWindow?.makeToast("您被禁言,不能转发!")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }else{
                if group?.is_all_banned == 1 {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        UIApplication.shared.keyWindow?.makeToast("您被禁言,不能转发!")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                    return
                }else{
                    let conversation = EMClient.shared()?.chatManager.getConversation(conversationId, type: EMConversationTypeGroupChat, createIfNotExist: true)
                    conversation?.loadMessagesStart(fromId: nil, count: 50, searchDirection: EMMessageSearchDirectionUp) { (m, e) in
                        if m == nil {
                            let msg = EMMessage(conversationID: conversationId, from: EMClient.shared()?.currentUsername, to: conversationId, body: self.message?.body, ext: self.message?.ext)
                            msg?.chatType = EMChatTypeGroupChat
                            EMClient.shared()?.chatManager.send(msg, progress: { (p) in
                                
                            }, completion: { (m, e) in
                                if e == nil {
                                    NotificationCenter.default.post(name: NSNotification.Name("UpdateSendOtherMessage"), object: msg)
                                    DispatchQueue.main.async {
                                        SVProgressHUD.dismiss()
                                        UIApplication.shared.keyWindow?.makeToast("已发送")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        SVProgressHUD.dismiss()
                                        UIApplication.shared.keyWindow?.makeToast("发送失败")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                }
                            })
                            return
                        }
                        if m!.count < 10 {
                            let msg = EMMessage(conversationID: conversationId, from: EMClient.shared()?.currentUsername, to: conversationId, body: self.message?.body, ext: self.message?.ext)
                            msg?.chatType = EMChatTypeGroupChat
                            EMClient.shared()?.chatManager.send(msg, progress: { (p) in
                                
                            }, completion: { (m, e) in
                                if e == nil {
                                    NotificationCenter.default.post(name: NSNotification.Name("UpdateSendOtherMessage"), object: msg)
                                    DispatchQueue.main.async {
                                        SVProgressHUD.dismiss()
                                        UIApplication.shared.keyWindow?.makeToast("已发送")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        SVProgressHUD.dismiss()
                                        UIApplication.shared.keyWindow?.makeToast("发送失败")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                }
                            })
                            return
                        }
                        var msgs = m as! [EMMessage]
                        msgs = msgs.filter({ (ms) -> Bool in
                            return ms.from == EMClient.shared()?.currentUsername
                        })
                        msgs = msgs.filter({ (ms) -> Bool in
                            if ms.ext != nil {
                                if ms.ext["em_recall"] != nil {
                                    return false
                                }
                            }
                            return true
                        })
                        msgs = msgs.sorted(by: { (a, b) -> Bool in
                            return a.localTime > b.localTime
                        })
                        if msgs.count > 9 {
                            if NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970InMilliSecond() - Double(msgs[9].timestamp) > 60 * 1000 {
                                let msg = EMMessage(conversationID: conversationId, from: EMClient.shared()?.currentUsername, to: conversationId, body: self.message?.body, ext: self.message?.ext)
                                msg?.chatType = EMChatTypeGroupChat
                                EMClient.shared()?.chatManager.send(msg, progress: { (p) in
                                    
                                }, completion: { (m, e) in
                                    if e == nil {
                                        NotificationCenter.default.post(name: NSNotification.Name("UpdateSendOtherMessage"), object: msg)
                                        DispatchQueue.main.async {
                                            SVProgressHUD.dismiss()
                                            UIApplication.shared.keyWindow?.makeToast("已发送")
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                                self.navigationController?.popViewController(animated: true)
                                            })
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            SVProgressHUD.dismiss()
                                            UIApplication.shared.keyWindow?.makeToast("发送失败")
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                                self.navigationController?.popViewController(animated: true)
                                            })
                                        }
                                    }
                                })
                                return
                            }else{
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    UIApplication.shared.keyWindow?.makeToast("60s内只能能发送10条消息")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                }
                            }
                        }else{
                            let msg = EMMessage(conversationID: conversationId, from: EMClient.shared()?.currentUsername, to: conversationId, body: self.message?.body, ext: self.message?.ext)
                            msg?.chatType = EMChatTypeGroupChat
                            EMClient.shared()?.chatManager.send(msg, progress: { (p) in
                                
                            }, completion: { (m, e) in
                                if e == nil {
                                    NotificationCenter.default.post(name: NSNotification.Name("UpdateSendOtherMessage"), object: msg)
                                    DispatchQueue.main.async {
                                        SVProgressHUD.dismiss()
                                        UIApplication.shared.keyWindow?.makeToast("已发送")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        SVProgressHUD.dismiss()
                                        UIApplication.shared.keyWindow?.makeToast("发送失败")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                    }
                                }
                            })
                            return
                        }
                    }
                }
            }
        }
    }
    
    @objc func onCancel() {
        searchTextFeild.text = nil
        textFieldDidChange(textField: searchTextFeild)
    }
    
    @objc func textFieldDidChange(textField:UITextField) {
        if textField.text?.count ?? 0 > 0 {
            cancelBtn.isHidden = false
            if let range = textField.markedTextRange {
                
            }else{
                self.searchKeyWord(textField.text!)
            }
        }else{
            searchedGroup = nil
            searchedContract = nil
            cancelBtn.isHidden = true
            queue.async {
                self.loadConversation()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textFieldDidChange(textField: textField)
        return true
    }
    
    func searchKeyWord(_ text:String) {
        searchedGroup = nil
        searchedContract = nil
        for con in contract! {
            for c in con!.data! {
                if c?.target_user_nickname?.contains(text) ?? false {
                    if searchedContract == nil {
                        searchedContract = Array<FriendData>()
                    }
                    searchedContract?.append(c!)
                }
                if c?.id_card?.contains(text) ?? false {
                    if searchedContract == nil {
                        searchedContract = Array<FriendData>()
                    }
                    searchedContract?.append(c!)
                }
                if c?.friend_self_name?.contains(text) ?? false {
                    if searchedContract == nil {
                        searchedContract = Array<FriendData>()
                    }
                    searchedContract?.append(c!)
                }
            }
        }
        if searchedContract != nil {
            searchedContract = NSSet(array: searchedContract!).allObjects as? [FriendData]
        }
        for group in allGroup {
            if group.groupName?.contains(text) ?? false{
                if searchedGroup == nil {
                    searchedGroup = Array<GroupViewModel>()
                }
                searchedGroup?.append(group)
            }
        }
        if searchedGroup != nil {
            searchedGroup = NSSet(array: searchedGroup!).allObjects as? [GroupViewModel]
        }
        self.tableView.reloadData()
    }

    func loadConversation() {
        let arr = EMClient.shared()?.chatManager.getAllConversations()
        if arr != nil {
            if arr?.count == 0 {
                return
            }
            var carr = arr as! [EMConversation]
            carr = carr.filter({ (c) -> Bool in
                if c.conversationId == EMClient.shared()?.currentUsername {
                    EMClient.shared()?.chatManager.deleteConversation(c.conversationId, isDeleteMessages: true, completion: { (cc, e) in
                        
                    })
                    return false
                }
                if c.conversationId == "collection" {
                    return false
                }
                if c.conversationId == "a77635d2218d49e592e678078ca90b4d" || c.conversationId == "7702f518c6cd46ce8e9976fe11568ca9" || c.conversationId == "ef1569ada7ab4c528375994e0de246ca" || c.conversationId == "2290120c5be7424082216dc8d98179a4" || c.conversationId == "1ec14a2de29d4c22926463c4338a36a7" || c.conversationId == "d18f2eecff1e4dada58a9f4350be12d6" {
                    return false
                }
                return true
            })
            dataArr = carr.map({ (c) -> BoXinConversationModel in
                return BoXinConversationModel(conversation: c)
            })
            dataArr = dataArr.filter({ (m) -> Bool in
                if m.conversation.latestMessage == nil {
                    EMClient.shared()?.chatManager.deleteConversation(m.conversation.conversationId, isDeleteMessages: false, completion: { (s, e) in
                        
                    })
                    return false
                }
                return true
            })
        }
        if dataArr.count > 1 {
            let chatTop = [ChatTapData].deserialize(from: UserDefaults.standard.string(forKey: "ChatTop"))
            dataArr = dataArr.filter({ (b) -> Bool in
                if b.conversation.conversationId == "ef1569ada7ab4c528375994e0de246ca" || b.conversation.conversationId == "2290120c5be7424082216dc8d98179a4" {
                    return false
                }
                if b.conversation.conversationId == "a77635d2218d49e592e678078ca90b4d" || b.conversation.conversationId == "7702f518c6cd46ce8e9976fe11568ca9" {
                    return false
                }
                return true
            })
            var data = dataArr.filter({ (b) -> Bool in
                if chatTop == nil {
                    return false
                }
                for c in chatTop! {
                    if c?.target_id == b.conversation.conversationId {
                        b.isTop = true
                        return true
                    }
                }
                return false
            })
            var untop = dataArr.filter({ (b) -> Bool in
                if chatTop == nil {
                    
                    
                    return true
                }
                for c in chatTop! {
                    if c?.target_id == b.conversation.conversationId {
                        return false
                    }
                }
                return true
            })
            data.sort(by: { (b1, b2) -> Bool in
                if b1.conversation.latestMessage == nil {
                    return false
                }
                if b2.conversation.latestMessage == nil {
                    return true
                }
                return b1.conversation.latestMessage.timestamp > b2.conversation.latestMessage.timestamp
            })
            untop.sort(by: { (b1, b2) -> Bool in
                if b1.conversation.latestMessage == nil {
                    return true
                }
                if b2.conversation.latestMessage == nil {
                    return false
                }
                return b1.conversation.latestMessage.timestamp > b2.conversation.latestMessage.timestamp
            })
            dataArr = data
            if untop != nil {
                for u in stride(from: 0, to: untop.count , by: 1) {
                    dataArr.append(untop[u])
                }
            }
        }
        let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
        for data in dataArr {
            if data.conversation.type == EMConversationTypeChat {
                if contact != nil {
                    for c in contact! {
                        for d in c!.data! {
                            if d?.user_id == data.conversation.conversationId {
                                data.title = d?.target_user_nickname
                                data.avatarImage = UIImage(named: "moren")
                                data.avatarURLPath = d?.portrait
                                if d?.is_shield == 1 {
                                    data.noTips = true
                                }else{
                                    data.noTips = false
                                }
                                break
                            }
                        }
                    }
                    if data.title == data.conversation.conversationId {
                        let da = QueryFriend.shared.queryStronger(id: data.conversation.conversationId)
                        data.title = da?.name
                        data.avatarURLPath = da?.portrait
                        data.noTips = false
                        data.avatarImage = UIImage(named: "moren")
                    }
                }else{
                    let da = QueryFriend.shared.queryStronger(id: data.conversation.conversationId)
                    data.title = da?.name
                    data.avatarURLPath = da?.portrait
                    data.noTips = false
                    data.avatarImage = UIImage(named: "moren")
                }
            }
            if data.conversation.type == EMConversationTypeGroupChat {
                let sqdata = QueryFriend.shared.queryGroup(id: data.conversation.conversationId)
                data.title = sqdata?.groupName
                data.avatarImage = UIImage(named: "群聊11111")
                data.avatarURLPath = sqdata?.portrait
                if sqdata?.group_type == 1
                {
                    data.isGroupType = true
                }else
                {
                    data.isGroupType = false
                }
                if sqdata?.is_pingbi == 1 {
                    data.noTips = true
                }else{
                    data.noTips = false
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
