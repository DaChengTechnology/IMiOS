//
//  ConversationViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import PPBadgeViewSwift

class ConversationViewController: UITableViewController,EMChatManagerDelegate,EMGroupManagerDelegate,EMContactManagerDelegate,UISearchControllerDelegate,UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        search(keyWord: searchController.searchBar.text ?? "")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.setPositionAdjustment(.zero, for: .search)
        DispatchQueue.global().async {
            self.contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
            self.group = QueryFriend.shared.getAllGroup()
        }
        search(keyWord: searchController.searchBar.text ?? "")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
//        searchController.searchBar.setPositionAdjustment(UIOffset(horizontal: (searchController.searchBar.bounds.width-searchController.searchBar.searchTextField.placeholderRect(forBounds: searchController.searchBar.searchTextField.bounds).width-40-20)/2, vertical: 0), for: .search)
        
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableViewDidTriggerHeaderRefresh()
        guard let friend = selectFriend else {
            guard let des = selectGroup else {
                return
            }
            let vc = ChatViewController(conversationChatter: des.groupId, conversationType: EMConversationTypeGroupChat)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            vc?.title = des.groupName
            self.navigationController?.pushViewController(vc!, animated: true)
            return
        }
        if friend.user_id == "收藏" {
            let vc = CollectionViewController(conversationChatter: "collection", conversationType: EMConversationTypeChat)
             self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.lastConlection = nil
            self.navigationController?.pushViewController(vc!, animated: true)
            return
        }
        let vc = ChatViewController(conversationChatter: friend.user_id, conversationType: EMConversationTypeChat)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
        vc?.title = (friend.target_user_nickname?.isEmpty ?? true) ? friend.friend_self_name : friend.target_user_nickname
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - EaseConversationListViewControllerDataSource
    var contact:[FriendViewModel?]?
    var dataArray:[BoXinConversationModel]?
    var isFirst:Bool = true
    var creatingGroupID:String?
    let queue = DispatchQueue.main
    let updateQueue = DispatchQueue(label: "com.bj.updateMessage")
    var isLoading:Bool = false
    var needLoad:Bool = false
    var isNeedLoadOnline:Bool = false
    var userList:[String] = Array<String>()
    var lastConlection:CollectionListData?
    var searchController = UISearchController(searchResultsController: nil)
    var group:[GroupViewModel]?
    var contactData:[FriendData?]?
    var groupData:[GroupViewModel]?
    var selectFriend:FriendData?
    var selectGroup:GroupViewModel?
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchController.isActive {
            return 56
        }
        return DCUtill.SCRATIO(x: 72)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchController.isActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts") as! ContactsTableViewCell
            if indexPath.row < (contactData?.count ?? 0) {
                if contactData![indexPath.row]!.user_id == "收藏" {
                    cell.headImgView.image = UIImage(named: "collectionHead")
                    cell.nickNameLabel.text = "我的收藏"
                    cell.Idlabel.isHidden = true
                    if indexPath.row == contactData!.count - 1 {
                        cell.bottonView.isHidden = true
                    }else{
                        cell.bottonView.isHidden = false
                    }
                    cell.Jiantou.isHidden=true
                    return cell
                }
                cell.headImgView.sd_setImage(with: URL(string: contactData![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
                cell.nickNameLabel.text = contactData![indexPath.row]!.target_user_nickname
                cell.Idlabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@", contactData![indexPath.row]!.id_card!)
                if indexPath.row == contactData!.count - 1 {
                    cell.bottonView.isHidden = true
                }
            }else{
                if indexPath.row - (contactData?.count ?? 0) > groupData?.count ?? 0 {
                    return cell
                }
                let des = groupData![indexPath.row - (contactData?.count ?? 0)]
                cell.headImgView.sd_setImage(with: URL(string: des.portrait!), placeholderImage: UIImage(named: "群聊11111"))
                cell.nickNameLabel.text = des.groupName
                cell.Idlabel.isHidden = true
                if indexPath.row == groupData!.count - 1 {
                    cell.bottonView.isHidden = true
                }else{
                    cell.bottonView.isHidden = false
                }
            }
            cell.Jiantou.isHidden=true
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Conversation") as! ConversationTableViewCell
        if dataArray == nil {
            return cell
        }
        if indexPath.row >= dataArray!.count {
            return cell
        }
        let model = dataArray![indexPath.row]
        if model.avatarURLPath == nil {
            cell.headImageView.image = model.avatarImage
        }else{
            cell.headImageView.sd_setImage(with: URL(string: model.avatarURLPath), placeholderImage: model.avatarImage)
        }
        cell.nickNameLabel.text = model.title
        if model.conversation.latestMessage == nil {
            cell.timeLabel.text = ""
        }else{
            cell.timeLabel.text = self.getLastTime(message: model.conversation.latestMessage)
        }
        cell.messageLabel.attributedText = getLastMessageText(model: model)
        cell.onLineImageView.isHidden = !model.isOnLine
        cell.yhjf.isHidden = !model.isYHJF
        if model.conversation.unreadMessagesCount > 0 {
            if model.conversation.unreadMessagesCount > 9 {
                cell.unReadView.pp.moveBadge(x: -14, y: 2)
            }else{
                cell.unReadView.pp.moveBadge(x: -2, y: 2)
            }
            if model.noTips {
                cell.unReadView.pp.addDot()
                cell.unReadView.pp.moveBadge(x: -2, y: 2)
                cell.unReadView.pp.setBadge(height: 11)
            }else{
                cell.unReadView.pp.setBadge(height: 16)
                if model.conversation.unreadMessagesCount > 99
                {
                     cell.unReadView.pp.addBadge(text: "99+")
                }else{
                     cell.unReadView.pp.addBadge(number: Int(model.conversation.unreadMessagesCount))
                }
            }
        }else{
            cell.unReadView.pp.hiddenBadge()
        }
        if model.noTips {
            
            cell.tipsImageView.image = UIImage(named: "铃声-静音")
            if model.isGroupType == true
            {
                cell.WorkImage.image = UIImage(named: "工作小矢量图")
                cell.WorkImage.isHidden = false
            }else{
                
                cell.WorkImage.isHidden = true
            }
        }else{
            cell.tipsImageView.image = nil
            if model.isGroupType == true
            {

                cell.tipsImageView.image = UIImage(named: "工作小矢量图")
                cell.WorkImage.isHidden = true
            }else{
                
                cell.WorkImage.isHidden = true
            }
        }
        if model.isTop {
            cell.contentView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "f2e9e9")
        }else{
            cell.contentView.backgroundColor = UIColor.white
        }
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return (contactData?.count ?? 0) + (groupData?.count ?? 0)
        }
        if dataArray == nil {
            return 0
        }
        return dataArray!.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if dataArray?.count ?? 0 > indexPath.row {
                if dataArray![indexPath.row].conversation.conversationId == "collection" {
                    UserDefaults.standard.set(lastConlection?.id, forKey: "DeleteCollection")
                    UserDefaults.standard.synchronize()
                    self.lastConlection = nil
                    EMClient.shared()?.chatManager.deleteConversation(dataArray![indexPath.row].conversation.conversationId, isDeleteMessages: true, completion: { (str, err) in
                        self.dataArray?.remove(at: indexPath.row)
                        tableView.beginUpdates()
                        tableView.deleteRows(at: [indexPath], with: .left)
                        tableView.endUpdates()
                    })
                    return
                }
                EMClient.shared()?.chatManager.deleteConversation(dataArray![indexPath.row].conversation.conversationId, isDeleteMessages: true, completion: { (str, err) in
                    self.dataArray?.remove(at: indexPath.row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .left)
                    tableView.endUpdates()
                })
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            if indexPath.row < (self.contactData?.count ?? 0) {
                selectFriend=contactData![indexPath.row]
            }else{
                if indexPath.row - (self.contactData?.count ?? 0) >= (self.groupData?.count ?? 0) {
                    return
                }
                selectGroup = self.groupData![indexPath.row - (self.contactData?.count ?? 0)]
            }
            searchController.isActive=false
            searchController.searchBar.resignFirstResponder()
            return
        }
        if dataArray?.count ?? 0 > indexPath.row {
            if dataArray![indexPath.row].conversation.conversationId == "a77635d2218d49e592e678078ca90b4d" || dataArray![indexPath.row].conversation.conversationId == "7702f518c6cd46ce8e9976fe11568ca9" {
                let vc = GroupNotifationViewController()
                vc.conversationID = dataArray![indexPath.row].conversation.conversationId
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(vc, animated: true)
                var err:EMError?
                dataArray![indexPath.row].conversation.markAllMessages(asRead: &err)
                return
            }
            if dataArray![indexPath.row].conversation.conversationId == "collection" {
                let vc = CollectionViewController(conversationChatter: "collection", conversationType: EMConversationTypeChat)
                 self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                self.lastConlection = nil
                self.navigationController?.pushViewController(vc!, animated: true)
                return
            }
            let vc = ChatViewController(conversationChatter: dataArray![indexPath.row].conversation.conversationId, conversationType: dataArray![indexPath.row].conversation.type)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            vc?.title = dataArray![indexPath.row].title
            if dataArray![indexPath.row].conversation.ext != nil {
                if dataArray![indexPath.row].conversation.ext["kHaveAtMessage"] != nil {
                    dataArray![indexPath.row].conversation.ext["kHaveAtMessage"] = nil
                }
            }
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "Conversation")
        searchController.delegate=self
        searchController.searchResultsUpdater=self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor=self.navigationController?.navigationBar.tintColor
        searchController.searchBar.backgroundColor=UIColor.white
        tableView.tableHeaderView=searchController.searchBar
        tableView.separatorStyle = .none
        tableView.rowHeight = 68
        tableView.estimatedRowHeight = 68
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.backgroundColor=UIColor.white
        view.backgroundColor=UIColor.white
        tableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "Contacts")
        NotificationCenter.default.addObserver(self, selector: #selector(ConnecttionStateDidChange(notifation:)), name: NSNotification.Name(rawValue: "EMConnectionState"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessage), name: Notification.Name(rawValue: "UpdateMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addingGroupMember(noti:)), name: NSNotification.Name("createGroup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endGroupMember), name: NSNotification.Name("endGroup"), object: nil)
        EMClient.shared()?.chatManager.remove(self)
        EMClient.shared()?.groupManager.removeDelegate(self)
        EMClient.shared()?.contactManager.removeDelegate(self)
        EMClient.shared()?.chatManager.add(self, delegateQueue: DispatchQueue.global())
        EMClient.shared()?.groupManager.add(self, delegateQueue: DispatchQueue.global())
        EMClient.shared()?.contactManager.add(self, delegateQueue: DispatchQueue.global())
    }
    
    @objc func addingGroupMember(noti:Notification){
        creatingGroupID = noti.object as? String ?? ""
    }
    
    @objc func endGroupMember() {
        creatingGroupID = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.isNetworkConnect {
            self.title = "畅聊"
        }else{
            self.title = "未连接"
        }
        DCUtill.setNavigationBarTittle(controller: self)
        let plus = UIBarButtonItem(image: UIImage(named: "添加(1)"), style: .plain, target: self, action: #selector(onPlus))
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItems([plus], animated: false)
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem=nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNeedLoadOnline = true
//        searchController.searchBar.setPositionAdjustment(UIOffset(horizontal: (searchController.searchBar.bounds.width-searchController.searchBar.searchTextField.placeholderRect(forBounds: searchController.searchBar.searchTextField.bounds).width-40-40)/2, vertical: 0), for: .search)
        self.tableViewDidTriggerHeaderRefresh()
        getLastCollection()
    }
    
    
    func getLastCollection() {
        DispatchQueue(label: "cl.getLastCollection").async {
            self.lastConlection = nil
            BoXinProvider.request(.GetLastCollection(model: UserInfoSendModel())) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = GetLastCollectionReciveModel.deserialize(from: try? res.mapString()) {
                            if model.code == 200 {
                                if model.data == nil {
                                    self.lastConlection = nil
                                    EMClient.shared()?.chatManager.deleteConversation("collection", isDeleteMessages: true, completion: nil)
                                    return
                                }
                                if let id = UserDefaults.standard.string(forKey: "DeleteCollection") {
                                    if id == model.data?.id {
                                        EMClient.shared()?.chatManager.deleteConversation("collection", isDeleteMessages: true, completion: nil)
                                        self.lastConlection = nil
                                        return
                                    }else{
                                        UserDefaults.standard.removeObject(forKey: "DeleteCollection")
                                        UserDefaults.standard.synchronize()
                                    }
                                }
                                if model.data?.content == nil {
                                    let dic = try? res.mapJSON() as? Dictionary<String, Any>
                                    let data = dic?["data"] as? Dictionary<String, Any>
                                    let content = data?["content"] as? Dictionary<String, Any>
                                    model.data?.content = MessgaeData.deserialize(from: content)
                                    if model.data?.content == nil {
                                        return
                                    }
                                }
                                self.lastConlection = model.data
                                if self.lastConlection != nil {
                                    DispatchQueue.main.async {
                                        self.tableViewDidTriggerHeaderRefresh()
                                    }
                                }
                            }
                        }
                    }
                case .failure(_):
                    return
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.lastConlection = nil
    }
    
    @objc func updateMessage() {
        DispatchQueue.main.async {
            self.tableViewDidTriggerHeaderRefresh()
        }
    }
    
    fileprivate func updateConversationList(_ arr: [Any]?) {
        if isLoading {
            needLoad = true
            return
        }
        isLoading = true
        updateQueue.async {
            var msgData:[BoXinConversationModel] = Array<BoXinConversationModel>()
            if arr != nil {
                var carr = arr as! [EMConversation]
                carr = carr.filter({ (c) -> Bool in
                    if c.conversationId == EMClient.shared()?.currentUsername || c.conversationId == "1ec14a2de29d4c22926463c4338a36a7" || c.conversationId == "d18f2eecff1e4dada58a9f4350be12d6" {
                        EMClient.shared()?.chatManager.deleteConversation(c.conversationId, isDeleteMessages: true, completion: { (cc, e) in
                            
                        })
                        return false
                    }
                    return true
                })
                var user = Array<String>()
                msgData = carr.map({ (c) -> BoXinConversationModel in
                    if c.type == EMConversationTypeChat {
                        user.append(c.conversationId)
                    }
                    return BoXinConversationModel(conversation: c)
                })
                if self.isNeedLoadOnline {
                    self.isNeedLoadOnline = false
                    self.getOnlineUser(user)
                }
                msgData = msgData.filter({ (m) -> Bool in
                    if m.conversation.latestMessage == nil {
                        EMClient.shared()?.chatManager.deleteConversation(m.conversation.conversationId, isDeleteMessages: false, completion: { (s, e) in
                            
                        })
                        return false
                    }
                    return true
                })
            }
            if msgData.count > 0 {
                let chatTop = [ChatTapData].deserialize(from: UserDefaults.standard.string(forKey: "ChatTop"))
                var data = msgData.filter({ (b) -> Bool in
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
                var untop = msgData.filter({ (b) -> Bool in
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
                msgData = data
                msgData.append(contentsOf: untop)
            }
            self.contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
            for data in msgData {
                if data.conversation.type == EMConversationTypeChat {
                    if data.conversation.conversationId == "ef1569ada7ab4c528375994e0de246ca" || data.conversation.conversationId == "2290120c5be7424082216dc8d98179a4" {
                        data.title = "系统消息"
                        data.avatarImage = UIImage(named: "admin_notice1")
                        data.isTop = false
                        data.noTips = false
                        continue
                    }
                    if data.conversation.conversationId == "a77635d2218d49e592e678078ca90b4d" || data.conversation.conversationId == "7702f518c6cd46ce8e9976fe11568ca9" {
                        data.title = "群通知"
                        data.avatarImage = UIImage(named: "群通知")
                        data.isTop = false
                        data.noTips = false
                        continue
                    }
                    if data.conversation.conversationId == "collection" {
                        data.avatarImage = UIImage(named: "collectionHead")
                        data.title = "我的收藏"
                        data.isTop = false
                        data.noTips = false
                        continue
                    }
                    if self.userList.contains(data.conversation.conversationId) {
                        data.isOnLine = true
                    }else{
                        data.isOnLine = false
                    }
                    if self.contact != nil {
                        for c in self.contact! {
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
                                    if d?.is_yhjf == 1 {
                                        data.isYHJF = true
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
                    if let sqdata = QueryFriend.shared.queryGroup(id: data.conversation.conversationId){
                        data.title = sqdata.groupName
                        data.avatarImage = UIImage(named: "群聊11111")
                        data.avatarURLPath = sqdata.portrait
                        if sqdata.group_type == 1
                        {
                            data.isGroupType = true
                        }else
                        {
                            data.isGroupType = false
                        }
                        if sqdata.is_pingbi == 1 {
                            data.noTips = true
                        }else{
                            data.noTips = false
                        }
                    }else{
                        BoXinUtil.getGroupOnlyInfo(groupId: data.conversation.conversationId, Complite: { (b) in
                            if b {
                                DispatchQueue.main.async {
                                    self.tableViewDidTriggerHeaderRefresh()
                                }
                            }
                        })
                    }
                }
            }
            var brage = 0
            self.dataArray = msgData.map({ (b) -> BoXinConversationModel in
                if !b.noTips {
                    brage += Int(b.conversation.unreadMessagesCount)
                }
                return b
            })
            DispatchQueue.main.async {
                if brage > 0 {
                    if brage > 99 {
                        self.tabBarItem.badgeValue = "99+"
                    }else{
                        self.tabBarItem.badgeValue = String(format: "%d", brage)
                    }
                }else{
                    self.tabBarItem.badgeValue = nil
                }
                UIApplication.shared.applicationIconBadgeNumber = brage
                self.tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.isLoading = false
                if self.needLoad {
                    self.needLoad = false;
                    DispatchQueue.main.async {
                        self.tableViewDidTriggerHeaderRefresh()
                    }
                }
            })
        }
    }
    
    func getOnlineUser(_ user:[String]) {
        weak var weakSelf = self
        reqquestQueue.addOperation {
            let model = GetOnlineUserSendModel()
            model.userIds = user.joined(separator: ",")
            BoXinProvider.request(.GetOnlineUser(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = GetOnlineUserReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    guard let data = model.data else {
                                        return
                                    }
                                    for online in data {
                                        weakSelf?.userList.append(online?.id ?? "")
                                    }
                                    DispatchQueue.main.async {
                                        self.tableViewDidTriggerHeaderRefresh()
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
                                            let nav = UINavigationController(rootViewController: WelcomeViewController())
                                            nav.modalPresentationStyle = .overFullScreen
                                            self.present(nav, animated: false, completion: nil)
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
    }
    
    func tableViewDidTriggerHeaderRefresh() {
        if searchController.isActive {
            return
        }
        queue.async {
            var arr = EMClient.shared()?.chatManager.getAllConversations()
            if arr == nil {
                return
            }
            guard arr != nil else {
                self.updateConversationList(arr)
                return
            }
            if let last = self.lastConlection {
                if last.time != 0 && last.content != nil {
                    var needAdd = true
                    for d in arr! {
                        guard let e = d as? EMConversation else{
                            continue
                        }
                        if e.conversationId == "collection" {
                            needAdd = false
                            if e.latestMessage.timestamp < last.time ?? 0 {
                                e.insert(last.toMessage(), error: nil)
                            }
                        }
                    }
                    if needAdd {
                        let c = EMClient.shared()?.chatManager.getConversation("collection", type: EMConversationTypeChat, createIfNotExist: true)
                        c?.insert(last.toMessage(), error: nil)
                        arr?.append(c as Any)
                    }
                }
                
            }
            self.updateConversationList(arr)
        }
    }
    
    @objc func onPlus(){
        PlusView().show()
    }
    
    func getLastTime(message:EMMessage) -> String {
        
        return (NSDate(timeIntervalInMilliSecondSince1970: Double(message.timestamp))?.formattedTime())!
    }
    
    func getLastMessageText(model:BoXinConversationModel) -> NSAttributedString {
        let message = model.conversation.latestMessage
        let lastMsg = message?.body
        var text:String = ""
        var attrText:NSMutableAttributedString = NSMutableAttributedString()
        if (message?.ext?["isFired"] as? Int ?? 0) > 0 && (message?.ext?["isFired"] as? Int ?? 0) != 2 {
            return NSAttributedString(string: "[阅后即焚]")
        }
        switch lastMsg?.type {
        case EMMessageBodyTypeImage:
            text = "[图片]"
            attrText = NSMutableAttributedString(string: text)
        case EMMessageBodyTypeText:
            let body = lastMsg as! EMTextMessageBody
            if message?.from == "a77635d2218d49e592e678078ca90b4d" || message?.from == "7702f518c6cd46ce8e9976fe11568ca9" {
                let json = DCEncrypt.Decode_AES(strToDecode: String(body.text.split(separator: "_")[0]))
                let data = GroupNotifationModel.deserialize(from: json)
                if let m = data?.msg {
                    return NSAttributedString(string: m)
                }else{
                    return NSAttributedString(string: "")
                }
            }
            var txt:String = ""
            if body.text.hasSuffix("_encode") {
                let messagetext = String(body.text.split(separator: "_")[0].utf8)
                if messagetext != nil {
                    txt = DCEncrypt.Decode_AES(strToDecode: messagetext!)
                }
            }else{
                txt = body.text
            }
            attrText = EaseEmotionEscape.attributtedString(fromText: txt)
            if message?.ext != nil {
                if message?.ext["em_is_big_expression"] != nil {
                    text = "[动画表情]"
                    attrText = NSMutableAttributedString(string: text)
                }
                if message?.ext["type"] as? String == "person" {
                    text = "[分享名片]"
                    attrText = NSMutableAttributedString(string: text)
                }
                if message?.ext["callType"] as? String == "1" {
                    text = "[语音通话]"
                    attrText = NSMutableAttributedString(string: text)
                }
                if message?.ext["callType"] as? String == "2" {
                    text = "[视频通话]"
                    attrText = NSMutableAttributedString(string: text)
                }
            }
        case EMMessageBodyTypeVoice:
            text = "[语音]"
            attrText = NSMutableAttributedString(string: text)
        case EMMessageBodyTypeVideo:
            text = "[视频]"
            attrText = NSMutableAttributedString(string: text)
        case EMMessageBodyTypeLocation:
            text = "[位置]"
            attrText = NSMutableAttributedString(string: text)
        case EMMessageBodyTypeFile:
            text = "[文件]"
            attrText = NSMutableAttributedString(string: text)
        default:
            break
        }
        if message?.direction == EMMessageDirectionReceive {
            if message?.chatType == EMChatTypeChat {
                if contact != nil {
                    for c in contact! {
                        for a in (c?.data)! {
                            if a?.user_id == message?.from {
                                if a?.target_user_nickname != "" {
                                    attrText.insert(NSAttributedString(string: String(format: "%@:", (a?.target_user_nickname ?? ""))), at: 0)
                                }else{
                                    attrText.insert(NSAttributedString(string: String(format: "%@:", (a?.friend_self_name ?? ""))), at: 0)
                                }
                            }
                        }
                    }
                }
            }
            if message?.chatType == EMChatTypeGroupChat {
                let data = QueryFriend.shared.getGroupUser(userId: message!.from, groupId: message!.conversationId)
                if data != nil {
                    if QueryFriend.shared.checkFriend(userID: data!.user_id!) {
                        if data?.friend_name != "" {
                            attrText.insert(NSAttributedString(string: String(format: "%@:", (data?.friend_name ?? ""))), at: 0)
                        }else{
                            attrText.insert(NSAttributedString(string: String(format: "%@:", (data?.user_name ?? ""))), at: 0)
                        }
                    }else{
                        if data?.group_user_nickname != "" {
                            attrText.insert(NSAttributedString(string: String(format: "%@:", (data?.group_user_nickname ?? ""))), at: 0)
                        }else{
                            attrText.insert(NSAttributedString(string: String(format: "%@:", (data?.user_name ?? ""))), at: 0)
                        }
                    }
                }else{
                    let d = QueryFriend.shared.queryFriend(id: message!.from)
                    if d != nil {
                        attrText.insert(NSAttributedString(string: String(format: "%@:", (d?.name ?? ""))), at: 0)
                    }
                }
            }
        }
        let ext = model.conversation.ext
        if ext != nil {
            if ((ext!["kHaveAtMessage"] as? Int) != nil) {
                if (ext!["kHaveAtMessage"] as! Int) == 1 {
                    attrText.insert(NSAttributedString(string: "[有人@我]"), at: 0)
                    attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, 6))
                }
                if (ext!["kHaveAtMessage"] as! Int) == 2 {
                    attrText.insert(NSAttributedString(string: "[有全体消息]"), at: 0)
                    attrText.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, 7))
                }
            }
        }
        return attrText
    }
    
    @objc func ConnecttionStateDidChange(notifation:Notification) {
        let state = notifation.object as? EMConnectionState
        DispatchQueue.main.async {
            if UIViewController.currentViewController() is ConversationViewController {
                if state == EMConnectionConnected {
                    self.title = "畅聊"
                    DCUtill.setNavigationBarTittle(controller: self)
                }else{
                    self.title = "未连接"
                    DCUtill.setNavigationBarTittle(controller: self)
                }
            }
        }
    }
    
    func messagesDidReceive(_ aMessages: [Any]!) {
        if let  msgs = aMessages as? [EMMessage] {
            for m in msgs {
                if m.ext != nil {
                    if m.ext?["em_at_list"] as?  String == "ALL" {
                        let conversation = EMClient.shared()?.chatManager.getConversation(m.conversationId, type: EMConversationTypeGroupChat, createIfNotExist: false)
                        conversation?.ext = ["kHaveAtMessage":2]
                    }
                    
                    if let member = m.ext?["em_at_list"] as? Array<String>
                    {
                        for b in member
                        {
                            if b == EMClient.shared()?.currentUsername
                            {
                                
                                let conversation = EMClient.shared()?.chatManager.getConversation(m.conversationId, type: EMConversationTypeGroupChat, createIfNotExist: false)
                                conversation?.ext = ["kHaveAtMessage":1]
                            }
                            
                        }
                        
                      
                    }
                    
                }
            }
        }
        DispatchQueue.main.async {
            self.tableViewDidTriggerHeaderRefresh()
        }
    }
    
    func friendshipDidAdd(byUser aUsername: String!) {
        
        BoXinUtil.getFriends({(b) in
            
            if b {
                let conversation = EMClient.shared()?.chatManager.getConversation(aUsername, type: EMConversationTypeChat, createIfNotExist: true)
                if conversation?.latestMessage == nil {
                    DispatchQueue.main.async {
                        let app = UIApplication.shared.delegate as! AppDelegate
                        if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                            if UserDefaults.standard.bool(forKey: "sound") && UserDefaults.standard.bool(forKey: "shake") {
                                AudioServicesPlayAlertSound(app.soundID)
                                return
                            }else if UserDefaults.standard.bool(forKey: "sound") && !UserDefaults.standard.bool(forKey: "shake") {
                                AudioServicesPlaySystemSound(app.soundID)
                            }else if !UserDefaults.standard.bool(forKey: "sound") && UserDefaults.standard.bool(forKey: "shake") {
                                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                            }
                        }
                    }
                    let msg = EaseSDKHelper.getTextMessage("你们成为了好友", to: aUsername, messageType: EMChatTypeChat, messageExt: ["em_recall":true])
                    msg?.isRead = true
                    msg?.status = EMMessageStatusSucceed
                    var err:EMError?
                    conversation?.insert(msg, error: &err)
                    if err != nil {
                        print(err?.errorDescription)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateFriend"), object: nil)
                    DispatchQueue.main.async {
                        let app = UIApplication.shared.delegate as! AppDelegate
                        AudioServicesPlayAlertSound(app.soundID)
                    }
                    let arr = EMClient.shared()?.chatManager.getAllConversations()
                    DispatchQueue.main.async {
                        self.tableViewDidTriggerHeaderRefresh()
                    }
                }else{
                    if let body = conversation?.latestMessage.body as? EMTextMessageBody {
                        if body.text == "你们成为了好友" {
                            return
                        }
                    }
                    DispatchQueue.main.async {
                        let app = UIApplication.shared.delegate as! AppDelegate
                        if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                            if UserDefaults.standard.bool(forKey: "sound") && UserDefaults.standard.bool(forKey: "shake") {
                                AudioServicesPlayAlertSound(app.soundID)
                                return
                            }else if UserDefaults.standard.bool(forKey: "sound") && !UserDefaults.standard.bool(forKey: "shake") {
                                AudioServicesPlaySystemSound(app.soundID)
                            }else if !UserDefaults.standard.bool(forKey: "sound") && UserDefaults.standard.bool(forKey: "shake") {
                                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                            }
                        }
                    }
                    let msg = EaseSDKHelper.getTextMessage("你们成为了好友", to: aUsername, messageType: EMChatTypeChat, messageExt: ["em_recall":true])
                    msg?.isRead = true
                    msg?.status = EMMessageStatusSucceed
                    var err:EMError?
                    conversation?.insert(msg, error: &err)
                    if err != nil {
                        print(err?.errorDescription)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateFriend"), object: nil)
                    DispatchQueue.main.async {
                        let app = UIApplication.shared.delegate as! AppDelegate
                        AudioServicesPlayAlertSound(app.soundID)
                    }
                    DispatchQueue.main.async {
                        self.tableViewDidTriggerHeaderRefresh()
                    }
                }
            }
            
        })
    }
    
    func userDidJoin(_ aGroup: EMGroup!, user aUsername: String!) {
        if aGroup.groupId == creatingGroupID {
            return
        }
        BoXinUtil.getGroupOneMember(groupID: aGroup.groupId, userID: aUsername) { (b) in
            if b {
                NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
            }
        }
    }
    
    func didJoin(_ aGroup: EMGroup!, inviter aInviter: String!, message aMessage: String!) {
        if aGroup.owner != EMClient.shared()?.currentUsername {
            let conversation = EMClient.shared()?.chatManager.getConversation(aGroup.groupId, type: EMConversationTypeGroupChat, createIfNotExist: true)
            if conversation?.latestMessage == nil {
                DispatchQueue.main.async {
                let app = UIApplication.shared.delegate as! AppDelegate
                if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                    if UserDefaults.standard.bool(forKey: "sound") && UserDefaults.standard.bool(forKey: "shake") {
                        AudioServicesPlayAlertSound(app.soundID)
                        return
                    }else if UserDefaults.standard.bool(forKey: "sound") && !UserDefaults.standard.bool(forKey: "shake") {
                        AudioServicesPlaySystemSound(app.soundID)
                    }else if !UserDefaults.standard.bool(forKey: "sound") && UserDefaults.standard.bool(forKey: "shake") {
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    }
                }
                }
                let msg = EaseSDKHelper.getTextMessage("你加入了群", to: aGroup.groupId, messageType: EMChatTypeGroupChat, messageExt: ["em_recall":true])
                msg?.isRead = true
                msg?.status = EMMessageStatusSucceed
                var err:EMError?
                conversation?.insert(msg, error: &err)
                if err != nil {
                    print(err?.errorDescription)
                }
                    BoXinUtil.getGroupOnlyInfo(groupId: aGroup.groupId) { (b) in
                    if b {
                        DispatchQueue.main.async {
                            self.tableViewDidTriggerHeaderRefresh()
                        }
                        }
                    }
                DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                    BoXinUtil.getGroupMember(groupID: aGroup.groupId, Complite: nil)
                })
            }
        }
    }
    
    func didLeave(_ aGroup: EMGroup!, reason aReason: EMGroupLeaveReason) {
        print(aGroup.groupId)
        DispatchQueue.main.async {
            if let vc = UIViewController.currentViewController() as? ChatViewController {
                if vc.conversation.type == EMConversationTypeGroupChat {
                    if vc.conversation.conversationId == aGroup.groupId {
                        vc.navigationController?.popToRootViewController(animated: true)
                        let alert = UIAlertController(title: nil, message: "你已被移除该群", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                        UIViewController.currentViewController()?.present(alert, animated: false, completion: nil)
                    }
                }
            }
            if let vc = UIViewController.currentViewController() as? GroupInfoViewController {
                if vc.model?.groupId == aGroup.groupId {
                    vc.navigationController?.popToRootViewController(animated: true)
                    let alert = UIAlertController(title: nil, message: "你已被移除该群", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                    alert.modalPresentationStyle = .overFullScreen
                    UIViewController.currentViewController()?.present(alert, animated: false, completion: nil)
                }
            }
            if let vc = UIViewController.currentViewController() as? GroupNoticeViewController {
                if vc.model?.groupId == aGroup.groupId {
                    vc.navigationController?.popToRootViewController(animated: true)
                    let alert = UIAlertController(title: nil, message: "你已被移除该群", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                    UIViewController.currentViewController()?.present(alert, animated: false, completion: nil)
                }
            }
            if let vc = UIViewController.currentViewController() as? TakeOutGroupMemberViewController {
                if vc.model?.groupId == aGroup.groupId {
                    vc.navigationController?.popToRootViewController(animated: true)
                    let alert = UIAlertController(title: nil, message: "你已被移除该群", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                    alert.modalPresentationStyle = .overFullScreen
                    UIViewController.currentViewController()?.present(alert, animated: false, completion: nil)
                }
            }
        }
        EMClient.shared()?.chatManager.deleteConversation(aGroup.groupId, isDeleteMessages: true, completion: { (a, err) in
            if err != nil {
                print(err?.errorDescription)
                self.didLeave(aGroup, reason: aReason)
                return
            }
            QueryFriend.shared.deleteGroup(id: aGroup.groupId)
            QueryFriend.shared.deleteGroupMember(id: aGroup.groupId)
            QueryFriend.shared.deleteFocus(groupId: aGroup.groupId)
            DispatchQueue.main.async {
                self.tableViewDidTriggerHeaderRefresh()
            }
            
        })
    }
    
    func userDidLeave(_ aGroup: EMGroup!, user aUsername: String!) {
        QueryFriend.shared.deleteGroupUser(userId: aUsername, groupId: aGroup.groupId)
        QueryFriend.shared.deleteFocus(userId: aUsername, groupId: aGroup.groupId)
        NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
    }
    
    func friendshipDidRemove(byUser aUsername: String!) {
        DispatchQueue.main.async {
            if let vc = UIViewController.currentViewController() as? ChatViewController {
                if vc.conversation.type == EMConversationTypeChat {
                    if vc.conversation.conversationId == aUsername {
                        vc.navigationController?.popToRootViewController(animated: true)
                        let data = QueryFriend.shared.queryFriend(id: aUsername)
                        UIApplication.shared.keyWindow?.makeToast("你已被\(data?.name ?? "")删除")
                    }
                }
            }
        }
        EMClient.shared()?.chatManager.deleteConversation(aUsername, isDeleteMessages: true, completion: { (a, err) in
            if err != nil {
                print(err?.errorDescription)
                self.friendshipDidRemove(byUser: aUsername)
                return
            }
            BoXinUtil.getFriends({ (a) in
                NotificationCenter.default.post(name: NSNotification.Name("UpdateFriend"), object: nil)
                DispatchQueue.main.async {
                    self.tableViewDidTriggerHeaderRefresh()
                }
            })
        })
    }
    
    func search(keyWord:String) {
        contactData  = nil
        groupData = nil
        if keyWord.isEmpty {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        if contact != nil {
            for con in contact! {
                for c in (con?.data!)! {
                    if (c?.target_user_nickname?.contains(keyWord))! {
                        if contactData == nil {
                            contactData = Array<FriendData>()
                        }
                        contactData?.append(c)
                    }
                    if (c?.id_card?.contains(keyWord))! {
                        if contactData == nil {
                            contactData = Array<FriendData>()
                        }
                        contactData?.append(c)
                    }
                    if (c?.friend_self_name?.contains(keyWord))! {
                        if contactData == nil {
                            contactData = Array<FriendData>()
                        }
                        contactData?.append(c)
                    }
                }
            }
            if "我的收藏".contains(keyWord) {
                if contactData == nil {
                    contactData = Array<FriendData>()
                }
                let f = FriendData()
                f.user_id = "收藏"
                contactData?.append(f)
            }
            if contactData != nil {
                contactData = NSSet(array: contactData!).allObjects as! [FriendData?]
            }
        }
        groupData = nil
        if group != nil {
            for g in group! {
                if g.groupName!.contains(keyWord) {
                    if groupData == nil {
                        groupData = Array<GroupViewModel>()
                    }
                    groupData?.append(g)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
