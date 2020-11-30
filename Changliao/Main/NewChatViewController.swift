////
////  NewChatViewController.swift
////  boxin
////
////  Created by guduzhonglao on 8/24/19.
////  Copyright © 2019 guduzhonglao. All rights reserved.
////
//
//import UIKit
//import Masonry
//
//class NewChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,EMChatToolbarDelegate,EMChatManagerDelegate,EaseChatBarMoreViewDelegate,HXAlbumListViewControllerDelegate,HXCustomCameraViewControllerDelegate,EMLocationViewDelegate {
//
//    var conversation:EMConversation
//    var tableView:ChatTableView?
//    var messageDatasourse:[EMMessage]?
//    var dataArray:[Any]?
//    var messageCountOfPage:Int = 10
//    var timeCellHeight:CGFloat = 30
//    var scrollToBottomWhenAppear = true
//    var isBottom = false
//    var chatToolbar:UIView?{
//        willSet{
//            self.chatToolbar?.removeFromSuperview()
//            self.chatToolbar?.removeObserver(self, forKeyPath: "isTextViewInputEnd")
//        }
//        didSet{
//            var tableFrame = tableView!.frame
//            tableFrame.size.height = self.view.bounds.height - (self.chatToolbar?.frame.height ?? EaseChatToolbar.defaultHeight()) - (UIScreen.main.bounds.height >= 812 ? 34 : 0)
//            tableView?.frame = tableFrame
//            if let chat = self.chatToolbar as? EaseChatToolbar {
//                chat.delegate = self
//                chat.addObserver(self, forKeyPath: "isTextViewInputEnd", options: .new, context: nil)
//                chatBarMoreView = chat.moreView as? EaseChatBarMoreView
//                faceView = chat.faceView as? EaseFaceView
//                recordView = chat.recordView as? EaseRecordView
//                chatBarMoreView?.delegate = self
//            }
//        }
//    }
//    var chatBarMoreView:EaseChatBarMoreView?
//    var faceView:EaseFaceView?
//    var recordView:EaseRecordView?
//    var menuIndexPath:NSIndexPath?
//    var muteBar:MuteView?
//    var groupModel:GroupViewModel?
//    var me:GroupMemberData?
//    var groupMember:GroupMemberData?
//    var friend:FriendData?
//    var isFriend:Bool = true
//    var isNeedDump:Bool = false
//    var focusList:[String]?
//    var focusTabview:UITableView?
//    var focusDataModel:ChatFocusModel?
//    var focusView:UIView?
//    var focusViewLines:UIView?
//    var focusTableLines:UIView?
//    var focusNameLabel:UILabel?
//    var focusMessageLabel:UILabel?
//    var showButton:UIButton?
//    var hideButton:UIButton?
//    var atList:[GroupAtModel?]?
//    var isAtAll:Bool = false
//    var atAllStart:Int = -1
//    var isFirst:Bool = true
//    var focusHiden:Bool = true
//    var isloading:Bool = false
//    let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
//    var groupSend:Bool = false
//    var focusCellClick = false
//    var groupInputList:[String] = Array<String>()
//    var recivedMessages:[Any]?
//    var isShow:Bool = false {
//        didSet{
//            self.messageQueue.async {
//                let normalMessage = self.messageDatasourse?.filter({ (m) -> Bool in
//                    if m.body.type == EMMessageBodyTypeCmd {
//                        return false
//                    }
//                    return true
//                })
//                self.sendHasReadMessage(message: normalMessage ?? [])
//            }
//        }
//    }
//    var isDownLoading:Bool = false
//    var isNeedPopToRoot:Bool = false
//    var messageQueue = DispatchQueue(label: "changliao.updateChat")
//    var loadedNormalMessageCout:Int?
//    var isRecording = false
//
//    init(conversationChatter:String,chatType:EMConversationType) {
//        conversation = EMClient.shared()!.chatManager.getConversation(conversationChatter, type: chatType, createIfNotExist: true)
//        super.init(nibName: nil, bundle: nil)
//        tableView = ChatTableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.bounds.height - EaseChatToolbar.defaultHeight() - (UIScreen.main.bounds.height >= 812 ? 34 : 0)), style: .plain)
//        tableView?.mj_header = ChatRefhreshHeader(refreshingTarget: self, refreshingAction: #selector(tableRefresh))
//        self.view.addSubview(tableView!)
//        var err:EMError?
//        conversation.markAllMessages(asRead: &err)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    override func loadView() {
//        DispatchQueue.global().async {
//            let faces = QueryFriend.shared.GetAllFace()
//            for f in faces {
//                if SDImageCache.shared.imageFromMemoryCache(forKey: f.url) == nil {
//                    if let image = SDImageCache.shared.imageFromMemoryCache(forKey: f.url) {
//                        SDImageCache.shared.storeImage(toMemory: image, forKey: f.url)
//                    }else{
//                        SDWebImageDownloader.shared.downloadImage(with: URL(string: f.url ?? ""), options: .allowInvalidSSLCertificates, progress: nil, completed: { (image, data, e, fanish) in
//                            if fanish {
//                                SDImageCache.shared.storeImage(toMemory: image, forKey: f.url)
//                            }
//                        })
//                    }
//                }
//            }
//        }
//        super.loadView()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        tableView?.dataSource = self
//        tableView?.delegate = self
//        tableView?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
//        chatToolbar = EaseChatToolbar(frame: CGRect(x: 0, y: tableView?.bounds.height ?? 0, width: UIScreen.main.bounds.width, height: EaseChatToolbar.defaultHeight()), type: conversation.type == EMConversationTypeChat ? EMChatToolbarTypeChat : EMChatToolbarTypeGroup)
//        tableView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
//        chatBarMoreView?.insertItem(with: UIImage(named: "文件"), highlightedImage: UIImage(named: "文件"), title: "文件")
//        EMClient.shared()?.chatManager.add(self, delegateQueue: messageQueue)
//        messageCountOfPage = 100
//        tableView?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
//        NotificationCenter.default.addObserver(self, selector: #selector(onEmojiChanged), name: Notification.Name("onEmojiChanged"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onHideMenu), name: UIMenuController.didHideMenuNotification, object: nil)
//        if !groupSend {
//            //            let bar = chatToolbar as! EaseChatToolbar
//            //            bar.inputTextView.addta
//        }
//        NotificationCenter.default.addObserver(forName: Notification.Name("popViewController"), object: nil, queue: nil) { (no) in
//            if no.object as? UIViewController === self {
//                EMClient.shared()?.chatManager.remove(self)
//            }
//        }
//
//        if conversation.type == EMConversationTypeChat {
//            if groupSend {
//                return
//            }
//            initData()
//            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateCall"), object: nil, queue: OperationQueue.main) { (n) in
//                let message = n.object as! EMMessage
//                self.messageDatasourse?.append(message)
//                if let last = self.dataArray?.last as? MessageViewModel{
//                    if let lastmsg = last.messageList?.last {
//                        if last.senderID == message.from {
//                            if message.localTime - lastmsg.message.localTime > 60 * 1000 {
//                                self.dataArray?.append(self.getLastTime(message: message))
//                                let model = MessageViewModel()
//                                model.senderID = message.from
//                                model.messageList = [self.modelForMessage(message: message)]
//                                self.dataArray?.append(model)
//                            }else{
//                                last.messageList?.append(self.modelForMessage(message: message))
//                            }
//                        }else{
//                            self.dataArray?.append(self.getLastTime(message: message))
//                            let model = MessageViewModel()
//                            model.senderID = message.from
//                            model.messageList = [self.modelForMessage(message: message)]
//                            self.dataArray?.append(model)
//                        }
//                    }
//                }
//                DispatchQueue.main.async {
//                    self.tableView?.reloadData()
//                }
//                DispatchQueue.main.async {
//                    if self.isBottom {
//                        self.tableView?.scrollToRow(at: IndexPath(row: (self.dataArray?.count ?? 1) - 1, section: 0), at: .bottom, animated: false)
//                    }
//                }
//            }
//        }
//        if conversation.type == EMConversationTypeGroupChat {
//            NotificationCenter.default.addObserver(self, selector: #selector(onUpdate), name: Notification.Name("UpdateGroup"), object: nil)
//            NotificationCenter.default.addObserver(self, selector: #selector(updateFocus), name: Notification.Name("UpdateFocus"), object: nil)
//            DispatchQueue.global().async {
//                self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
//            }
//            groupModel = QueryFriend.shared.queryGroup(id: conversation.conversationId)
//            if groupModel?.is_all_banned == 1 && groupModel?.is_admin == 2 && groupModel?.is_menager == 2 {
//                self.chatToolbar?.isHidden = true
//                self.muteBar = MuteView(frame: self.chatToolbar!.frame)
//                self.view.addSubview(self.muteBar!)
//                self.muteBar?.mas_makeConstraints({ (make) in
//                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
//                    make?.top.equalTo()(self.tableView?.mas_bottom)
//                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
//                    make?.bottom.equalTo()(self.view.mas_bottom)
//                })
//            }
//            if groupModel?.is_admin == 2 && groupModel?.is_menager == 2 {
//                let bar = chatToolbar as! EaseChatToolbar
//                bar.inputViewLeftItems.removeAll()
//            }
//            if groupModel?.is_admin == 1 {
//                chatBarMoreView?.insertItem(with: UIImage(named: "抖一抖"), highlightedImage: UIImage(named: "抖一抖"), title: "抖一抖")
//            }
//            chatBarMoreView?.removeItematIndex(4)
//            chatBarMoreView?.removeItematIndex(3)
//        }
//        if conversation.type == EMConversationTypeChat
//        {
//            if isFriend == true
//            {
//                chatBarMoreView?.insertItem(with: UIImage(named: "抖一抖"), highlightedImage: UIImage(named: "抖一抖"), title: "抖一抖")
//            }
//        }
//
//        isShow = true
//        if conversation.type == EMConversationTypeChat {
//            if conversation.conversationId != "ef1569ada7ab4c528375994e0de246ca" && conversation.conversationId != "2290120c5be7424082216dc8d98179a4" {
//                let more = UIBarButtonItem(image: UIImage(named: "圆点菜单"), style: .plain, target: self, action: #selector(onPersonMore))
//                self.navigationItem.rightBarButtonItem = more
//            }
//            (chatToolbar as? EaseChatToolbar)?.addObserver(self, forKeyPath: "isTextViewInputEnd", options: .new, context: nil)
//        }
//        if conversation.type == EMConversationTypeGroupChat {
//            let more = UIBarButtonItem(image: UIImage(named: "圆点菜单"), style: .plain, target: self, action: #selector(onMore))
//            self.navigationItem.rightBarButtonItem = more
//            groupModel = QueryFriend.shared.queryGroup(id: conversation.conversationId)
//            DispatchQueue.global().async {
//                if let focus = QueryFriend.shared.queryFocus(id: self.data!.db!.user_id!, groupId: self.conversation.conversationId) {
//                    self.focusList = focus
//                    if self.focusList != nil {
//                        self.setupFocusView(focusList: self.focusList!)
//                    }
//                }
//                ///自动收齐关注列表
//                if self.isFirst {
//                    self.isFirst = false
//                    self.updateFocus()
//                }
//            }
//        }
//        self.navigationItem.title = self.title
//        isShow = true
//        tableRefresh()
//    }
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "contentOffset" {
//            if let table = object as? ChatTableView {
//                let offset = table.contentOffset.y
//                let size = table.contentSize.height
//                if size - offset < table.frame.size.height + 400 {
//                    isBottom = true
//                }else{
//                    isBottom = false
//                }
//            }
//        }
//        if keyPath == "isTextViewInputEnd" {
//            if object is EaseChatToolbar {
//                if change?[.newKey] as? Bool ?? false {
//                    let body = EMCmdMessageBody(action: "TypingEnd")
//                    body?.isDeliverOnlineOnly = true
//                    let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                    EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                    }, completion: { (m, e) in
//
//                    })
//                }
//            }
//        }
//    }
//
//    override func currentViewControllerShouldPop() -> Bool {
//        if isNeedPopToRoot {
//            self.navigationController?.popToRootViewController(animated: false)
//            return false
//        }
//        return true
//    }
//
//    @objc func onHideMenu() {
//        if recivedMessages != nil {
//            self.messagesDidReceive(recivedMessages!)
//            recivedMessages = nil
//        }
//    }
//
//    @objc func onGroupUpdate(noti:Notification) {
//        groupModel = QueryFriend.shared.queryGroup(id: conversation.conversationId)
//        self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
//        if groupModel?.is_all_banned == 1 {
//            ChangeMuteble(mute: true)
//        }
//        if groupModel?.is_all_banned == 2 {
//            ChangeMuteble(mute: false)
//        }
//    }
//
//    @objc func updateFocus() {
//        if self.focusView != nil{
//            DispatchQueue.main.async {
//                self.focusView?.removeFromSuperview()
//                self.focusTabview?.removeFromSuperview()
//                self.focusView = nil
//                self.focusTabview = nil
//            }
//            self.focusDataModel?.messageDatasource.removeAll()
//            self.focusDataModel?.dataArray.removeAll()
//            self.focusDataModel = nil
//            if let focus = QueryFriend.shared.queryFocus(id: self.data!.db!.user_id!, groupId: self.conversation.conversationId) {
//                self.focusList = focus
//                if self.focusList != nil {
//                    self.setupFocusView(focusList: self.focusList!)
//                }
//            }
//        }else{
//            if let focus = QueryFriend.shared.queryFocus(id: self.data!.db!.user_id!, groupId: self.conversation.conversationId) {
//                self.focusList = focus
//                if self.focusList != nil {
//                    self.setupFocusView(focusList: self.focusList!)
//                }
//            }
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        UIViewController.currentViewController()?.navigationController?.setNavigationBarHidden(false, animated: false)
//        EMCDDeviceManager.sharedInstance()?.stopPlaying()
//
//        if !groupSend {
//            if conversation.type == EMConversationTypeChat {
//                let body = EMCmdMessageBody(action: "TypingEnd")
//                body?.isDeliverOnlineOnly = true
//                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                }, completion: { (m, e) in
//
//                })
//            }
//            if conversation.type == EMConversationTypeGroupChat {
//                let body = EMCmdMessageBody(action: "TypingEnd")
//                body?.isDeliverOnlineOnly = true
//                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                message?.chatType = EMChatTypeGroupChat
//                EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                }, completion: { (m, e) in
//
//                })
//            }
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        var needUpdate = false
//        if !isShow {
//            needUpdate = true
//        }
//        isShow = true
//        if needUpdate {
//            messageQueue.async {
//                self.updateNeedRead()
//            }
//        }
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        isShow = false
//        SVProgressHUD.dismiss()
//    }
//
//    func DidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//
//    @objc private func onMore() {
//        if isloading {
//            return
//        }
//        isloading = true
//        SVProgressHUD.show()
//        BoXinUtil.getGroupOnlyInfo(groupId: conversation.conversationId) { (b) in
//            SVProgressHUD.dismiss()
//            if b {
//                DispatchQueue.main.async {
//                    self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
//                }
//                let vc = GroupInfoViewController()
//                vc.groupId = self.conversation.conversationId
//                vc.model = QueryFriend.shared.queryGroup(id: self.conversation.conversationId)
//                vc.data = QueryFriend.shared.getGroupMembers(groupId: self.conversation.conversationId)
//                if self.me == nil {
//                    self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
//                }
//                vc.me = self.me
//                if vc.data == nil || vc.me == nil {
//                    BoXinUtil.getGroupMember(groupID: self.conversation.conversationId, Complite: { (b) in
//                        if b {
//                            self.isloading = false
//                            vc.model = QueryFriend.shared.queryGroup(id: self.conversation.conversationId)
//                            vc.data = QueryFriend.shared.getGroupMembers(groupId: self.conversation.conversationId)
//                            self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
//                            vc.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
//                            DispatchQueue.main.async {
//                                self.navigationController?.pushViewController(vc, animated: true)
//                            }
//                        }else
//                        {
//                            self.isloading = false
//                        }
//
//                    })
//                    return
//                }
//                self.isloading = false
//                DispatchQueue.main.async {
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }else
//            {
//                self.isloading = false
//            }
//        }
//    }
//
//    @objc private func onPersonMore() {
//        if friend == nil {
//            isNeedDump = true
//            return
//        }
//        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
//
//        if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
//            for c in contact {
//                if c?.data != nil {
//                    for d in c!.data! {
//                        if d?.user_id == conversation.conversationId {
//                            let vc = PersonVc()
//                            let m = FriendDataModel()
//                            m.clCodeNumber = d?.id_card ?? ""
//                            m.nickName = d?.target_user_nickname ?? ""
//                            m.userName = d?.friend_self_name ?? ""
//                            m.iConImage = d?.portrait ?? ""
//                            m.friendId=d?.user_id ?? ""
//                            m.is_Friend = true
//                            if d?.is_star == 1
//                            {
//                                m.is_starFriend = true
//                            }else
//                            {
//                                m.is_starFriend = false
//                            }
//                            vc.model = m
//                            self.navigationController?.pushViewController(vc, animated: true)
//                            return
//                        }
//                    }
//                }
//            }
//        }
//        let dat = QueryFriend.shared.queryStronger(id: conversation.conversationId)
//        if dat != nil {
//            let vc = UserDetailViewController()
//            vc.model = FriendData()
//            vc.model?.user_id = dat?.id
//            vc.model?.target_user_nickname = dat?.name
//            vc.model?.id_card = dat?.id_card
//            vc.model?.portrait = dat?.portrait
//            vc.model?.is_shield = 2
//            vc.model?.is_star = 2
//            vc.type = 0
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//
//    // MARK: - UITableViewDataSource
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataArray?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let model = dataArray?[indexPath.row] as? MessageViewModel {
//            return DIYMessageCell.cellHeight(model: model)
//        }
//        return DCTimeMessageCell.cellForHeight()
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let model = dataArray?[indexPath.row] as? MessageViewModel {
//            var cell = tableView.dequeueReusableCell(withIdentifier: DIYMessageCell.cellID()) as? DIYMessageCell
//            if cell == nil {
//                cell = DIYMessageCell(style: .default, reuseIdentifier: DIYMessageCell.cellID())
//            }
//            cell?.model = model
//            cell?.delegate = self
//            return cell!
//        }
//        var cell = tableView.dequeueReusableCell(withIdentifier: DCTimeMessageCell.cellID()) as? DCTimeMessageCell
//        if cell == nil{
//            cell = DCTimeMessageCell(style: .default, reuseIdentifier: DCTimeMessageCell.cellID())
//        }
//        cell?.timeLabel.text = ((dataArray?[indexPath.row] as? String) ?? "")
//        return cell!
//    }
//
//    /// 消息模型处理
//    ///
//    /// - Parameter message: 消息
//    /// - Returns: 消息模型
//    func modelForMessage(message:EMMessage) -> BoxinMessageModel {
//        let model = BoxinMessageModel(message: message)
//        model?.avatarImage = UIImage(named: "moren")
//        if message.from == "ef1569ada7ab4c528375994e0de246ca" || message.from == "2290120c5be7424082216dc8d98179a4" {
//            model?.avatarImage = UIImage(named: "admin_notice1")
//            model?.nickname = "系统消息"
//            return model!
//        }
//        if model!.isSender {
//            if let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo")){
//                model?.nickname = data.db?.user_name
//                model?.avatarURLPath = data.db?.portrait
//                return model!
//            }
//        }
//        if conversation.type == EMConversationTypeChat {
//            if let data = QueryFriend.shared.queryFriend(id: message.from) {
//                model?.nickname = data.name
//                model?.avatarURLPath = data.portrait
//                return model!
//            }else{
//                let m = GetUserByIDSendModel()
//                m.user_id = message.from
//                BoXinProvider.request(.GetUserByID(model: m)) { (result) in
//                    switch result {
//                    case .success(let res):
//                        if res.statusCode == 200 {
//                            do{
//                                if let mo = GetUserByIDReciveModel.deserialize(from: try res.mapString()) {
//                                    if mo.code == 200 {
//                                        QueryFriend.shared.addStranger(id: mo.data!.user_id!, user_name: mo.data!.user_name!, portrait1: mo.data!.portrait!, card: mo.data!.id_card!)
//                                        model?.nickname = mo.data?.user_name
//                                        model?.avatarURLPath = mo.data?.portrait
//                                    }else{
//                                        if mo.message == "请重新登录" {
//                                            BoXinUtil.Logout()
//                                            if (UIViewController.currentViewController() as? BootViewController) != nil {
//                                                let app = UIApplication.shared.delegate as! AppDelegate
//                                                app.isNeedLogin = true
//                                                return
//                                            }
//                                            if let vc = UIViewController.currentViewController() as? LoginViewController {
//                                                if vc.type == 0 {
//                                                    return
//                                                }
//                                            }
//                                            let sb = UIStoryboard(name: "Main", bundle: nil)
//                                            UIViewController.currentViewController()?.present(sb.instantiateViewController(withIdentifier: "LoginNavigation"), animated: false, completion: nil)
//                                        }
//                                        UIViewController.currentViewController()?.view.makeToast(mo.message)
//                                    }
//                                }else{
//                                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
//                                }
//                            }catch{
//                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
//                            }
//                        }else{
//                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
//                        }
//                    case .failure(let err):
//                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
//                        print(err.errorDescription!)
//                    }
//                }
//                let data = QueryFriend.shared.queryStronger(id: message.from)
//                model?.nickname = data?.name
//                model?.avatarURLPath = data?.portrait
//            }
//        }
//        if conversation.type == EMConversationTypeGroupChat {
//            if let m = QueryFriend.shared.getGroupUser(userId: message.from, groupId: conversation.conversationId) {
//                var text :String? = ""
//                if QueryFriend.shared.checkFriend(userID: m.user_id!) {
//                    if m.friend_name != "" {
//                        text = m.friend_name
//                    }else{
//                        text = m.user_name
//                    }
//                }else{
//                    if m.group_user_nickname != "" {
//                        text = m.group_user_nickname;
//                    }else{
//                        text = m.user_name
//                    }
//                }
//                model?.nickname = text
//                //            model?.nickname = m?.group_user_nickname
//                model?.avatarURLPath = m.portrait
//                model?.member = m
//                return model!
//            }else{
//                let data = QueryFriend.shared.queryStronger(id: message.from)
//                model?.nickname = data?.name
//                model?.avatarURLPath = data?.portrait
//            }
//        }
//        return model!
//    }
//
//    /// 下拉加载方法
//    @objc func tableRefresh() {
//        weak var weakSelf = self
//        conversation.loadMessagesStart(fromId: messageDatasourse?.first?.messageId, count: Int32(messageCountOfPage), searchDirection: EMMessageSearchDirectionUp, completion: { (messages, err) in
//            if err == nil {
//                if messages?.count ?? 0 > 0 {
//                    weakSelf?.messageQueue.async {
//                        let normalMessage = (messages as! [EMMessage]).filter({ (ms) -> Bool in
//                            if ms.body.type == EMMessageBodyTypeCmd {
//                                return false
//                            }
//                            weakSelf?.downloadMessageAttachments(message: ms)
//                            return true
//                        })
//                        let messageData = weakSelf?.generateModel(normalMessage, isAppend: false)
//                        if weakSelf?.messageDatasourse == nil {
//                            weakSelf?.messageDatasourse = messages as? [EMMessage]
//                        }else{
//                            let tepArr = [(messages as! [EMMessage]),weakSelf?.messageDatasourse]
//                            weakSelf?.messageDatasourse = tepArr.flatMap({ (arr) -> Array<EMMessage> in
//                                return arr!
//                            })
//                        }
//                        if weakSelf?.dataArray == nil {
//                            weakSelf?.dataArray = messageData
//                        }else{
//                            let tepArr = [messageData,weakSelf?.dataArray]
//                            weakSelf?.dataArray = tepArr.flatMap({ (arr) -> Array<Any> in
//                                return arr!
//                            })
//                        }
//                        DispatchQueue.main.async {
//                            weakSelf?.tableView?.reloadData()
//                            weakSelf?.tableView?.mj_header.state = .idle
//                        }
//                        DispatchQueue.main.async {
//                            if weakSelf?.isBottom ?? false {
//                                weakSelf?.tableView?.scrollToRow(at: IndexPath(row: (weakSelf?.dataArray?.count ?? 1) - 1, section: 0), at: .top, animated: false)
//                            }
//                        }
//                        weakSelf?.sendHasReadMessage(message: normalMessage)
//                        for m in normalMessage {
//                            weakSelf?.downloadMessageAttachments(message: m)
//                        }
//                        if weakSelf?.loadedNormalMessageCout != nil {
//                            if (weakSelf?.loadedNormalMessageCout ?? 0) + normalMessage.count >= weakSelf?.messageCountOfPage ?? 0 {
//                                weakSelf?.loadedNormalMessageCout = nil
//                            }
//                        }
//                        if normalMessage.count < weakSelf?.messageCountOfPage ?? 0 {
//                            weakSelf?.loadedNormalMessageCout = normalMessage.count
//                            weakSelf?.tableRefresh()
//                        }
//                    }
//                }else{
//                    if let messageDataSource = weakSelf?.messageDatasourse {
//                        let onlineMessages = messageDataSource.filter({ (message) -> Bool in
//                            if message.body.type == EMMessageBodyTypeText {
//                                if message.ext?["em_recall"] as? Bool ?? false {
//                                    return false
//                                }
//                                if message.ext?["callType"] != nil {
//                                    return false
//                                }
//                            }
//                            return true
//                        })
//                        if onlineMessages.count > 0 {
//                            EMClient.shared()?.chatManager.asyncFetchHistoryMessages(fromServer: weakSelf?.conversation.conversationId ?? "", conversationType: weakSelf?.conversation.type ?? EMConversationTypeChat, startMessageId: onlineMessages.first?.messageId, pageSize: Int32(weakSelf?.messageCountOfPage ?? 0), completion: { (resulr, err) in
//                                if err == nil {
//                                    if let severMessages = resulr?.list as? [EMMessage] {
//                                        weakSelf?.messageQueue.async {
//                                            let normalMessage = severMessages.filter({ (ms) -> Bool in
//                                                if ms.body.type == EMMessageBodyTypeCmd {
//                                                    return false
//                                                }
//                                                return true
//                                            })
//                                            let messageData = weakSelf?.generateModel(normalMessage, isAppend: false)
//                                            if weakSelf?.messageDatasourse == nil {
//                                                weakSelf?.messageDatasourse = severMessages
//                                            }else{
//                                                let tepArr = [severMessages,weakSelf?.messageDatasourse]
//                                                weakSelf?.messageDatasourse = tepArr.flatMap({ (arr) -> Array<EMMessage> in
//                                                    return arr!
//                                                })
//                                            }
//                                            if weakSelf?.dataArray == nil {
//                                                weakSelf?.dataArray = messageData
//                                            }else{
//                                                let tepArr = [messageData,weakSelf?.dataArray]
//                                                weakSelf?.dataArray = tepArr.flatMap({ (arr) -> Array<Any> in
//                                                    return arr!
//                                                })
//                                            }
//                                            DispatchQueue.main.async {
//                                                weakSelf?.tableView?.reloadData()
//                                                weakSelf?.tableView?.mj_header.state = .idle
//                                            }
//                                            DispatchQueue.main.async {
//                                                if weakSelf?.isBottom ?? false {
//                                                    weakSelf?.tableView?.scrollToRow(at: IndexPath(row: (weakSelf?.dataArray?.count ?? 1) - 1, section: 0), at: .top, animated: false)
//                                                }
//                                            }
//                                            weakSelf?.sendHasReadMessage(message: normalMessage)
//                                            for m in normalMessage {
//                                                weakSelf?.downloadMessageAttachments(message: m)
//                                            }
//                                            if weakSelf?.loadedNormalMessageCout != nil {
//                                                if (weakSelf?.loadedNormalMessageCout ?? 0) + normalMessage.count >= weakSelf?.messageCountOfPage ?? 0 {
//                                                    weakSelf?.loadedNormalMessageCout = nil
//                                                }
//                                            }
//                                            if normalMessage.count < weakSelf?.messageCountOfPage ?? 0 {
//                                                weakSelf?.loadedNormalMessageCout = normalMessage.count
//                                                weakSelf?.tableRefresh()
//                                            }
//                                        }
//                                    }
//                                }
//                            })
//                        }
//                    }
//                }
//            }
//        })
//    }
//
//    /// 生成消息模型
//    ///
//    /// - Parameter messages: 消息
//    /// - Returns: 消息模型
//    func generateModel(_ messages:[EMMessage], isAppend:Bool) -> [Any] {
//        var arr = Array<Any>()
//        if messages.count > 0 {
//            let nomalMSG =  self.messageDatasourse?.filter({ (m) -> Bool in
//                if m.body.type == EMMessageBodyTypeCmd {
//                    return false
//                }
//                return true
//            })
//            var  data = MessageViewModel()
//            if isAppend {
//                data = dataArray?.last as? MessageViewModel ?? MessageViewModel()
//                if data.senderID == nil {
//                    arr.append(self.getLastTime(message: nomalMSG!.first!))
//                }
//            }else{
//                arr.append(self.getLastTime(message: nomalMSG!.first!))
//            }
//            for msg in nomalMSG! {
//                if data.senderID == msg.from {
//                    if msg.localTime - data.messageList!.last!.message.localTime > 60 * 1000 {
//                        arr.append(data)
//                        data = MessageViewModel()
//                        data.senderID = msg.from
//                        data.messageList = Array<BoxinMessageModel>()
//                        data.messageList?.append(modelForMessage(message: msg))
//                    }else{
//                        data.messageList?.append(modelForMessage(message: msg))
//                    }
//                }else{
//                    if data.senderID != nil {
//                        arr.append(data)
//                    }
//                    data = MessageViewModel()
//                    data.senderID = msg.from
//                    data.messageList = Array<BoxinMessageModel>()
//                    data.messageList?.append(modelForMessage(message: msg))
//                }
//            }
//        }
//    }
//
//    /// 初始化关注列表
//    ///
//    /// - Parameter focusList: 关注人ID
//    func setupFocusView(focusList:[String]) {
//        conversation.loadMessagesStart(fromId: nil, count: 100, searchDirection: EMMessageSearchDirectionUp) { (msg, err) in
//            if msg != nil {
//                var m = (msg as! [EMMessage]).filter({ (mg) -> Bool in
//                    for s in focusList {
//                        if mg.from == s {
//                            return true
//                        }
//                    }
//                    return false
//                })
//                if m.count == 0 {
//                    return
//                }
//                var focusMessages = Array<EMMessage>()
//                m = m.filter({ (ms) -> Bool in
//                    if ms.body.type == EMMessageBodyTypeCmd {
//                        return false
//                    }
//                    focusMessages.append(ms)
//
//                    return true
//                })
//
//                if self.focusDataModel == nil {
//                    self.focusDataModel = ChatFocusModel()
//                    self.focusDataModel?.chat = self
//                }
//
//                self.focusDataModel?.messageDatasource.removeAll()
//                self.focusDataModel?.dataArray.removeAll()
//                for m in stride(from: 0, to: focusMessages.count, by: 1) {
//                    if let ms = self.focusDataModel?.messageDatasource.last as? EMMessage {
//                        if focusMessages[m].localTime - ms.localTime > 60 * 1000 {
//                            self.focusDataModel?.dataArray.append(self.getLastTime(message: focusMessages[m]))
//                        }
//                    }
//                    self.focusDataModel?.messageDatasource.append(focusMessages[m])
//                    self.focusDataModel?.dataArray.append(self.modelForMessage(message: focusMessages[m]))
//                }
//                DispatchQueue.main.async {
//                    if self.focusTabview == nil {
//                        self.focusTabview = UITableView(frame: CGRect(x: 0, y: self.tableView!.frame.minY, width: UIScreen.main.bounds.width, height: 220))
//                        self.view.addSubview(self.focusTabview!)
//                        self.focusTabview?.dataSource = self.focusDataModel
//                        self.focusTabview?.delegate = self.focusDataModel
//                        self.focusTabview?.separatorStyle = .none
//                        self.focusTabview?.isHidden = true
//                        self.hideButton = UIButton(type: .custom)
//                        self.hideButton?.setImage(UIImage(named: "拉起"), for: .normal)
//                        self.hideButton?.setImage(UIImage(named: "拉起"), for: .selected)
//                        self.hideButton?.setImage(UIImage(named: "拉起"), for: .highlighted)
//                        self.hideButton?.setImage(UIImage(named: "拉起"), for: .disabled)
//                        self.hideButton?.addTarget(self, action: #selector(self.onHide), for: .touchUpInside)
//                        self.view.addSubview(self.hideButton!)
//                        self.hideButton?.mas_makeConstraints({ (make) in
//                            make?.right.equalTo()(self.focusTabview?.mas_right)?.offset()(-8)
//                            make?.bottom.equalTo()(self.focusTabview?.mas_bottom)?.offset()(-4)
//                            make?.height.mas_equalTo()(30)
//                            make?.width.mas_equalTo()(30)
//                        })
//                        self.focusTableLines = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
//                        self.focusTableLines?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "d9d9d9")
//                        self.view.addSubview(self.focusTableLines!)
//                        self.focusTableLines?.mas_makeConstraints({ (make) in
//                            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
//                            make?.top.equalTo()(self.focusTabview?.mas_bottom)
//                            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
//                            make?.height.mas_equalTo()(0.5)
//                        })
//                    }
//                    if self.focusView == nil {
//                        self.focusView = UIView(frame: CGRect(x: 0, y: self.tableView!.frame.minY, width: UIScreen.main.bounds.width, height: 50))
//                        self.focusView?.backgroundColor = UIColor.white
//                        self.view.addSubview(self.focusView!)
//                        self.focusMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
//                        self.focusMessageLabel?.font = UIFont.systemFont(ofSize: 13)
//                        self.focusMessageLabel?.textColor = UIColor.gray
//                        self.focusView?.addSubview(self.focusMessageLabel!)
//                        self.showButton = UIButton(type: .custom)
//                        self.showButton?.setImage(UIImage(named: "show_down"), for: .normal)
//                        self.showButton?.setImage(UIImage(named: "show_down"), for: .selected)
//                        self.showButton?.setImage(UIImage(named: "show_down"), for: .highlighted)
//                        self.showButton?.setImage(UIImage(named: "show_down"), for: .disabled)
//                        self.showButton?.addTarget(self, action: #selector(self.onShow), for: .touchUpInside)
//                        self.focusView?.addSubview(self.showButton!)
//                        self.showButton?.mas_makeConstraints({ (make) in
//                            make?.right.equalTo()(self.focusView?.mas_right)?.offset()(-8)
//                            make?.height.mas_equalTo()(30)
//                            make?.width.mas_equalTo()(30)
//                            make?.bottom.equalTo()(self.focusView?.mas_bottom)?.offset()(-4)
//                        })
//                        self.focusMessageLabel?.mas_makeConstraints({ (make) in
//                            make?.left.equalTo()(self.focusView?.mas_left)?.offset()(16)
//                            make?.centerY.equalTo()(self.focusView?.mas_centerY)
//                            make?.right.mas_lessThanOrEqualTo()(self.showButton?.mas_left)?.offset()(-4)
//                        })
//                        self.focusViewLines = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
//                        self.focusViewLines?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "d9d9d9")
//                        self.view.addSubview(self.focusViewLines!)
//                        self.focusViewLines?.mas_makeConstraints({ (make) in
//                            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
//                            make?.top.equalTo()(self.focusView?.mas_bottom)
//                            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
//                            make?.height.mas_equalTo()(0.5)
//                        })
//                    }
//                    if focusMessages.count == 0 {
//                        return
//                    }
//                    if self.focusHiden {
//                        self.focusTabview?.isHidden = true
//                        self.hideButton?.isHidden = true
//                        self.focusTableLines?.isHidden = true
//                        self.focusView?.isHidden = false
//                        self.showButton?.isHidden = false
//                        self.focusViewLines?.isHidden = false
//                    }else{
//                        self.focusTabview?.isHidden = false
//                        self.hideButton?.isHidden = false
//                        self.focusTableLines?.isHidden = false
//                        self.focusView?.isHidden = true
//                        self.showButton?.isHidden = true
//                        self.focusViewLines?.isHidden = true
//                    }
//                    self.focusTabview?.reloadData()
//                    let msg = focusMessages[focusMessages.count - 1]
//                    let da = QueryFriend.shared.getGroupUser(userId: msg.from, groupId: msg.conversationId)
//                    var text:String? = ""
//                    if da == nil {
//                        return
//                    }
//                    if da?.user_id == nil {
//                        return
//                    }
//                    if QueryFriend.shared.checkFriend(userID: da!.user_id!) {
//                        if da?.friend_name != "" {
//                            text = da?.friend_name
//                        }else{
//                            text = da?.user_name
//                        }
//                    }else{
//                        if da?.group_user_nickname != "" {
//                            text = da?.group_user_nickname;
//                        }else{
//                            text = da?.user_name
//                        }
//                    }
//                    self.focusMessageLabel?.text = String(format: "[关注]%@: %@", (text ??  ""),self.getMSGtext(message: msg))
//                }
//            }
//            if self.focusDataModel!.dataArray.count > 3 {
//                if self.focusDataModel?.currentIsInBottom == true
//                {
//                    DispatchQueue.main.async {
//                        self.focusTabview?.scrollToRow(at: IndexPath(row: self.focusDataModel!.dataArray.count - 1, section: 0), at: .top, animated: true)
//                    }
//                }
//            }
//        }
//    }
//
//    /// 关注短消息展示
//    ///
//    /// - Parameter message: 已关注人发的消息
//    /// - Returns: 消息展示
//    func getMSGtext(message:EMMessage) -> String {
//        let lastMsg = message.body
//        var text:String = ""
//        switch lastMsg?.type {
//        case EMMessageBodyTypeImage:
//            text = "[图片]"
//        case EMMessageBodyTypeText:
//            var msg = lastMsg as! EMTextMessageBody
//            if msg.text.hasSuffix("_encode") {
//                var messagetext = String(msg.text.split(separator: "_")[0].utf8)
//                if messagetext != nil {
//                    messagetext = DCEncrypt.Decode_AES(strToDecode: messagetext!)
//                }
//                if messagetext != nil {
//                    msg = EMTextMessageBody(text: messagetext!)
//                }
//            }
//            text = EaseConvertToCommonEmoticonsHelper.convert(toSystemEmoticons: msg.text)
//            if message.ext != nil {
//                if message.ext["em_is_big_expression"] != nil {
//                    text = "[动画表情]"
//                }
//                if message.ext["type"] as? String == "person" {
//                    text = "[分享名片]"
//                }
//            }
//        case EMMessageBodyTypeVoice:
//            text = "[语音]"
//        case EMMessageBodyTypeVideo:
//            text = "[视频]"
//        case EMMessageBodyTypeLocation:
//            text = "[位置]"
//        case EMMessageBodyTypeFile:
//            text = "[文件]"
//        default:
//            break
//        }
//        return text
//    }
//
//    /// 显示关注消息列表
//    @objc func onShow() {
//        self.focusTabview?.isHidden = false
//        self.hideButton?.isHidden = false
//        self.focusTableLines?.isHidden = false
//        self.focusView?.isHidden = true
//        self.showButton?.isHidden = true
//        self.focusViewLines?.isHidden = true
//        if focusTabview == nil {
//            return
//        }
//        focusTabview?.reloadData()
//        DispatchQueue.main.async {
//            self.focusTabview?.reloadData()
//        }
//        if focusDataModel!.dataArray.count == 0 {
//            return
//        }
//        DispatchQueue.main.async {
//            self.focusTabview?.scrollToRow(at: IndexPath(row: self.focusDataModel!.dataArray.count - 1, section: 0), at: .bottom, animated: false)
//        }
//    }
//
//    /// 隐藏关注消息列表
//    @objc func onHide() {
//        self.focusTabview?.isHidden = true
//        self.hideButton?.isHidden = true
//        self.focusTableLines?.isHidden = true
//        self.focusView?.isHidden = false
//        self.showButton?.isHidden = false
//        self.focusViewLines?.isHidden = false
//    }
//
//    /// 全体禁言设置
//    ///
//    /// - Parameter mute: 全体禁言状态
//    func ChangeMuteble(mute:Bool) {
//        if groupModel?.is_admin == 1 || groupModel?.is_menager == 1 {
//            DispatchQueue.main.async {
//                let chatbar =  self.chatToolbar as! EaseChatToolbar
//                chatbar.showVoiceStyleButton(true)
//                if self.muteBar != nil {
//                    for v in self.muteBar!.subviews {
//                        v.removeFromSuperview()
//                    }
//                    self.muteBar?.removeFromSuperview()
//                }
//                self.muteBar = nil
//                if self.chatToolbar != nil {
//                    self.chatToolbar?.endEditing(true)
//                    self.chatToolbar?.isHidden = false
//                }
//            }
//            return
//        }
//        let chatbar =  self.chatToolbar as! EaseChatToolbar
//        chatbar.showVoiceStyleButton(false)
//        if mute {
//            if muteBar != nil {
//                return
//            }
//            if chatToolbar != nil {
//                chatToolbar?.endEditing(true)
//                chatToolbar?.isHidden = true
//                muteBar = MuteView(frame: chatToolbar!.frame)
//            }else{
//                muteBar = MuteView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
//            }
//            self.view.addSubview(muteBar!)
//            DispatchQueue.main.async {
//                if self.chatToolbar != nil {
//                    self.chatToolbar?.endEditing(true)
//                }
//                self.tableView!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - EaseChatToolbar.defaultHeight() - (UIScreen.main.bounds.height >= 812 ? 34 : 0))
//                self.muteBar?.mas_makeConstraints({ (make) in
//                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
//                    make?.top.equalTo()(self.tableView?.mas_bottom)
//                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
//                    make?.bottom.equalTo()(self.view.mas_bottom)
//                })
//            }
//        }else{
//            DispatchQueue.main.async {
//                if self.muteBar != nil {
//                    for v in self.muteBar!.subviews {
//                        v.removeFromSuperview()
//                    }
//                    self.muteBar?.removeFromSuperview()
//                }
//                self.muteBar = nil
//                if self.chatToolbar != nil {
//                    self.chatToolbar?.endEditing(true)
//                    self.chatToolbar?.isHidden = false
//                }
//            }
//        }
//    }
//
//    /// 初始化个人聊天页数据
//    func initData() {
//        DispatchQueue.global().async {
//            if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
//                for c in contact {
//                    if c != nil && c?.data != nil {
//                        for co in c!.data! {
//                            if co?.user_id == self.conversation.conversationId {
//                                self.friend = co
//                                self.isFriend = true
//                                if self.isNeedDump {
//                                    DispatchQueue.main.async {
//                                        let vc = UserDetailViewController()
//                                        vc.model = self.friend
//                                        vc.type = 1
//                                        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
//                                        self.navigationController?.pushViewController(vc, animated: true)
//                                    }
//                                }
//                                return
//                            }
//                        }
//                    }
//                }
//            }
//            self.isFriend = false
//            let model = GetUserByIDSendModel()
//            model.user_id = self.conversation.conversationId
//            BoXinProvider.request(.GetUserByID(model: model)) { (result) in
//                switch result {
//                case .success(let res):
//                    if res.statusCode == 200 {
//                        do{
//                            if let md = GetUserByIDReciveModel.deserialize(from: try res.mapString()) {
//                                if md.code == 200 {
//                                    self.friend = FriendData(data: md.data)
//                                    if self.isNeedDump {
//                                        DispatchQueue.main.async {
//                                            let vc = UserDetailViewController()
//                                            vc.model = self.friend
//                                            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
//                                            self.navigationController?.pushViewController(vc, animated: true)
//                                        }
//                                    }
//                                }else{
//                                    if md.message == "请重新登录" {
//                                        DispatchQueue.main.async {
//                                            BoXinUtil.Logout()
//                                            if (UIViewController.currentViewController() as? BootViewController) != nil {
//                                                let app = UIApplication.shared.delegate as! AppDelegate
//                                                app.isNeedLogin = true
//                                                return
//                                            }
//                                            if let vc = UIViewController.currentViewController() as? LoginViewController {
//                                                if vc.type == 0 {
//                                                    return
//                                                }
//                                            }
//                                            let sb = UIStoryboard(name: "Main", bundle: nil)
//                                            self.present(sb.instantiateViewController(withIdentifier: "LoginNavigation"), animated: false, completion: nil)
//                                        }
//                                    }
//                                    self.view.makeToast(md.message)
//                                }
//                            }else{
//                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
//                            }
//                        }catch{
//                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
//                        }
//                    }else{
//                        print(res.statusCode)
//                    }
//                case .failure(let err):
//                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
//                    print(err.errorDescription)
//                }
//            }
//        }
//    }
//
//    /// 群权限变更
//    @objc func onUpdate() {
//        me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
//        groupModel = QueryFriend.shared.queryGroup(id: conversation.conversationId)
//        if groupModel?.is_all_banned == 1 {
//            ChangeMuteble(mute: true)
//        }
//        if groupModel?.is_all_banned == 2 {
//            ChangeMuteble(mute: false)
//        }
//    }
//
//    /// 表情变动通知
//    @objc func onEmojiChanged() {
//        setupEmotion()
//    }
//
//    /// 获取消息时间
//    ///
//    /// - Parameter message: 消息
//    /// - Returns: 消息时间
//    func getLastTime(message:EMMessage) -> String {
//        return (NSDate(timeIntervalInMilliSecondSince1970: Double(message.localTime))?.formattedTime())!
//    }
//
//    func sendHasReadMessage(message:[EMMessage]) {
//        if conversation.type == EMConversationTypeGroupChat {
//            return
//        }
//        for m in message {
//            if (m.body.type != EMMessageBodyTypeVoice) || (m.body.type != EMMessageBodyTypeVideo) || (m.body.type != EMMessageBodyTypeImage) {
//                EMClient.shared()?.chatManager.sendMessageReadAck(m, completion: nil)
//            }
//        }
//    }
//
//    func updateNeedRead() {
//        let normalMSG = messageDatasourse?.filter({ (m) -> Bool in
//            if m.body.type == EMMessageBodyTypeCmd {
//                return false
//            }
//            return true
//        })
//        if (normalMSG?.count ?? 0) == 0 {
//            return
//        }
//        sendHasReadMessage(message: normalMSG!)
//    }
//
//    /// 刷新消息
//    ///
//    /// - Parameter message: 要刷新的消息
//    func reloadMessaage(message:EMMessage) {
//        if let data = dataArray {
//            for (index, obj) in data.enumerated() {
//                if let model = obj as? MessageViewModel {
//                    for (idx,msg) in model.messageList!.enumerated() {
//                        if message.messageId == msg.messageId {
//                            model.messageList![idx] = modelForMessage(message: message)
//                            DispatchQueue.main.async {
//                                self.tableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    /// 自定义视频缩略图下载
//    ///
//    /// - Parameter aMessage: 视频消息
//    func customDownloadVedioFile(_ aMessage: EMMessage!) {
//        if let body = aMessage.body as? EMVideoMessageBody {
//            if body.thumbnailLocalPath != nil && FileManager.default.fileExists(atPath: body.thumbnailLocalPath) {
//                body.thumbnailDownloadStatus = EMDownloadStatusSucceed
//                aMessage.body = body
//                reloadMessaage(message: aMessage)
//            }
//            if body.thumbnailRemotePath == nil {
//                return
//            }
//            let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
//            var dic = path[path.endIndex - 1]
//            dic.appendPathComponent("VedioTemp", isDirectory: true)
//            dic.appendPathComponent(((body.thumbnailRemotePath ?? "temp") as NSString).lastPathComponent, isDirectory: false)
//            BoXinProvider.request(.DownLoad(url: body.thumbnailRemotePath, filepath: dic.path)) { (_) in
//                if FileManager.default.fileExists(atPath: dic.path) {
//                    body.thumbnailLocalPath = dic.path
//                    body.thumbnailDownloadStatus = EMDownloadStatusSucceed
//                    aMessage.body = body
//                    self.reloadMessaage(message: aMessage)
//                }
//            }
//        }
//    }
//
//    /// 下载消息附件
//    ///
//    /// - Parameter message: 消息
//    func downloadMessageAttachments(message:EMMessage) {
//        weak var weakSelf = self
//        if message.body.type == EMMessageBodyTypeImage {
//            let body = message.body as! EMImageMessageBody
//            if body.thumbnailDownloadStatus.rawValue > EMDownloadStatusSucceed.rawValue || !FileManager.default.fileExists(atPath: body.thumbnailLocalPath) {
//                EMClient.shared()?.chatManager.downloadMessageThumbnail(message, progress: { (p) in
//
//                }, completion: { (msg, err) in
//                    if err != nil {
//                        DispatchQueue.main.async {
//                            UIApplication.shared.keyWindow?.makeToast("获取缩略图失败")
//                        }
//                    }else{
//                        weakSelf?.reloadMessaage(message: msg!)
//                    }
//                })
//            }
//        }
//        if message.body.type == EMMessageBodyTypeVideo {
//            let body = message.body as! EMVideoMessageBody
//            if body.thumbnailDownloadStatus.rawValue > EMDownloadStatusSucceed.rawValue || !FileManager.default.fileExists(atPath: body.thumbnailLocalPath) {
//                if body.remotePath.hasPrefix("http://hgjt-oss") {
//                    weakSelf?.customDownloadVedioFile(message)
//                }else{
//                    EMClient.shared()?.chatManager.downloadMessageThumbnail(message, progress: { (p) in
//
//                    }, completion: { (msg, err) in
//                        if err != nil {
//                            DispatchQueue.main.async {
//                                UIApplication.shared.keyWindow?.makeToast("获取缩略图失败")
//                            }
//                        }else{
//                            weakSelf?.reloadMessaage(message: msg!)
//                        }
//                    })
//                }
//            }
//        }
//        if message.body.type == EMMessageBodyTypeVoice {
//            let body = message.body as! EMVoiceMessageBody
//            if body.downloadStatus.rawValue > EMDownloadStatusSucceed.rawValue || !FileManager.default.fileExists(atPath: body.localPath) {
//                EMClient.shared()?.chatManager.downloadMessageThumbnail(message, progress: { (p) in
//
//                }, completion: { (msg, err) in
//                    if err != nil {
//                        DispatchQueue.main.async {
//                            UIApplication.shared.keyWindow?.makeToast("获取缩略图失败")
//                        }
//                    }else{
//                        weakSelf?.reloadMessaage(message: msg!)
//                    }
//                })
//            }
//        }
//    }
//
//    // MAARK: - EMChatManagerDelegate
//    func messagesDidReceive(_ aMessages: [Any]!) {
//        if UIMenuController.shared.isMenuVisible {
//            if recivedMessages == nil {
//                recivedMessages = aMessages
//            }else{
//                for m in aMessages {
//                    recivedMessages?.append(m)
//                }
//            }
//            return
//        }
//        for msg in (aMessages as! [EMMessage]) {
//            downloadMessageAttachments(message: msg)
//        }
//        if focusList != nil {
//            if focusDataModel == nil {
//                return
//            }
//            var focusMessages = (aMessages as! [EMMessage]).filter { (m) -> Bool in
//                if m.conversationId == self.conversation.conversationId {
//                    for f in focusList! {
//                        if f == m.from {
//                            if focusDataModel == nil {
//                                return true
//                            }
//                            for ms in focusDataModel!.messageDatasource {
//                                let n = ms as! EMMessage
//                                if n.messageId == m.messageId {
//                                    return false
//                                }
//                            }
//                            return true
//                        }
//                    }
//                }
//                return false
//            }
//            focusMessages = focusMessages.filter({ (m) -> Bool in
//                if m.body.type == EMMessageBodyTypeCmd {
//                    return false
//                }
//                return true
//            })
//            if focusMessages.count > 0 {
//                if focusView == nil {
//                    self.setupFocusView(focusList: focusList!)
//                    return
//                }
//                let msgs = focusMessages.map { (m) -> IMessageModel in
//                    return self.modelForMessage(message: m)
//                }
//                for m in focusMessages {
//                    var ishave = false
//                    for mg in self.focusDataModel!.messageDatasource as! [EMMessage] {
//                        if mg.messageId == m.messageId {
//                            ishave = true
//                            break
//                        }
//                    }
//                    if !ishave {
//                        self.focusDataModel?.messageDatasource.append(m)
//                    }
//                }
//                for m in msgs {
//                    var ishave = false
//                    for mg in self.focusDataModel!.dataArray as! [BoxinMessageModel] {
//                        if mg.messageId == m.messageId {
//                            ishave = true
//                            break
//                        }
//                    }
//                    if !ishave {
//                        self.focusDataModel?.dataArray.append(m)
//                    }
//                }
//                self.focusDataModel?.messageDatasource = self.focusDataModel!.messageDatasource.sorted(by: { (a1, a2) -> Bool in
//                    let m1 = a1 as? EMMessage
//                    if m1 == nil {
//                        return false
//                    }
//                    let m2 = a2 as? EMMessage
//                    if m2 == nil {
//                        return true
//                    }
//                    return m1!.localTime < m2!.localTime
//                })
//                self.focusDataModel?.dataArray = self.focusDataModel!.dataArray.sorted(by: { (a1, a2) -> Bool in
//                    let b1 = a1 as? BoxinMessageModel
//                    let b2 = a2 as? BoxinMessageModel
//                    if b1 == nil {
//                        return true
//                    }
//                    if b2 == nil {
//                        return false
//                    }
//                    return b1!.message.localTime < b2!.message.localTime
//
//                })
//                DispatchQueue.main.async {
//                    self.focusTabview?.reloadData()
//                    self.focusTabview?.scrollToRow(at: IndexPath(row: self.focusDataModel!.dataArray.count - 1, section: 0), at: .bottom, animated: false)
//                    let m = self.focusDataModel?.dataArray[self.focusDataModel!.dataArray.count - 1] as! BoxinMessageModel
//                    let da = QueryFriend.shared.getGroupUser(userId: m.message.from, groupId: m.message.conversationId)
//                    if da == nil {
//                        return
//                    }
//                    var text :String? = ""
//                    if QueryFriend.shared.checkFriend(userID: da!.user_id!) {
//                        if da?.friend_name != "" {
//                            text = da?.friend_name
//                        }else{
//                            text = da?.user_name
//                        }
//                    }else{
//                        if da?.group_user_nickname != "" {
//                            text = da?.group_user_nickname;
//                        }else{
//                            text = da?.user_name
//                        }
//                    }
//                    self.focusMessageLabel?.text = String(format: "[关注]%@: %@", (text ??  ""),self.getMSGtext(message: m.message))
//                }
//            }
//        }
//    }
//
//    func cmdMessagesDidReceive(_ aCmdMessages: [Any]!) {
//        for cmd in aCmdMessages as! [EMMessage] {
//            if cmd.conversationId == conversation.conversationId {
//                let cmdbody = cmd.body as! EMCmdMessageBody
//                //                if conversation.type == EMConversationTypeGroupChat {
//                //                    if cmdbody.action == "TypingBegin" {
//                //                        var needAdd = true
//                //                        for username in groupInputList {
//                //                            if username == cmd.from {
//                //                                needAdd = false
//                //                            }
//                //                        }
//                //                        if needAdd {
//                //                            groupInputList.append(cmd.from)
//                //                        }
//                //                        var text = ""
//                //                        for username in groupInputList {
//                //                            if let data = QueryFriend.shared.getGroupUser(userId: username, groupId: cmd.conversationId) {
//                //                                if QueryFriend.shared.checkFriend(userID: username) {
//                //                                    if data.friend_name?.isEmpty ?? true {
//                //                                        text += String(format: "%@ ", data.user_name!)
//                //                                    }else{
//                //                                        text += String(format: "%@ ", data.friend_name!)
//                //                                    }
//                //                                }else{
//                //                                    if data.group_user_nickname?.isEmpty ?? true {
//                //                                        text += String(format: "%@ ", data.user_name!)
//                //                                    }else{
//                //                                        text += String(format: "%@ ", data.group_user_nickname!)
//                //                                    }
//                //                                }
//                //                            }else{
//                //                                let data = QueryFriend.shared.queryStronger(groupId: conversation.conversationId, id: username)
//                //                                text += String(format: "%@ ", data?.name ?? "")
//                //                            }
//                //                        }
//                //                        self.title = String(format: "%@正在输入", text)
//                //                    }
//                //                    if cmdbody.action == "TypingEnd" {
//                //                        if groupInputList.count == 0 {
//                //                            self.title = self.groupModel?.groupName
//                //                        }else{
//                //                            var i = 0
//                //                            for name in groupInputList {
//                //                                if name == cmd.from {
//                //                                    break
//                //                                }
//                //                                i += 1
//                //                            }
//                //                            if i == 0 && groupInputList[0] == cmd.from {
//                //                                groupInputList.remove(at: 0)
//                //                            }
//                //                            if i != 0 {
//                //                                groupInputList.remove(at: i)
//                //                            }
//                //                            if groupInputList.count == 0 {
//                //                                self.title = self.groupModel?.groupName
//                //                            }else{
//                //                                var text = ""
//                //                                for username in groupInputList {
//                //                                    if let data = QueryFriend.shared.getGroupUser(userId: username, groupId: cmd.conversationId) {
//                //                                        if QueryFriend.shared.checkFriend(userID: username) {
//                //                                            if data.friend_name?.isEmpty ?? true {
//                //                                                text += String(format: "%@ ", data.user_name!)
//                //                                            }else{
//                //                                                text += String(format: "%@ ", data.friend_name!)
//                //                                            }
//                //                                        }else{
//                //                                            if data.group_user_nickname?.isEmpty ?? true {
//                //                                                text += String(format: "%@ ", data.user_name!)
//                //                                            }else{
//                //                                                text += String(format: "%@ ", data.group_user_nickname!)
//                //                                            }
//                //                                        }
//                //                                    }else{
//                //                                        let data = QueryFriend.shared.queryStronger(groupId: conversation.conversationId, id: username)
//                //                                        text += String(format: "%@ ", data?.name ?? "")
//                //                                    }
//                //                                }
//                //                                self.title = String(format: "%@正在输入", text)
//                //                            }
//                //                        }
//                //                    }
//                //                }
//                if conversation.type == EMConversationTypeChat {
//                    if cmdbody.action == "TypingBegin" {
//                        self.title = "对方正在输入"
//                    }
//                    if cmdbody.action == "TypingEnd" {
//                        if let data = QueryFriend.shared.queryFriend(id: conversation.conversationId) {
//                            self.title = data.name
//                        }else{
//                            let data = QueryFriend.shared.queryStronger(id: conversation.conversationId)
//                            self.title = data?.name
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func messagesDidRead(_ aMessages: [Any]!) {
//        if let messazges = aMessages as? [EMMessage] {
//            for m in messazges {
//                if m.conversationId == conversation.conversationId {
//                    reloadMessaage(message: m)
//                }
//            }
//        }
//    }
//
//    // MARK: EMChatToolbarDelegate
//    func chatToolbarDidChangeFrame(toHeight: CGFloat) {
//        UIView.animate(withDuration: 0.3) {
//            var rext = self.tableView!.frame
//            rext.origin.y = 0
//            rext.size.height = self.view.frame.height - toHeight - (UIScreen.main.bounds.height >= 812 ? 34 : 0)
//            self.tableView!.frame = rext
//        }
//        _scrollViewToBottom(animated: false)
//    }
//
//    func inputTextViewWillBeginEditing(_ inputTextView: EaseTextView!) {
//        UIMenuController.shared.setMenuVisible(false, animated: false)
//    }
//
//    func inputTextViewDidBeginEditing(_ inputTextView: EaseTextView!) {
//
//    }
//
//    func didSendText(_ text: String!) {
//        if text.count > 0 {
//            sendTextMessage(text)
//        }
//        if !groupSend {
//            if conversation.type == EMConversationTypeChat {
//                let body = EMCmdMessageBody(action: "TypingEnd")
//                body?.isDeliverOnlineOnly = true
//                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                }, completion: { (m, e) in
//
//                })
//            }
//            if conversation.type == EMConversationTypeGroupChat {
//                let body = EMCmdMessageBody(action: "TypingEnd")
//                body?.isDeliverOnlineOnly = true
//                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                message?.chatType = EMChatTypeGroupChat
//                EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                }, completion: { (m, e) in
//
//                })
//            }
//        }
//    }
//
//    func didInputAt(inLocation location: UInt) -> Bool {
//        return false
//    }
//
//    func didDeleteCharacter(fromLocation location: UInt) -> Bool {
//        return false
//    }
//
//    func didSendText(_ text: String!, withExt ext: [AnyHashable : Any]!) {
//        if let emotion = ext[EASEUI_EMOTION_DEFAULT_EXT] as? EaseEmotion {
//            if let ex = self.emotionExtFormessageViewController(self, easeEmotion: emotion) {
//                sendTextMessage(text: text, ext: ex)
//                if !groupSend {
//                    if conversation.type == EMConversationTypeChat {
//                        let body = EMCmdMessageBody(action: "TypingEnd")
//                        body?.isDeliverOnlineOnly = true
//                        let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                        EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                        }, completion: { (m, e) in
//
//                        })
//                    }
//                    if conversation.type == EMConversationTypeGroupChat {
//                        let body = EMCmdMessageBody(action: "TypingEnd")
//                        body?.isDeliverOnlineOnly = true
//                        let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                        message?.chatType = EMChatTypeGroupChat
//                        EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                        }, completion: { (m, e) in
//
//                        })
//                    }
//                }
//                return
//            }
//        }
//        if text.count > 0 {
//            sendTextMessage(text: text, ext: ext)
//        }
//        if !groupSend {
//            if conversation.type == EMConversationTypeChat {
//                let body = EMCmdMessageBody(action: "TypingEnd")
//                body?.isDeliverOnlineOnly = true
//                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                }, completion: { (m, e) in
//
//                })
//            }
//            if conversation.type == EMConversationTypeGroupChat {
//                let body = EMCmdMessageBody(action: "TypingEnd")
//                body?.isDeliverOnlineOnly = true
//                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                message?.chatType = EMChatTypeGroupChat
//                EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                }, completion: { (m, e) in
//
//                })
//            }
//        }
//    }
//
//    func didStartRecordingVoiceAction(_ recordView: UIView!) {
//        weak var weakSelf = self
//        _canRecordCompletion { (state) in
//            if state == 1 {
//                weakSelf?.recordView?.recordButtonTouchDown()
//                self.isRecording = true
//                let tmpView = self.recordView
//                weakSelf?.view.bringSubviewToFront(tmpView!)
//                tmpView?.mas_makeConstraints({ (make) in
//                    make?.centerX.equalTo()(weakSelf?.view)
//                    make?.centerY.equalTo()(weakSelf?.navigationController?.view)
//                    make?.height.mas_equalTo()(200)
//                    make?.width.mas_equalTo()(200)
//                })
//                EMCDDeviceManager.sharedInstance()?.asyncStartRecording(withFileName: UUID().uuidString, completion: { (er) in
//                    if er != nil {
//                        self.isRecording = false
//                    }
//                })
//            }
//            if state == 2 {
//                let alert = UIAlertController(title: "没有麦克风权限", message: nil, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
//                weakSelf?.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
//
//    func didCancelRecordingVoiceAction(_ recordView: UIView!) {
//        if isRecording {
//            EMCDDeviceManager.sharedInstance()?.cancelCurrentRecording()
//            self.recordView?.recordButtonTouchUpOutside()
//            self.recordView?.removeFromSuperview()
//            isRecording = false
//        }
//    }
//
//    func didFinishRecoingVoiceAction(_ recordView: UIView!) {
//        if isRecording {
//            self.recordView?.recordButtonTouchUpInside()
//            self.recordView?.removeFromSuperview()
//            EMCDDeviceManager.sharedInstance()?.asyncStopRecording(completion: { (filePath, duration, err) in
//                if err != nil {
//                    DispatchQueue.main.async {
//                        UIApplication.shared.keyWindow?.makeToast(err?.localizedDescription)
//                    }
//                }else{
//                    self.sendVoiceMessage(localPath: filePath!, duration: duration)
//                }
//            })
//            isRecording = false
//        }
//    }
//
//    func didDrag(insideAction recordView: UIView!) {
//        self.recordView?.recordButtonDragInside()
//    }
//
//    func didDragOutsideAction(_ recordView: UIView!) {
//        self.recordView?.recordButtonDragOutside()
//    }
//
//    // MARK: EaseChatBarMoreViewDelegate
//    func moreView(_ moreView: EaseChatBarMoreView!, didItemInMoreViewAt index: Int) {
//
//    }
//
//    func moreViewPhotoAction(_ moreView: EaseChatBarMoreView!) {
//        chatToolbar?.endEditing(true)
//        imagePickAction(moreView)
//        isShow = false
//        EaseSDKHelper.share()?.isShowingimagePicker = true
//    }
//
//    func moreViewTakePicAction(_ moreView: EaseChatBarMoreView!) {
//        chatToolbar?.endEditing(true)
//        takePicAction(moreView)
//        self.isShow = false
//        EaseSDKHelper.share()?.isShowingimagePicker = true
//    }
//
//    func moreViewLocationAction(_ moreView: EaseChatBarMoreView!) {
//        chatToolbar?.endEditing(true)
//        let locationController = EaseLocationViewController()
//        locationController.delegate = self
//        self.navigationController?.pushViewController(locationController, animated: true)
//    }
//
//    func moreViewAudioCallAction(_ moreView: EaseChatBarMoreView!) {
//        chatToolbar?.endEditing(true)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNOTIFICATION_MAKE1V1CALL), object: ["chatter":conversation.conversationId,"type":0], userInfo: nil)
//    }
//
//    func moreViewVideoCallAction(_ moreView: EaseChatBarMoreView!) {
//        chatToolbar?.endEditing(true)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNOTIFICATION_MAKE1V1CALL), object: ["chatter":conversation.conversationId,"type":1], userInfo: nil)
//    }
//
//    func imagePickAction(_ moreView: EaseChatBarMoreView!) {
//        let vc = HXAlbumListViewController()
//        let m = HXPhotoManager()
//        m.configuration.cameraCellShowPreview = false
//        m.configuration.downloadICloudAsset = true
//        m.configuration.openCamera = false
//        m.configuration.lookGifPhoto = false
//        m.configuration.lookLivePhoto = false
//        m.type = .photoAndVideo
//        m.configuration.saveSystemAblum = false
//        m.configuration.supportRotation = false
//        m.configuration.photoMaxNum = 1
//        m.configuration.videoMaxNum = 1
//        m.configuration.maxNum = 1
//        m.configuration.hideOriginalBtn = false
//        m.configuration.photoCanEdit = false
//        m.configuration.videoCanEdit = false
//        m.configuration.specialModeNeedHideVideoSelectBtn = true
//        m.configuration.navBarBackgroudColor = UIColor.hexadecimalColor(hexadecimal: "F7F6F6")
//        m.configuration.navigationTitleColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
//        m.configuration.themeColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
//        m.configuration.videoMaximumSelectDuration = 10 * 60
//        m.configuration.showDateSectionHeader = false
//        vc.manager = m
//        vc.delegate = self
//        let nav = HXCustomNavigationController(rootViewController: vc)
//        nav.supportRotation = false
//        nav.navigationBar.tintColor = UIColor.white
//        UIViewController.currentViewController()?.present(nav, animated: true, completion: nil)
//    }
//
//    func takePicAction(_ moreView: EaseChatBarMoreView!) {
//        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
//            self.view.makeToast("无法使用相机")
//            return
//        }
//        AVCaptureDevice.requestAccess(for: .video) { (granted) in
//            DispatchQueue.main.async {
//                if granted {
//                    let m = HXPhotoManager()
//                    m.type = .photoAndVideo
//                    m.configuration.videoMaximumDuration = 10 * 60
//                    m.configuration.themeColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
//                    m.configuration.sessionPreset = "AVCaptureSessionPreset1280x720"
//                    let vc = HXCustomCameraViewController()
//                    vc.manager = m
//                    vc.delegate = self
//                    vc.isOutside = true
//                    let nav = HXCustomNavigationController(rootViewController: vc)
//                    nav.isCamera = true
//                    nav.supportRotation = false
//                    self.present(nav, animated: true, completion: nil)
//                }else{
//                    self.view.makeToast("无法使用相机")
//                }
//            }
//        }
//    }
//
//    func emotionExtFormessageViewController(_ viewController: NewChatViewController!, easeEmotion: EaseEmotion!) -> [AnyHashable : Any]! {
//        if easeEmotion.emotionId == "add_DIY" {
//            return ["NoSend":"1"]
//        }
//        if easeEmotion.emotionId == "[自定义表情]" {
//            return ["jpzim_is_big_expression":true,MESSAGE_ATTR_IS_BIG_EXPRESSION:true,"jpzim_big_expression_path":easeEmotion.emotionOriginalURL]
//        }
//        return [:]
//    }
//
//    // MARK: - EMLocationViewDelegate
//
//    func sendLocationLatitude(_ latitude: Double, longitude: Double, andAddress address: String!) {
//        let msg = EaseSDKHelper.getLocationMessage(withLatitude: latitude, longitude: longitude, address: address, to: conversation.conversationId, messageType: _messageTypeFromConversationType(), messageExt: nil)
//        send(msg, isNeedUploadFile: false)
//    }
//
//    //  MARK: - HXAlbumListViewControllerDelegate
//
//    func albumListViewController(_ albumListViewController: HXAlbumListViewController!, didDoneAllList allList: [HXPhotoModel]!, photos photoList: [HXPhotoModel]!, videos videoList: [HXPhotoModel]!, original: Bool) {
//        albumListViewController.dismiss(animated: true, completion: nil)
//        self.isShow = true
//        EaseSDKHelper.share()?.isShowingimagePicker = false
//        for photo in photoList {
//            let imageRequestOption = PHImageRequestOptions()
//            // PHImageRequestOptions是否有效
//            imageRequestOption.isSynchronous = true
//            // 缩略图的压缩模式设置为无
//            imageRequestOption.resizeMode = .none
//            imageRequestOption.deliveryMode = .highQualityFormat
//            if photo.asset?.isGIF ?? false {
//                PHImageManager.default().requestImageData(for: photo.asset!, options: imageRequestOption) { (gifdata, name, org, ext) in
//                    self.sendImageMessage(with: gifdata!)
//                }
//            }else{
//                if let p = photo.previewPhoto {
//                    if original {
//                        let message = EaseSDKHelper.getImageMessage(with: p, to: self.conversation.conversationId, messageType: self._messageTypeFromConversationType(), messageExt: [:])
//                        let body = message?.body as! EMImageMessageBody
//                        body.compressionRatio = 1
//                        message?.body = body
//                        self.send(message, isNeedUploadFile: true)
//                    }else{
//                        self.sendImageMessage(p)
//                    }
//                    return
//                }
//                // 缩略图的质量为高质量，不管加载时间花多少
//                if original {
//                    imageRequestOption.deliveryMode = .highQualityFormat
//                }else{
//                    imageRequestOption.deliveryMode = .fastFormat
//                }
//                var size = photo.imageSize
//                if !original {
//                    size = CGSize(width: 800, height: photo.imageSize.height/photo.imageSize.width*800)
//                }
//                PHImageManager.default().requestImage(for: photo.asset!, targetSize: size, contentMode: .default, options: imageRequestOption) { (image, ext) in
//                    if image != nil {
//                        if original {
//                            let message = EaseSDKHelper.getImageMessage(with: image, to: self.conversation.conversationId, messageType: self._messageTypeFromConversationType(), messageExt: [:])
//                            let body = message?.body as! EMImageMessageBody
//                            body.compressionRatio = 1
//                            message?.body = body
//                            self.send(message, isNeedUploadFile: true)
//                        }else{
//                            self.sendImageMessage(image!)
//                        }
//                    }
//                }
//            }
//        }
//
//        for v in videoList {
//            if v.fileURL != nil {
//                let mp4 = self._convert2Mp4(v.fileURL!)
//                self.sendVideoMessage(with: mp4!)
//            }
//        }
//    }
//    func albumListViewControllerDidCancel(_ albumListViewController: HXAlbumListViewController!) {
//        self.isShow = true
//        EaseSDKHelper.share()?.isShowingimagePicker = false
//    }
//
//    // MARK: - HXCustomCameraViewControllerDelegate
//
//    func customCameraViewController(_ viewController: HXCustomCameraViewController!, didDone model: HXPhotoModel!) {
//        viewController.dismiss(animated: true, completion: nil)
//        if model.type == .cameraPhoto {
//            if let p = model.previewPhoto {
//                let message = EaseSDKHelper.getImageMessage(with: p, to: self.conversation.conversationId, messageType: self._messageTypeFromConversationType(), messageExt: [:])
//                let body = message?.body as! EMImageMessageBody
//                body.compressionRatio = 1
//                message?.body = body
//                self.send(message, isNeedUploadFile: true)
//                return
//            }
//        }
//        if model.type == .cameraVideo {
//            if model.fileURL != nil {
//                let mp4 = self._convert2Mp4(model.fileURL!)
//                self.sendVideoMessage(with: mp4!)
//            }
//        }
//        self.isShow = true
//        EaseSDKHelper.share()?.isShowingimagePicker = false
//    }
//
//    func customCameraViewControllerDidCancel(_ viewController: HXCustomCameraViewController!) {
//        self.isShow = true
//        EaseSDKHelper.share()?.isShowingimagePicker = false
//    }
//
//    // MARK: - Helper
//    func _messageTypeFromConversationType() -> EMChatType {
//        return conversation.type == EMConversationTypeChat ? EMChatTypeChat : EMChatTypeGroupChat
//    }
//
//    func _convert2Mp4(_ url:URL) -> URL? {
//        let mp4Url:URL = URL(fileURLWithPath: String(format: "%@/%@.mp4", EMCDDeviceManager.dataPath(),UUID().uuidString.replacingOccurrences(of: "-", with: "")))
//        let avAsset = AVURLAsset(url: url)
//        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)
//        exportSession?.outputURL = mp4Url
//        exportSession?.shouldOptimizeForNetworkUse = true
//        exportSession?.outputFileType = .mp4
//        let wait = DispatchSemaphore(value: 01)
//        exportSession?.exportAsynchronously(completionHandler: {
//            switch exportSession!.status {
//            case .cancelled:
//                break
//            case .failed:
//                break
//            case .completed:
//                break
//            default:
//                break
//            }
//            wait.signal()
//        })
//        let res = wait.wait(timeout: .distantFuture)
//        if res == .timedOut {
//            return nil
//        }
//        return mp4Url
//    }
//
//    func sendVoiceMessage(localPath:String,duration:Int) {
//        let msg = EaseSDKHelper.getVoiceMessage(withLocalPath: localPath, duration: duration, to: conversation.conversationId, messageType: _messageTypeFromConversationType(), messageExt: nil)
//        send(msg, isNeedUploadFile: true)
//    }
//
//    func sendTextMessage(_ text:String) {
//        let msg = EaseSDKHelper.getTextMessage(text, to: conversation.conversationId, messageType: _messageTypeFromConversationType(), messageExt: nil)
//        send(msg, isNeedUploadFile: false)
//    }
//
//    func sendTextMessage(text:String,ext:[AnyHashable:Any]) {
//        let msg = EaseSDKHelper.getTextMessage(text, to: conversation.conversationId, messageType: _messageTypeFromConversationType(), messageExt: ext)
//        send(msg, isNeedUploadFile: false)
//    }
//
//    func sendImageMessage(_ image:UIImage) {
//        let msg = EaseSDKHelper.getImageMessage(with: image, to: conversation.conversationId, messageType: _messageTypeFromConversationType(), messageExt: nil)
//        send(msg, isNeedUploadFile: true)
//    }
//
//    func sendImageMessage(with:Data) {
//        let msg = EaseSDKHelper.getImageMessage(withImageData: with, to: conversation.conversationId, messageType: _messageTypeFromConversationType(), messageExt: nil)
//        send(msg, isNeedUploadFile: true)
//    }
//
//    func sendVideoMessage(with: URL) {
//        let msg = EaseSDKHelper.getVideoMessage(with: with, to: conversation.conversationId, messageType: _messageTypeFromConversationType(), messageExt: nil)
//        send(msg, isNeedUploadFile: false)
//    }
//
//    func send(_ message: EMMessage!, isNeedUploadFile isUploadFile: Bool) {
//        weak var weakSelf = self
//        if conversation.type == EMConversationTypeGroupChat {
//            message.chatType = EMChatTypeGroupChat
//        }
//        if message.ext != nil {
//            if message.ext["NoSend"] as? String == "1" {
//                return
//            }
//            if message.ext["jpzim_is_big_expression"] as? Int == 1 {
//                message.body = EMTextMessageBody(text: "[自定义表情]")
//            }
//        }
//        if conversation.type == EMConversationTypeGroupChat {
//            if me?.is_shield == 1 && me?.is_manager == 2 && me?.is_administrator == 2 {
//                self.chatToolbar?.endEditing(true)
//                self.view.makeToast("你已被禁言")
//                return
//            }else{
//                if me?.is_manager == 2 && me?.is_administrator == 2 {
//                    if groupModel?.is_all_banned == 1 {
//                        self.ChangeMuteble(mute: true)
//                        self.chatToolbar?.endEditing(true)
//                        self.view.makeToast("全员禁言中")
//                        return
//                    }
//                    conversation.loadMessagesStart(fromId: nil, count: 50, searchDirection: EMMessageSearchDirectionUp) { (m, e) in
//                        if m == nil
//                        {
//                            if self.atList != nil {
//                                var at = Array<String?>()
//                                for m in self.atList! {
//                                    at.append(m?.model?.user_id)
//                                }
//                                message.ext = ["em_at_list":at]
//                                self.atList = nil
//                            }
//                            if self.isAtAll {
//                                if message.ext == nil
//                                {
//                                    message.ext = ["em_at_list":"ALL"]
//                                }else
//                                {
//                                    message.ext["em_at_list"] = "ALL"
//                                }
//                                self.isAtAll = false
//                                self.atAllStart = -1
//                            }
//                            if message.body.type == EMMessageBodyTypeText {
//                                let body = message.body as! EMTextMessageBody
//                                message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
//                            }
//                            if isUploadFile  {
//                                if !EMClient.shared()!.options.isAutoTransferMessageAttachments {
//                                    EMClient.shared()?.options.isAutoTransferMessageAttachments = true
//                                }
//                            }
//                            weakSelf?.addMessageDataSourse(mesasage: message)
//                            if message.body.type == EMMessageBodyTypeVideo {
//                                weakSelf?.uploadAndSendVedioMessage(message: message)
//                                return
//                            }
//                            EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                            }, completion: { (msg, err) in
//                                weakSelf?.reloadMessaage(message: message)
//                            })
//                            return
//                        }
//                        if m!.count < 5
//                        {
//                            if self.atList != nil {
//                                var at = Array<String?>()
//                                for m in self.atList! {
//                                    at.append(m?.model?.user_id)
//                                }
//                                message.ext = ["em_at_list":at]
//                                self.atList = nil
//                            }
//                            if self.isAtAll {
//                                if message.ext == nil
//                                {
//                                    message.ext = ["em_at_list":"ALL"]
//                                }else
//                                {
//                                    message.ext["em_at_list"] = "ALL"
//                                }
//                                self.isAtAll = false
//                                self.atAllStart = -1
//                            }
//                            if message.body.type == EMMessageBodyTypeText {
//                                let body = message.body as! EMTextMessageBody
//                                message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
//                            }
//                            if isUploadFile  {
//                                if !EMClient.shared()!.options.isAutoTransferMessageAttachments {
//                                    EMClient.shared()?.options.isAutoTransferMessageAttachments = true
//                                }
//                            }
//                            weakSelf?.addMessageDataSourse(mesasage: message)
//                            if message.body.type == EMMessageBodyTypeVideo {
//                                weakSelf?.uploadAndSendVedioMessage(message: message)
//                                return
//                            }
//                            EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                            }, completion: { (msg, err) in
//                                weakSelf?.reloadMessaage(message: message)
//                            })
//                            return
//                        }
//                        var msgs = m as! [EMMessage]
//                        msgs = msgs.filter({ (ms) -> Bool in
//                            return ms.from == self.data!.db!.user_id!
//                        })
//                        msgs = msgs.filter({ (ms) -> Bool in
//                            if ms.ext != nil {
//                                if ms.ext["em_recall"] != nil {
//                                    return false
//                                }
//                            }
//                            return true
//                        })
//                        msgs = msgs.sorted(by: { (a, b) -> Bool in
//                            return a.localTime > b.localTime
//                        })
//                        if msgs.count > 4 {
//                            if NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970InMilliSecond() - Double(msgs[4].timestamp) > 60 * 1000 {
//                                if self.atList != nil {
//                                    var at = Array<String?>()
//                                    for m in self.atList! {
//                                        at.append(m?.model?.user_id)
//                                    }
//                                    message.ext = ["em_at_list":at]
//                                    self.atList = nil
//                                }
//                                if self.isAtAll {
//                                    if message.ext == nil
//                                    {
//                                        message.ext = ["em_at_list":"ALL"]
//                                    }else
//                                    {
//                                        message.ext["em_at_list"] = "ALL"
//                                    }
//                                    self.isAtAll = false
//                                    self.atAllStart = -1
//                                }
//                                if message.body.type == EMMessageBodyTypeText {
//                                    let body = message.body as! EMTextMessageBody
//                                    message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
//                                }
//                                if isUploadFile  {
//                                    if !EMClient.shared()!.options.isAutoTransferMessageAttachments {
//                                        EMClient.shared()?.options.isAutoTransferMessageAttachments = true
//                                    }
//                                }
//                                weakSelf?.addMessageDataSourse(mesasage: message)
//                                if message.body.type == EMMessageBodyTypeVideo {
//                                    weakSelf?.uploadAndSendVedioMessage(message: message)
//                                    return
//                                }
//                                EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                                }, completion: { (msg, err) in
//                                    weakSelf?.reloadMessaage(message: message)
//                                })
//                                return
//                            }else{
//                                self.chatToolbar?.endEditing(true)
//                                self.view.makeToast("60秒内只可以发5条消息")
//                            }
//                        }else{
//                            if self.atList != nil {
//                                var at = Array<String?>()
//                                for m in self.atList! {
//                                    at.append(m?.model?.user_id)
//                                }
//                                message.ext = ["em_at_list":at]
//                                self.atList = nil
//                            }
//                            if self.isAtAll {
//                                if message.ext == nil
//                                {
//                                    message.ext = ["em_at_list":"ALL"]
//                                }else
//                                {
//                                    message.ext["em_at_list"] = "ALL"
//                                }
//                                self.isAtAll = false
//                                self.atAllStart = -1
//                            }
//                            if message.body.type == EMMessageBodyTypeText {
//                                let body = message.body as! EMTextMessageBody
//                                message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
//                            }
//                            if isUploadFile  {
//                                if !EMClient.shared()!.options.isAutoTransferMessageAttachments {
//                                    EMClient.shared()?.options.isAutoTransferMessageAttachments = true
//                                }
//                            }
//                            weakSelf?.addMessageDataSourse(mesasage: message)
//                            if message.body.type == EMMessageBodyTypeVideo {
//                                weakSelf?.uploadAndSendVedioMessage(message: message)
//                                return
//                            }
//                            EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                            }, completion: { (msg, err) in
//                                weakSelf?.reloadMessaage(message: message)
//                            })
//                        }
//                    }
//                    return
//                }
//            }
//        }
//        if self.atList != nil {
//            var at = Array<String?>()
//            for m in self.atList! {
//                at.append(m?.model?.user_id)
//            }
//            message.ext = ["em_at_list":at]
//            self.atList = nil
//        }
//        if isAtAll {
//            if message.ext == nil
//            {
//                message.ext = ["em_at_list":"ALL"]
//            }else
//            {
//                message.ext["em_at_list"] = "ALL"
//            }
//            self.isAtAll = false
//            self.atAllStart = -1
//        }
//        if message.body.type == EMMessageBodyTypeText {
//            let body = message.body as! EMTextMessageBody
//            message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
//        }
//        if isUploadFile  {
//            if !EMClient.shared()!.options.isAutoTransferMessageAttachments {
//                EMClient.shared()?.options.isAutoTransferMessageAttachments = true
//            }
//        }
//        addMessageDataSourse(mesasage: message)
//        if message.body.type == EMMessageBodyTypeVideo {
//            uploadAndSendVedioMessage(message: message)
//            return
//        }
//        EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//        }, completion: { (msg, err) in
//            weakSelf?.reloadMessaage(message: message)
//        })
//    }
//
//    func uploadAndSendVedioMessage(message:EMMessage) {
//        weak var weakSelf = self
//        message.status = EMMessageStatusDelivering
//        weakSelf?.reloadMessaage(message: message)
//        if let body = message.body as? EMVideoMessageBody {
//            if !FileManager.default.fileExists(atPath: body.localPath) {
//                message.status = EMMessageStatusFailed
//                weakSelf?.reloadMessaage(message: message)
//                return
//            }
//            let app = UIApplication.shared.delegate as! AppDelegate
//            let put1 = OSSPutObjectRequest()
//            put1.bucketName = "hgjt-oss"
//            put1.objectKey = String(format: "im19060501/%@", (body.localPath! as NSString).lastPathComponent)
//            put1.uploadingFileURL = URL(fileURLWithPath: body.localPath)
//            let put1Task = app.ossClient?.putObject(put1)
//            put1Task?.continue({ (task) -> Any? in
//                if message.status == EMMessageStatusFailed {
//                    return nil
//                }
//                if task.error == nil {
//                    body.remotePath = String(format: "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/%@", put1.objectKey)
//                    message.body = body
//                    weakSelf?.reloadMessaage(message: message)
//                    let put2 = OSSPutObjectRequest()
//                    put2.bucketName = "hgjt-oss"
//                    put2.objectKey = String(format: "im19060501/%@", (body.thumbnailLocalPath! as NSString).lastPathComponent)
//                    put2.uploadingFileURL = URL(fileURLWithPath: body.thumbnailLocalPath)
//                    let put2Task = app.ossClient?.putObject(put2)
//                    put2Task?.continue({ (task) -> Any? in
//                        if message.status == EMMessageStatusFailed {
//                            return nil
//                        }
//                        if task.error == nil {
//                            body.thumbnailRemotePath = String(format: "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/%@", put2.objectKey)
//                            message.body = body
//                            weakSelf?.reloadMessaage(message: message)
//                            EMClient.shared()?.options.isAutoTransferMessageAttachments = false
//                            EMClient.shared()?.chatManager.send(message, progress: { (p) in
//
//                            }, completion: { (msg, err) in
//                                EMClient.shared()?.options.isAutoTransferMessageAttachments = true
//                                weakSelf?.reloadMessaage(message: message)
//                            })
//                        }else{
//                            message.status = EMMessageStatusFailed
//                            weakSelf?.reloadMessaage(message: message)
//                        }
//                        return nil
//                    })
//                }else{
//                    message.status = EMMessageStatusFailed
//                    weakSelf?.reloadMessaage(message: message)
//                }
//                return nil
//            })
//        }else{
//            message.status = EMMessageStatusFailed
//            weakSelf?.reloadMessaage(message: message)
//        }
//    }
//
//    func addMessageDataSourse(mesasage:EMMessage) {
//        weak var weazkSelf = self
//        messageQueue.async {
//            weazkSelf?.messageDatasourse?.append(mesasage)
//            DispatchQueue.main.async {
//                let data = [weazkSelf?.dataArray,weazkSelf?.generateModel([mesasage], isAppend: true)]
//                weazkSelf?.dataArray = data.compactMap({ (d) -> [Any]? in
//                    return d
//                })
//                weazkSelf?.tableView?.reloadData()
//            }
//            DispatchQueue.main.async {
//                if mesasage.direction != EMMessageDirectionReceive || weazkSelf?.isBottom ?? false {
//                    weazkSelf?.tableView?.scrollToRow(at: IndexPath(row: (weazkSelf?.dataArray?.count ?? 1) - 1, section: 0), at: .bottom, animated: true)
//                }
//            }
//        }
//    }
//
//    func _scrollViewToBottom(animated:Bool) {
//        if tableView!.contentSize.height > tableView!.frame.height {
//            let offset = CGPoint(x: 0, y: tableView!.contentSize.height - tableView!.frame.height)
//            tableView?.setContentOffset(offset, animated: animated)
//        }
//    }
//
//    func _canRecordCompletion(aCompletion: @escaping (Int) -> Void) {
//        let state = AVCaptureDevice.authorizationStatus(for: .audio)
//        if state == .notDetermined {
//            AVAudioSession.sharedInstance().requestRecordPermission { (b) in
//                aCompletion(0)
//            }
//        }else if state == .restricted || state == .denied {
//            aCompletion(2)
//        }else{
//            aCompletion(1)
//        }
//    }
//
//
//    func setupEmotion() {
//        var defualface = Array<EaseEmotion>()
//        if let emotionDB = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "emotionDB", ofType: "plist")!) {
//            for (_,value) in emotionDB {
//                defualface.append(EaseEmotion(name: "", emotionId: value as? String, emotionThumbnail: value as? String, emotionOriginal: value as? String, emotionOriginalURL: "", emotionType: EMEmotionType.default))
//            }
//        }
//        let menagerDefualt = EaseEmotionManager(type: .default, emotionRow: 3, emotionCol: 7, emotions: defualface, tagImage: UIImage(named: "ee_1"))
//        var pngFace = Array<EaseEmotion>()
//        pngFace.append(EaseEmotion(name: "", emotionId: "add_DIY", emotionThumbnail: "添加Face", emotionOriginal: "", emotionOriginalURL: "", emotionType: .png))
//        let faces = QueryFriend.shared.GetAllFace()
//        for face in faces {
//            if face.url != nil && face.path != nil {
//                pngFace.append(EaseEmotion(name: "", emotionId: "[自定义表情]", emotionThumbnail: face.path!, emotionOriginal: face.path!, emotionOriginalURL: face.url!, emotionType: .gif))
//            }else if face.url != nil {
//                pngFace.append(EaseEmotion(name: "", emotionId: "[自定义表情]", emotionThumbnail: "", emotionOriginal: "", emotionOriginalURL: face.url!, emotionType: .gif))
//            }
//        }
//        let menagerDIY = EaseEmotionManager(type: .gif, emotionRow: 2, emotionCol: 5, emotions: pngFace, tagImage: UIImage(named: "心"))
//        self.faceView?.setEmotionManagers([menagerDefualt,menagerDIY])
//    }
//
//    func isEmotionMessageFormessageViewController(_ messageModel: IMessageModel!) -> Bool {
//        if messageModel.bodyType == EMMessageBodyTypeText && messageModel.message.ext != nil {
//            if (messageModel.message.ext["jpzim_is_big_expression"] as? Bool) ?? false {
//                return true
//            }
//        }
//        return false
//    }
//
//    deinit {
//        tableView?.removeObserver(self, forKeyPath: "contentOffset")
//    }
//
//}
