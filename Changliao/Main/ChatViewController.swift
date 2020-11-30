//
//  ChatViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/11/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage
import SVProgressHUD

@objc class ChatViewController: EaseMessageViewController,EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource,GroupAtDelegate,HXAlbumListViewControllerDelegate,HXCustomCameraViewControllerDelegate,UIDocumentInteractionControllerDelegate{
   @objc var emotionDic:NSMutableDictionary?
    var group:EMGroup?
    var muteBar:MuteView?
    var groupModel:GroupViewModel?
    var me:GroupMemberData?
    var groupMember:GroupMemberData?
    var friend:FriendData?
    var isFriend:Bool = true
    var isNeedDump:Bool = false
    var focusList:[String]?
    var focusTabview:UITableView?
    var focusDataModel:ChatFocusModel?
    var focusView:UIView?
    var focusViewLines:UIView?
    var focusTableLines:UIView?
    var focusNameLabel:UILabel?
    var focusMessageLabel:UILabel?
    var showButton:UIButton?
    var hideButton:UIButton?
    var atList:[GroupAtModel?]?
    var isAtAll:Bool = false
    var atAllStart:Int = -1
    var isFirst:Bool = true
    var focusHiden:Bool = true
    var isloading:Bool = false
    let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
    var groupSend:Bool = false
    var focusCellClick = false
    var groupInputList:[String] = Array<String>()
    var recivedMessages:[Any]?
    var isShow:Bool = false
    var isDownLoading:Bool = false
    var isNeedPopToRoot:Bool = false
    @objc var picker:UIImagePickerController?
    @objc var FaceArr: NSMutableArray?
    var bkUrl:String = ""
    var yhjfView:UIImageView?
    var yhjfImageView:UIImageView?
    var isOnPreview:Bool = false
    let backImage = UIImageView(image: UIImage(named: "chat_background"))
    
    override func loadView() {
        DispatchQueue.global().async {
            let faces = QueryFriend.shared.GetAllFace()
            for f in faces {
                if SDImageCache.shared.imageFromMemoryCache(forKey: f.url) == nil {
                    if let image = SDImageCache.shared.imageFromMemoryCache(forKey: f.url) {
                        SDImageCache.shared.storeImage(toMemory: image, forKey: f.url)
                    }else{
                        SDWebImageDownloader.shared.downloadImage(with: URL(string: f.url ?? ""), options: .allowInvalidSSLCertificates, progress: nil, completed: { (image, data, e, fanish) in
                            if fanish {
                                SDImageCache.shared.storeImage(toMemory: image, forKey: f.url)
                            }
                        })
                    }
                }
            }
        }
        super.loadView()
        EaseMessageCell.appearance().bubbleMaxWidth = UIScreen.main.bounds.width - EaseBaseMessageCell.appearance().avatarSize * 2 - EaseMessageCellPadding * 4 - 20
        EaseCustomMessageCell.appearance().maxBubbleWidth = UIScreen.main.bounds.width - EaseBaseMessageCell.appearance().avatarSize * 2 - EaseMessageCellPadding * 4 - 20
        EaseBaseMessageCell.appearance().messageNameFont = DCUtill.FONT(x: 12)
    }

    @objc override func viewDidLoad() {
        isShow = false
        super.viewDidLoad()
        scrollToBottomWhenAppear = true
        weak var weakSelf = self
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight=0
        tableView.estimatedSectionFooterHeight=0
        NotificationCenter.default.addObserver(forName: Notification.Name("popViewController"), object: nil, queue: nil) { (no) in
            if no.object as? UIViewController === weakSelf {
                if weakSelf != nil {
                    if let msgList = weakSelf?.messsagesSource as? [EMMessage] {
                        for msg in msgList {
                            if msg.ext?["isFired"] as? Int == 3 {
                                msg.ext?["isFired"] = 4
                                EMClient.shared()?.chatManager.update(msg, completion: nil)
                            }
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateMessage"), object: nil)
                    }
                    EMClient.shared()?.chatManager.remove(weakSelf)
                    EMClient.shared()?.roomManager.remove(weakSelf)
                }
            }
        }
        EaseBaseMessageCell.appearance().avatarCornerRadius = EaseBaseMessageCell.appearance().avatarSize/2
        EaseBaseMessageCell.appearance().messageNameHeight = 15;
        EaseMessageCell.appearance().messageTextFont = UIFont.systemFont(ofSize: 17)
        self.delegate = self
        self.dataSource = self
        self.showRefreshHeader = true
//        self.tableView.keyboardDismissMode = .onDrag
        chatBarMoreView.insertItem(with: UIImage(named: "文件"), highlightedImage: UIImage(named: "文件"), title: "文件")
        messageCountOfPage = 20
        tableView.register(UserCardTableViewCell.self, forCellReuseIdentifier: UserCardTableViewCell.cellIdentifier(withModel: group))
        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        NotificationCenter.default.addObserver(self, selector: #selector(onEmojiChanged), name: Notification.Name("onEmojiChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onHideMenu), name: UIMenuController.didHideMenuNotification, object: nil)
        backImage.contentMode = .scaleAspectFill
        self.view.insertSubview(backImage, at: 0)
        if let bk = QueryFriend.shared.getChatBK(conversation.conversationId) {
            bkUrl = bk
            backImage.sd_setImage(with: URL(string: bk), placeholderImage: UIImage(named: "chat_background"), options: .retryFailed, completed: nil)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ReloadMessaage"), object: nil, queue: OperationQueue.main) { (n) in
            if let msg = n.object as? EMMessage {
                self._reloadTableViewData(with: msg)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateSendOtherMessage"), object: nil, queue: .main) { (n) in
            guard let message = n.object as? EMMessage else{
                return
            }
            if message.conversationId == self.conversation.conversationId {
                self.messageQueue.async {
                    let data = weakSelf?.formatMessages([message])
                    weakSelf?.messsagesSource.add(message)
                    weakSelf?.dataArray.addObjects(from: data ?? [])
                    DispatchQueue.main.async {
                        weakSelf?.tableView.reloadData()
                    }
                    DispatchQueue.main.async {
                        weakSelf?.tableView.scrollToRow(at: IndexPath(row: (weakSelf?.dataArray.count ?? 1) - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            }
        }
        if !groupSend {
//            let bar = chatToolbar as! EaseChatToolbar
//            bar.inputTextView.addta
        }
        
        if conversation.type == EMConversationTypeChat {
            if groupSend {
                return
            }
            initData()
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateCall"), object: nil, queue: OperationQueue.main) { (n) in
                let message = n.object as! EMMessage
                if message.conversationId != self.conversation.conversationId {
                    return
                }
                self.messsagesSource.add(message)
                self.dataArray.add(self.messageViewController(self, modelFor: message))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: self.dataArray.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("fireUpdate"), object: nil, queue: OperationQueue.main) { (n) in
                self.initData()
            }
        }
        if conversation.type == EMConversationTypeGroupChat {
            let chatbar = chatToolbar as! EaseChatToolbar
            DispatchQueue.global().async {
                BoXinUtil.getGroupMember(groupID: self.conversation.conversationId, Complite: nil)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(onUpdate), name: Notification.Name("UpdateGroup"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateFocus), name: Notification.Name("UpdateFocus"), object: nil)
            NotificationCenter.default.addObserver(forName: NSNotification.Name("updateFocusView"), object: nil, queue: OperationQueue.main) { (n) in
                DispatchQueue.main.async {
                    if self.focusTabview != nil {
                        self.focusTabview?.reloadData()
                    }
                }
            }
            DispatchQueue.global().async {
                self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
            }
            groupModel = QueryFriend.shared.queryGroup(id: conversation.conversationId)
            if groupModel?.is_all_banned == 1 && groupModel?.is_admin == 2 && groupModel?.is_menager == 2 {
                self.chatToolbar.isHidden = true
                self.muteBar = MuteView(frame: self.chatToolbar.frame)
                self.view.addSubview(self.muteBar!)
                self.muteBar?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                    make?.top.equalTo()(self.tableView.mas_bottom)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                    make?.bottom.equalTo()(self.view.mas_bottom)
                })
            }
            if groupModel?.is_admin == 2 && groupModel?.is_menager == 2 {
                let bar = chatToolbar as! EaseChatToolbar
                bar.inputViewLeftItems.removeAll()
            }
            if groupModel?.is_admin == 1 || groupModel?.is_menager == 1 {
                chatBarMoreView.insertItem(with: UIImage(named: "抖一抖"), highlightedImage: UIImage(named: "抖一抖"), title: "抖一抖")
            }
            chatBarMoreView.removeItematIndex(4)
            chatBarMoreView.removeItematIndex(3)
        }
        if conversation.type == EMConversationTypeChat
        {
            if isFriend == true
            {
                chatBarMoreView.insertItem(with: UIImage(named: "抖一抖"), highlightedImage: UIImage(named: "抖一抖"), title: "抖一抖")
            }
        }
        
        isShow = true
        if conversation.type == EMConversationTypeChat {
            if conversation.conversationId != "ef1569ada7ab4c528375994e0de246ca" && conversation.conversationId != "2290120c5be7424082216dc8d98179a4" {
                let more = UIBarButtonItem(image: UIImage(named: "圆点菜单"), style: .plain, target: self, action: #selector(onPersonMore))
                self.navigationItem.rightBarButtonItem = more
            }else{
                chatBarMoreView.removeItematIndex(6)
                chatBarMoreView.removeItematIndex(4)
                chatBarMoreView.removeItematIndex(3)
            }
            (chatToolbar as? EaseChatToolbar)?.addObserver(self, forKeyPath: "isTextViewInputEnd", options: .new, context: nil)
        }
        if conversation.type == EMConversationTypeGroupChat {
            let more = UIBarButtonItem(image: UIImage(named: "圆点菜单"), style: .plain, target: self, action: #selector(onMore))
            self.navigationItem.rightBarButtonItem = more
            groupModel = QueryFriend.shared.queryGroup(id: conversation.conversationId)
            DispatchQueue.global().async {
                if let focus = QueryFriend.shared.queryFocus(id: self.data!.db!.user_id!, groupId: self.conversation.conversationId) {
                    self.focusList = focus
                    if self.focusList != nil {
                        self.setupFocusView(focusList: self.focusList!)
                    }
                }
                ///自动收齐关注列表
                if self.isFirst {
                    self.isFirst = false
                    self.updateFocus()
                }
                BoXinUtil.getGroupOnlyInfo(groupId: self.conversation.conversationId) { (b) in
                    NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                    BoXinUtil.getGroupOneMember(groupID: self.conversation.conversationId, userID: EMClient.shared()?.currentUsername ?? "") { (b) in
                        NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                    }
                }
            }
        }
        tableView.backgroundColor=UIColor.clear
        
    }
    
    func getPersonState() {
        if conversation.conversationId == "collection" || conversation.conversationId == "ef1569ada7ab4c528375994e0de246ca" || conversation.conversationId == "2290120c5be7424082216dc8d98179a4" {
            return
        }
        let model = GetChatBackgroundSendModel()
        model.target_id = conversation.conversationId
        DispatchQueue.global().async {
            BoXinProvider.request(.GetUserLastOnlineTime(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        if let model = GetUserLastOnlineReciveModel.deserialize(from: try?res.mapString()) {
                            if model.code == 200 {
                                DispatchQueue.main.async {
                                    let titleView = UIView(frame: CGRect.zero)
                                    let titleLabel = UILabel(frame: CGRect.zero)
                                    titleLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#000527")
                                    titleLabel.font = DCUtill.FONT(x: 17)
                                    titleLabel.text = self.navigationItem.title
                                    titleView.addSubview(titleLabel)
                                    titleLabel.mas_makeConstraints { (make) in
                                        make?.centerX.equalTo()(titleView)
                                        make?.top.equalTo()(titleView)?.offset()(DCUtill.SCRATIO(x: 5))
                                    }
                                    let subTitleLabel = UILabel(frame: CGRect.zero)
                                    subTitleLabel.font = DCUtill.FONT(x: 10)
                                    subTitleLabel.textColor = UIColor.hexadecimalColor(hexadecimal: "#000527")
                                    subTitleLabel.text = model.data?.time
                                    titleView.addSubview(subTitleLabel)
                                    subTitleLabel.mas_makeConstraints { (make) in
                                        make?.centerX.equalTo()(titleView)
                                        make?.top.equalTo()(titleLabel.mas_bottom)
                                    }
                                    self.navigationItem.titleView = titleView
                                }
                            }
                        }
                    }
                case .failure(let err):
                    print(err)
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        if object is EaseChatToolbar {
            if change?[.newKey] as? Bool ?? false {
                let body = EMCmdMessageBody(action: "TypingEnd")
                body?.isDeliverOnlineOnly = true
                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
                EMClient.shared()?.chatManager.send(message, progress: { (p) in
                    
                }, completion: { (m, e) in
                    
                })
            }
        }
    }
    
    override func currentViewControllerShouldPop() -> Bool {
        if isNeedPopToRoot {
            return false
        }
        return true
    }
    
    override func onPop() {
        if isNeedPopToRoot {
            guard let nav = self.navigationController else {
                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
                return
            }
            nav.popToRootViewController(animated: false)
        }
    }
    
    @objc func onHideMenu() {
        if recivedMessages != nil {
            self.messagesDidReceive(recivedMessages!)
            recivedMessages = nil
        }
    }
    
    @objc func onGroupUpdate(noti:Notification) {
        groupModel = QueryFriend.shared.queryGroup(id: conversation.conversationId)
        self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
        if groupModel?.is_all_banned == 1 {
            ChangeMuteble(mute: true)
        }
        if groupModel?.is_all_banned == 2 {
            ChangeMuteble(mute: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backImage.frame=tableView.frame
        isViewDidAppear  = true
        isShow = true
        if isOnPreview {
            return
        }
        super.viewWillAppear(animated)
        getChatBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isShow = true
        if isOnPreview {
            isOnPreview = false
        }
        if conversation.type == EMConversationTypeChat {
            getPersonState()
        }
        super.viewDidAppear(animated)
    }
    
    func getChatBackground() {
        let model = GetChatBackgroundSendModel()
        model.target_id = conversation.conversationId
        weak var weakSelf = self
        DispatchQueue.global().async {
            BoXinProvider.request(.GetChatBackground(model: model)) { (result) in
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
                                    if data.isEmpty {
                                        return
                                    }
                                    if data != weakSelf?.bkUrl {
                                        QueryFriend.shared.addChatBK(weakSelf?.conversation.conversationId ?? "", data)
                                    }
                                    weakSelf?.bkUrl = data
                                    DispatchQueue.main.async {
                                        self.backImage.sd_setImage(with: URL(string: data), placeholderImage: UIImage(named: "chat_background"), options: .allowInvalidSSLCertificates, context: nil)
                                        guard let focusTable = weakSelf?.focusTabview else {
                                            return
                                        }
                                        if let bkview = focusTable.backgroundView as? UIImageView {
                                            bkview.sd_setImage(with: URL(string: data), placeholderImage: UIImage(named: "chat_background"), options: .allowInvalidSSLCertificates, context: nil)
                                        }
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
    
    func DidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @objc func updateFocus() {
        if self.focusView != nil{
            DispatchQueue.main.async {
                self.focusView?.removeFromSuperview()
                self.focusTabview?.removeFromSuperview()
                self.hideButton?.removeFromSuperview()
                self.showButton?.removeFromSuperview()
                self.focusView = nil
                self.focusTabview = nil
                self.hideButton = nil
                self.showButton = nil
            }
            self.focusDataModel?.messageDatasource.removeAll()
            self.focusDataModel?.dataArray.removeAll()
            self.focusDataModel = nil
            if let focus = QueryFriend.shared.queryFocus(id: self.data!.db!.user_id!, groupId: self.conversation.conversationId) {
                self.focusList = focus
                if self.focusList != nil {
                    self.setupFocusView(focusList: self.focusList!)
                }
            }
        }else{
            if let focus = QueryFriend.shared.queryFocus(id: self.data!.db!.user_id!, groupId: self.conversation.conversationId) {
                self.focusList = focus
                if self.focusList != nil {
                    self.setupFocusView(focusList: self.focusList!)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIViewController.currentViewController()?.navigationController?.setNavigationBarHidden(false, animated: false)
        EMCDDeviceManager.sharedInstance()?.stopPlaying()
        UIMenuController.shared.setMenuVisible(false, animated: false)
        chatToolbar.endEditing(true)

        if !groupSend {
            if conversation.type == EMConversationTypeChat {
                let body = EMCmdMessageBody(action: "TypingEnd")
                body?.isDeliverOnlineOnly = true
                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
                EMClient.shared()?.chatManager.send(message, progress: { (p) in
                    
                }, completion: { (m, e) in
                    
                })
            }
            if conversation.type == EMConversationTypeGroupChat {
                let body = EMCmdMessageBody(action: "TypingEnd")
                body?.isDeliverOnlineOnly = true
                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
                message?.chatType = EMChatTypeGroupChat
                EMClient.shared()?.chatManager.send(message, progress: { (p) in
                    
                }, completion: { (m, e) in
                    
                })
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.navigationController == nil {
            EMClient.shared()?.chatManager.remove(self)
            EMClient.shared()?.roomManager.remove(self)
        }
        isShow = false
        isViewDidAppear = false
        SVProgressHUD.dismiss()
    }
    
    @objc private func onMore() {
        if isloading {
            return
        }
        isloading = true
        SVProgressHUD.show()
        BoXinUtil.getGroupOnlyInfo(groupId: conversation.conversationId) { (b) in
            SVProgressHUD.dismiss()
            if b {
                DispatchQueue.main.async {
                    self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
                    let vc = GroupInfoViewController()
                    vc.groupId = self.conversation.conversationId
                    vc.model = QueryFriend.shared.queryGroup(id: self.conversation.conversationId)
                    vc.data = QueryFriend.shared.getGroupMembers(groupId: self.conversation.conversationId)
                    if self.me == nil {
                        self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
                    }
                    vc.me = self.me
                    if vc.data == nil || vc.me == nil {
                        BoXinUtil.getGroupMember(groupID: self.conversation.conversationId, Complite: { (b) in
                            if b {
                                self.isloading = false
                                vc.model = QueryFriend.shared.queryGroup(id: self.conversation.conversationId)
                                vc.data = QueryFriend.shared.getGroupMembers(groupId: self.conversation.conversationId)
                                self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
                                vc.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
                                DispatchQueue.main.async {
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }else
                            {
                                self.isloading = false
                            }
                            
                        })
                        return
                    }
                    self.isloading = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else
            {
                self.isloading = false
            }
        }
    }
    
    @objc private func onPersonMore() {
        if friend == nil {
            isNeedDump = true
            return
        }
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
        
        if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
            for c in contact {
                if c?.data != nil {
                    for d in c!.data! {
                        if d?.user_id == conversation.conversationId {
                            let vc = UserDetailViewController()
                            vc.type=4
                            vc.model=d
                            self.navigationController?.pushViewController(vc, animated: true)
                            return
                        }
                    }
                }
            }
        }
        let dat = QueryFriend.shared.queryStronger(id: conversation.conversationId)
        if dat != nil {
            let vc = UserDetailViewController()
            vc.model = FriendData()
            vc.model?.user_id = dat?.id
            vc.model?.target_user_nickname = dat?.name
            vc.model?.id_card = dat?.id_card
            vc.model?.portrait = dat?.portrait
            vc.model?.is_shield = 2
            vc.model?.is_star = 2
            vc.type = 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func updateDB(_ message: EMMessage?, _ userID:String? = nil) {
        guard let msg = message else{
            return
        }
        GetUserInfoMenager.shard.getUser(message: msg) { (mess) in
            guard let mg = mess else {
                return
            }
            self.messageQueue.async {
                for (idx,obj) in self.dataArray.enumerated() {
                    guard let model = obj as? BoxinMessageModel else {
                        continue
                    }
                    if model.message.from == mg.from {
                        self.dataArray[idx] = self.messageViewController(self, modelFor: model.message) as Any
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func messageViewController(_ viewController: EaseMessageViewController!, modelFor message: EMMessage!) -> IMessageModel! {
        print(messsagesSource.count)
        let model = BoxinMessageModel(message: message)
        model?.avatarImage = UIImage(named: "moren")
        if let body = message.body as? EMImageMessageBody {
            print(body.localPath)
        }
        if message.from == "ef1569ada7ab4c528375994e0de246ca" || message.from == "2290120c5be7424082216dc8d98179a4" {
            model?.avatarImage = UIImage(named: "admin_notice1")
            model?.nickname = "系统消息"
            return model
        }
        if model!.isSender {
            if let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo")){
                model?.nickname = data.db?.user_name
                model?.avatarURLPath = data.db?.portrait
                if model?.isIDCard ?? false {
                    guard let userId = model?.personalID else {
                        return model
                    }
                    if let stranger = QueryFriend.shared.queryStronger(id: userId) {
                        model?.personalName = stranger.name ?? ((message.ext?["username"] as? String) ?? "")
                        model?.personalIDCard = stranger.id_card ?? ((message.ext?["usernum"] as? String) ?? "")
                        model?.personalHeadURL = stranger.portrait ?? ((message.ext?["userhead"] as? String) ?? "")
                    }else{
                        updateDB(message, userId)
                    }
                }
                return model
            }
        }
        if conversation.type == EMConversationTypeChat {
            if let data = QueryFriend.shared.queryFriend(id: message.from) {
                model?.nickname = data.name
                model?.avatarURLPath = data.portrait
            }else{
                if let data = QueryFriend.shared.queryStronger(id: message.from) {
                    model?.nickname = data.name
                    model?.avatarURLPath = data.portrait
                }else{
                    updateDB(message)
                }
            }
            if model?.isIDCard ?? false {
                guard let userId = model?.personalID else {
                    return model
                }
                if let stranger = QueryFriend.shared.queryStronger(id: userId) {
                    model?.personalName = stranger.name ?? ((message.ext?["username"] as? String) ?? "")
                    model?.personalIDCard = stranger.id_card ?? ((message.ext?["usernum"] as? String) ?? "")
                    model?.personalHeadURL = stranger.portrait ?? ((message.ext?["userhead"] as? String) ?? "")
                }else{
                    updateDB(message, userId)
                }
            }
            return model
        }
        if conversation.type == EMConversationTypeGroupChat {
            if let m = QueryFriend.shared.getGroupUser(userId: message.from, groupId: conversation.conversationId) {
                var text :String? = ""
                if QueryFriend.shared.checkFriend(userID: m.user_id!) {
                    if m.friend_name != "" {
                        text = m.friend_name
                    }else{
                        text = m.user_name
                    }
                }else{
                    if m.group_user_nickname != "" {
                        text = m.group_user_nickname;
                    }else{
                        text = m.user_name
                    }
                }
                model?.nickname = text
                //            model?.nickname = m?.group_user_nickname
                model?.avatarURLPath = m.portrait
                model?.member = m
                if model?.isIDCard ?? false {
                    guard let userId = model?.personalID else {
                        return model
                    }
                    if let stranger = QueryFriend.shared.queryStronger(id: userId) {
                        model?.personalName = stranger.name ?? ((message.ext?["username"] as? String) ?? "")
                        model?.personalIDCard = stranger.id_card ?? ((message.ext?["usernum"] as? String) ?? "")
                        model?.personalHeadURL = stranger.portrait ?? ((message.ext?["userhead"] as? String) ?? "")
                    }else{
                        updateDB(message, userId)
                    }
                }
                return model
            }else{
                if let data = QueryFriend.shared.queryStronger(groupId: conversation.conversationId, id: message.from){
                    model?.nickname = data.name
                    model?.avatarURLPath = data.portrait
                }else{
                    updateDB(message)
                }
            }
        }
        if model?.isIDCard ?? false {
            guard let userId = model?.personalID else {
                return model
            }
            if let stranger = QueryFriend.shared.queryStronger(id: userId) {
                model?.personalName = stranger.name ?? ((message.ext?["username"] as? String) ?? "")
                model?.personalIDCard = stranger.id_card ?? ((message.ext?["usernum"] as? String) ?? "")
                model?.personalHeadURL = stranger.portrait ?? ((message.ext?["userhead"] as? String) ?? "")
            }else{
                updateDB(message, userId)
            }
        }
        return model
    }
    
       @objc func messageViewController(_ viewController: EaseMessageViewController!, canLongPressRowAt indexPath: IndexPath!) -> Bool {
        return true
    }
    
    fileprivate func GroupOwnerOrMenager(_ model: IMessageModel?) {
        BoXinUtil.getGroupOneMember(groupID: conversation.conversationId, userID: (model?.message.from)!) { (b) in
            if b {
                DispatchQueue.main.async {
                    self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                    let vc = UserDetailViewController()
                    vc.type=2
                    if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
                        for c in contact {
                            if c?.data != nil {
                                for d in c!.data! {
                                    if d?.user_id == model?.message.from {
                                        vc.type=3
                                        vc.model = d
                                        break
                                    }
                                }
                            }
                        }
                    }
                    dbQuese.async {
                        if let member = QueryFriend.shared.getGroupUser(userId: model!.message.from, groupId: self.conversation.conversationId){
                            vc.member=member
                        }else{
                        }
                        vc.group = self.groupModel
                        DispatchQueue.main.async {
                            self.isloading = false
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }else{
                self.isloading = false
            }
        }
    }
    
    @objc  override func avatarViewSelcted(_ model: IMessageModel!) {
        if !model.isSender {
            if isloading {
                return
            }
            isloading = true
            if conversation.type == EMConversationTypeChat {
                if conversation.conversationId == "ef1569ada7ab4c528375994e0de246ca" || conversation.conversationId == "2290120c5be7424082216dc8d98179a4" {
                    return
                }
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                
                if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
                    for c in contact {
                        if c?.data != nil {
                            for d in c!.data! {
                                if d?.user_id == model.message.from {
                                    let vc = UserDetailViewController()
                                    vc.type=4
                                    vc.model=d
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    return
                                }
                            }
                        }
                    }
                }
                let vc = UserDetailViewController()
                let dat = QueryFriend.shared.queryStronger(id: model.message.from)
                if dat != nil {
                    let m = FriendData()
                    m.target_user_nickname = dat?.name
                    m.friend_self_name = dat?.friend_name
                    m.user_id = dat?.id
                    m.portrait = dat?.portrait
                    m.is_shield = 2
                    m.is_star = 2
                    vc.type = 0
                    m.id_card = dat?.id_card
                    vc.model = m
                    isloading = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            if conversation.type == EMConversationTypeGroupChat {
                if groupModel?.is_menager == 1 || groupModel?.is_admin == 1 {
                    GroupOwnerOrMenager(model)
                    return
                }
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                //        let vc = UserDetailViewController()
                let vc = UserDetailViewController()
                if let m = QueryFriend.shared.getGroupUser(userId: model.message.from, groupId: conversation.conversationId) {
                    let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
                    if contact == nil {
                        BoXinUtil.getFriends { (b) in
                            self.isloading = false
                            if b {
                                let con  = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
                                if con != nil {
                                    for c in con! {
                                        for d in c!.data! {
                                            if d?.user_id == m.user_id {
                                                vc.type=3
                                                vc.model = d
                                                vc.group=self.groupModel
                                                vc.member = m
                                                self.isloading = false
                                                self.navigationController?.pushViewController(vc, animated: true)
                                                return
                                                
                                            }
                                        }
                                    }
                                    vc.type=2
                                    vc.group=self.groupModel
                                    vc.member = m
                                    self.isloading = false
                                    self.navigationController?.pushViewController(vc, animated: true)
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
                                vc.group=self.groupModel
                                vc.member = m
                                self.isloading = false
                                self.navigationController?.pushViewController(vc, animated: true)
                                return
                                
                                
                            }
                        }
                    }
                    vc.type=2
                    vc.group=self.groupModel
                    vc.member = m
                    self.isloading = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    GroupOwnerOrMenager(model)
                }
            }
        }
        super.avatarViewSelcted(model)
    }
    
       @objc func messageViewController(_ viewController: EaseMessageViewController!, didLongPressRowAt indexPath: IndexPath!) -> Bool {
        if (indexPath == nil) {
            return false;
        }
        if indexPath.row >= dataArray.count {
            return false
        }
        if conversation.conversationId == "ef1569ada7ab4c528375994e0de246ca" || conversation.conversationId == "2290120c5be7424082216dc8d98179a4" {
            return false
        }
        let obj = dataArray.object(at: indexPath.row)
        if !(obj is String)  {
            if let cell = tableView.cellForRow(at: indexPath) as? EaseMessageCell {
                cell.becomeFirstResponder()
                menuIndexPath = indexPath
                self.showMenuViewController(cell.bubbleView, andIndexPath: indexPath, messageType: cell.model.bodyType)
                return true
            }
        }
        return true
    }
    
    
       @objc func messageViewController(_ tableView: UITableView!, cellFor messageModel: IMessageModel!) -> UITableViewCell! {
        if messageModel.message.ext != nil {
            if messageModel.message.ext["isFired"] as? Int == 4 {
                let cell = EaseMessageTimeCell(style: .default, reuseIdentifier: EaseMessageTimeCell.cellIdentifier())
                cell.selectionStyle = .none
                cell.title = NSLocalizedString("BurnAfterRead", comment: "Burn after reading")
                return cell
            }
            if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["em_recall"] as? Bool ?? false{
                let cell = EaseMessageTimeCell(style: .default, reuseIdentifier: EaseMessageTimeCell.cellIdentifier())
                cell.selectionStyle = .none
                cell.title = messageModel.text
                return cell
            }
            if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["type"] as? String == "dyd"{
                let cell = EaseMessageTimeCell(style: .default, reuseIdentifier: EaseMessageTimeCell.cellIdentifier())
                cell.selectionStyle = .none
                cell.title = messageModel.text
                return cell
            }
            if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["type"] as? String == "dydfriend"{
                let cell = EaseMessageTimeCell(style: .default, reuseIdentifier: EaseMessageTimeCell.cellIdentifier())
                cell.selectionStyle = .none
                cell.title = messageModel.text
                return cell
            }
        }
        return nil
    }
    
       @objc func messageViewController(_ viewController: EaseMessageViewController!, heightFor messageModel: IMessageModel!, withCellWidth cellWidth: CGFloat) -> CGFloat {
        if messageModel.message.ext != nil {
            if messageModel.message.ext["isFired"] as? Int == 4 {
                return timeCellHeight
            }
            if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["em_recall"] as? Bool ?? false {
                return timeCellHeight
            }
            if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["type"] as? String == "dyd"{
                return timeCellHeight
            }
            if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["type"] as? String == "dydfriend"{
                return timeCellHeight
            }
        }
        if dataSource.isEmotionMessageFormessageViewController?(self, messageModel: messageModel) ?? false {
            return EaseCustomMessageCell.cellHeight(messageModel)
        }
        return EaseBaseMessageCell.cellHeight(withModel: messageModel)
    }
    
       @objc func messageViewController(_ viewController: EaseMessageViewController!, didSelect messageModel: IMessageModel!) -> Bool {
        chatToolbar.endEditing(true)
        if messageModel == nil {
            return true
        }
        if let model = messageModel as? BoxinMessageModel {
            if model.urls?.count ?? 0 == 1 {
                UIApplication.shared.open(URL(string: model.urls![0])!, options: [:], completionHandler: nil)
                return true
            }
            if model.urls?.count ?? 0 > 1 {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                for url in model.urls!{
                    alert.addAction(UIAlertAction(title: url, style: .default, handler: { (a) in
                        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
                    }))
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .destructive, handler: nil))
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
                return true
            }
        }
        if UIMenuController.shared.isMenuVisible {
            UIMenuController.shared.setMenuVisible(false, animated: true)
        }
        if messageModel.message.ext != nil {
            if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["type"] as? String == "person" {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                guard let uid = messageModel.message.ext["id"] as? String else {
                    return true
                }
                if QueryFriend.shared.checkFriend(userID: uid) {
                    if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
                        for c in contact {
                            if c?.data != nil {
                                for d in c!.data! {
                                    if d?.user_id == uid {
                                        let vc = UserDetailViewController()
                                        vc.model = d
                                        vc.type=4
                                        self.navigationController?.pushViewController(vc, animated: true)
                                        return true
                                    }
                                }
                            }
                        }
                    }
                }
                let vc = UserDetailViewController()
                let data = QueryFriend.shared.queryStronger(id: uid)
                let f = FriendData()
                f.is_shield = 2
                f.is_star = 2
                f.target_user_nickname = data?.name
                f.user_id = data?.id
                f.portrait = data?.portrait
                f.id_card = data?.id_card
                vc.model = f
                self.navigationController?.pushViewController(vc, animated: true)
                focusCellClick = false
                return true
            }
            
            if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["callType"] as? String == "1"
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNOTIFICATION_MAKE1V1CALL), object: ["chatter":self.conversation.conversationId,"type":0], userInfo: nil)
                focusCellClick = false
                 return true
                
            }else if messageModel.message.body.type == EMMessageBodyTypeText && messageModel.message.ext["callType"] as? String == "2"
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNOTIFICATION_MAKE1V1CALL), object: ["chatter":self.conversation.conversationId,"type":1], userInfo: nil)
                focusCellClick = false
                return true
            }
        }
        if messageModel.bodyType == EMMessageBodyTypeImage {
            onImageCellClick(messageModel.message)
            focusCellClick = false
            return true
        }
        if messageModel.message.body.type == EMMessageBodyTypeFile {
            OpenFileGoLookMessage(message: messageModel.message)
            focusCellClick = false
            return true
        }
        if messageModel.bodyType == EMMessageBodyTypeVideo {
            playVedio(messageModel)
            focusCellClick = false
            return true
        }
        focusCellClick = false
        return false
    }
    
    func playVedio(_ message:IMessageModel) {
        let body = message.message.body as! EMVideoMessageBody
        if FileManager.default.fileExists(atPath: body.localPath) {
            let data = DCVideoData()
            data.videoURL = URL(fileURLWithPath: body.localPath)
            let browser = YBImageBrowser()
            browser.dataSourceArray = [data]
            browser.currentPage = 0
            browser.show(to: self.navigationController!.view)
        }else{
            let view = UIView(frame: self.view.bounds)
            view.backgroundColor = UIColor.clear
            view.tag = 100
            self.view.addSubview(view)
            if body.remotePath.isEmpty {
                UIApplication.shared.keyWindow?.makeToast("视频地址无效")
                return
            }
            if isDownLoading {
                return
            }
            isDownLoading = true
            SVProgressHUD.showProgress(0)
            let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            var dic = path[path.endIndex - 1]
            dic.appendPathComponent("Vedios", isDirectory: true)
            dic.appendPathComponent(UUID().uuidString, isDirectory: false)
            dic = dic.appendingPathExtension("mp4")
            BoXinProvider.request(.DownLoad(url: body.remotePath, filepath: dic.path), callbackQueue: DispatchQueue.main, progress: { (p) in
                if self.isShow {
                    SVProgressHUD.showProgress(Float(p.progress))
                }
            }) { (result) in
                if let v = self.view.viewWithTag(100) {
                    v.removeFromSuperview()
                }
                self.isDownLoading = false
                if FileManager.default.fileExists(atPath: dic.path){
                    SVProgressHUD.showSuccess(withStatus: "下载成功")
                    SVProgressHUD.dismiss(withDelay: 1.0)
                    body.localPath = dic.path
                    let msg = message.message
                    msg?.body = body
                    var err:EMError?
                    self.conversation.updateMessageChange(msg, error: &err)
                    if self.isShow {
                        let data = DCVideoData()
                        data.videoURL = dic
                        let browser = YBImageBrowser()
                        browser.dataSourceArray = [data]
                        browser.currentPage = 0
                        self.isOnPreview = true
                        browser.show(to: self.navigationController!.view)
                        SVProgressHUD.dismiss()
                    }
                }else{
                    SVProgressHUD.showError(withStatus: "下载失败")
                    SVProgressHUD.dismiss(withDelay: 1.0)
                }
            }
        }
    }
    
    func onImageCellClick(_ message:EMMessage) {
        if focusCellClick {
            if focusDataModel == nil {
                return
            }
            let images = focusDataModel!.dataArray.filter { (messagemodel) -> Bool in
                if let model = messagemodel as? IMessageModel {
                    if model.bodyType == EMMessageBodyTypeImage {
                        return true
                    }
                }
                return false
            }
            var datas = Array<DCImageData>()
            let imageCells = images as! [IMessageModel]
            var i = 0
            var index = -1
            for imageModel in imageCells {
                let data = DCImageData()
                let body = imageModel.message.body as! EMImageMessageBody
                if FileManager.default.fileExists(atPath: body.localPath) {
                    data.imageURL = URL(fileURLWithPath: body.localPath)
                }else{
                    data.imageURL = URL(string: body.remotePath)
                }
                datas.append(data)
                if imageModel.message.localTime == message.localTime {
                    index = i
                }
                i += 1
            }
            let browser = YBImageBrowser()
            browser.dataSourceArray = datas
            if index != -1 {
                browser.currentPage = index
            }else{
                browser.currentPage = 0
            }
            isOnPreview = true
            browser.show(to: self.navigationController!.view)
            return
        }
        let images = dataArray.filter { (messagemodel) -> Bool in
            if let model = messagemodel as? IMessageModel {
                if model.bodyType == EMMessageBodyTypeImage {
                    if message.ext?["isFire"] as? Int == 4 {
                        return false
                    }
                    return true
                }
            }
            return false
        }
        var datas = Array<DCImageData>()
        let imageCells = images as! [IMessageModel]
        var i = 0
        var index = -1
        for imageModel in imageCells {
            let data = DCImageData()
            let body = imageModel.message.body as! EMImageMessageBody
            if imageModel.isSender {
                if FileManager.default.fileExists(atPath: body.localPath) {
                    data.imageURL = URL(fileURLWithPath: body.localPath)
                }else{
                    data.imageURL = URL(string: body.remotePath)
                }
            }else{
                data.imageURL = URL(string: body.remotePath)
            }
            datas.append(data)
            if imageModel.message.localTime == message.localTime {
                index = i
            }
            i += 1
        }
        let browser = YBImageBrowser()
        browser.dataSourceArray = datas
        if index != -1 {
            browser.currentPage = index
        }else{
            browser.currentPage = 0
        }
        isOnPreview = true
        browser.show(to: self.navigationController!.view)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            if let msgList = self.messsagesSource as? [EMMessage] {
                DispatchQueue.global().async {
                    for msg in msgList {
                        if msg.ext?["isFired"] as? Int == 3 {
                            msg.ext?["isFired"] = 4
                            EMClient.shared()?.chatManager.update(msg, completion: nil)
                        }
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateMessage"), object: nil)
                }
            }
            EMClient.shared()?.chatManager.remove(self)
            EMClient.shared()?.roomManager.remove(self)
            onPop()
        }
    }
    
       @objc override func showMenuViewController(_ showInView: UIView!, andIndexPath indexPath: IndexPath!, messageType: EMMessageBodyType) {
        if menuController == nil {
            menuController = UIMenuController.shared
        }
        menuController.menuItems?.removeAll()
        let delete = UIMenuItem(title: "删除", action: #selector(onDelete))
        let copy = UIMenuItem(title: "复制", action: #selector(onCopy))
        let atHim = UIMenuItem(title: "@TA", action: #selector(onAtHim))
        let tackOut = UIMenuItem(title: "踢人", action: #selector(onTackOut))
        let Alldelete = UIMenuItem(title: "为全体无痕删除", action: #selector(onAllDelete))
        let zhuanfa = UIMenuItem(title: "转发", action: #selector(onSendOther))
        let Alldelete2 = UIMenuItem(title: "为对方无痕删除", action: #selector(onAllDelete))
        let addFace = UIMenuItem(title: "添加到表情", action: #selector(onAddFace))
        let collection = UIMenuItem(title: "收藏", action: #selector(onCollection))
        let model = dataArray.object(at: indexPath.row) as! BoxinMessageModel
        menuController.menuItems = []
        if messageType == EMMessageBodyTypeText {
            if isEmotionMessageFormessageViewController(self, messageModel: model) && !model.isSender {
                menuController.menuItems?.append(addFace)
            }else{
                if !model.text.isEmpty {
                    if !model.text.hasPrefix("[:voice]") && !model.text.hasPrefix("[:vedio]") && !isEmotionMessageFormessageViewController(self, messageModel: model) {
                        menuController.menuItems?.append(copy)
                    }
                }
            }
        }
        if messageType != EMMessageBodyTypeVoice {
            if messageType == EMMessageBodyTypeText {
                if !model.text.hasPrefix("[:voice]") && !model.text.hasPrefix("[:vedio]") {
                    menuController.menuItems?.append(zhuanfa)
                }
            }else{
                 menuController.menuItems?.append(zhuanfa)
            }
        }
        if !model.isGifFace {
            if messageType == EMMessageBodyTypeText {
                if !model.text.hasPrefix("[:voice]") && !model.text.hasPrefix("[:vedio]") && !isEmotionMessageFormessageViewController(self, messageModel: model) {
                    menuController.menuItems?.append(collection)
                }
            }else{
                menuController.menuItems?.append(collection)
            }
        }
        menuController.menuItems?.append(delete)
        if conversation.type == EMConversationTypeGroupChat {
            let userModel = model
            if !userModel.isSender {
                menuController.menuItems?.append(atHim)
            }
            if groupModel?.is_admin == 1 {
                if userModel.message.direction != EMMessageDirectionReceive {
                    menuController.menuItems?.append(Alldelete)
                }else{
                    menuController.menuItems?.append(Alldelete)
                    menuController.menuItems?.append(tackOut)
                }
            }
            if groupModel?.is_menager == 1 {
                if userModel.message.direction != EMMessageDirectionReceive {
                    menuController.menuItems?.append(Alldelete)
                }else{
                    if userModel.member?.is_manager == 2 && userModel.member?.is_administrator == 2 {
                        menuController.menuItems?.append(Alldelete)
                        menuController.menuItems?.append(tackOut)
                    }
                }
            }
        }
        if conversation.type == EMConversationTypeChat
        {
             let userModel = model as! BoxinMessageModel
            if userModel.message.direction != EMMessageDirectionReceive
            {
                 menuController.menuItems?.append(Alldelete2 )
            }else
            {
                 menuController.menuItems?.append(Alldelete2)
            }
        }
        menuController.setTargetRect(showInView.frame, in: showInView.superview!)
        menuController.setMenuVisible(true, animated: true)

    }
    
    @objc func onSendOther(){
        if menuIndexPath == nil {
            return
        }
        if menuIndexPath.row >= 0{
            let mmodel = dataArray.object(at: menuIndexPath.row) as! IMessageModel
            let vc = SendOtherViewController()
            vc.message = mmodel.message
            vc.IastId = conversation.conversationId
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        menuIndexPath = nil
    }
    
    @objc func onCollection() {
        if menuIndexPath == nil {
            return
        }
        if menuIndexPath.row >= 0{
            let mmodel = dataArray.object(at: menuIndexPath.row) as! IMessageModel
            if let msg = EMMessage(conversationID: "收藏", from: EMClient.shared()?.currentUsername, to: "收藏", body: mmodel.message.body, ext: mmodel.message.ext) {
                SVProgressHUD.show()
                if mmodel.bodyType == EMMessageBodyTypeVoice {
                    downloadFile(msg) { (a) in
                        if let body = msg.body as? EMVoiceMessageBody {
                            DispatchQueue.main.async {
                                self.uploadFile(msg) { (a) in
                                    self.messageQueue.async {
                                        self.collection(msg)
                                    }
                                }
                            }
                        }
                    }
                    return
                }
                if mmodel.bodyType == EMMessageBodyTypeImage {
                    downloadFile(msg) { (a) in


                        if let body = msg.body as? EMImageMessageBody {
                            DispatchQueue.main.async {
                                self.uploadFile(msg) { (a) in
                                    self.messageQueue.async {
                                        self.collection(msg)
                                    }
                                }
                            }
                        }
                    }
                    return
                }
                if mmodel.bodyType == EMMessageBodyTypeFile {
                    downloadFile(msg) { (a) in
                        if let body = msg.body as? EMFileMessageBody {
                            if body.displayName.isEmpty {
                                DispatchQueue.main.async {
                                    self.view.makeToast("文件格式错误")
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                self.uploadFile(msg) { (a) in
                                    self.messageQueue.async {
                                        self.collection(msg)
                                    }
                                }
                            }
                            return
                        }
                    }
                    return
                }
                if mmodel.bodyType == EMMessageBodyTypeVideo {
                    downloadFile(msg) { (a) in
                        if let body = msg.body as? EMVideoMessageBody {
                            DispatchQueue.main.async {
                                self.uploadFile(msg) { (a) in
                                    self.messageQueue.async {
                                        self.collection(msg)
                                    }
                                }
                            }
                            return
                        }
                    }
                    return
                }
                collection(msg)
            }
        }
        menuIndexPath = nil
    }
    
    @objc func onAddFace(){
        if menuIndexPath == nil {
            return
        }
        if menuIndexPath.row >= 0 {
            if isloading {
                return
            }
            self.isloading = true
            let mmodel = dataArray.object(at: menuIndexPath.row) as! IMessageModel
            let model = SaveImageForFace()
            model.type = 2
            model.phiz_name = mmodel.message.ext!["jpzim_big_expression_path"] as? String
            model.width = mmodel.message.ext?["faceW"] as? String
            model.high = mmodel.message.ext?["faceH"] as? String
            BoXinProvider.request(.SaveImageForFace(model: model), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
                switch(result){
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = AddFaceReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.isloading = false
                                    let m = FaceViewModel()
                                    m.id = model.data?.phiz_id
                                    m.url = model.data?.phiz_url
                                    QueryFriend.shared.AddFace(id: model.data!.phiz_id!)
                                    QueryFriend.shared.updateFace(model: m)
                                    NotificationCenter.default.post(Notification(name: Notification.Name("onEmojiChanged")))
                                    DispatchQueue.main.async {
                                        SVProgressHUD.dismiss()
                                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("AddSuccessed", comment: "Add successed"))
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
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                    self.isloading = false
                                    self.view.makeToast(model.message)
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                self.isloading = false
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            self.isloading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        self.isloading = false
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    self.isloading = false
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @objc func onAllDelete()
    {
        if menuIndexPath.row >= 0 {
            let model = dataArray.object(at: menuIndexPath.row) as! IMessageModel
            let body = EMCmdMessageBody(action: "")
            if model.message?.chatType == EMChatTypeChat
            {
                var ext = ["type":"personMSG","msgid":model.messageId]
                ext["userid"] = model.message.from
                if model.isSender {
                    EMClient.shared()?.chatManager.recall(model.message, completion: { (m, e) in
                        if e != nil {
                            print(e?.errorDescription)
                        }
                    })
                }
                let msg = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: ext as [AnyHashable : Any])
                EMClient.shared()?.chatManager.send(msg!, progress: { (p) in
                    
                }, completion: { (m, e) in
                    if e != nil {
                        SVProgressHUD.showError(withStatus: "超过24小时的无法删除")
                        SVProgressHUD.dismiss(withDelay: 1.0)
                        print(e?.errorDescription)
                    }else{
                        self._Delete(withMessageID: model.messageId, text: "", isDelete: true)
                        DispatchQueue.main.async {
                            UIApplication.shared.keyWindow?.makeToast("撤回成功")
                        }
                    }
                })
            }
            if model.message?.chatType == EMChatTypeGroupChat{
                recallNotificationServer(model.messageId)
                var ext = ["type":"deleteMSG","msgid":model.messageId]
                ext["userid"] = model.message.from
                ext["isDelete"] = "1"
                ext["id"] = conversation.conversationId
                if model.isSender {
                    EMClient.shared()?.chatManager.recall(model.message, completion: { (m, e) in
                        if e != nil {
                            print(e?.errorDescription)
                        }
                    })
                }
                let msg = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: ext as [AnyHashable : Any])
                msg?.chatType = EMChatTypeGroupChat
                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                    
                }, completion: { (msg, err) in
                    if err != nil {
                        SVProgressHUD.showError(withStatus: "超过24小时的无法删除")
                        SVProgressHUD.dismiss(withDelay: 1.0)
                        print(err?.errorDescription)
                    }else
                    {
                        self._Delete(with: model.message!, text: "", isDelete: true)
                        DispatchQueue.main.async {
                            UIApplication.shared.keyWindow?.makeToast("撤回成功")
                        }
                    }
                })
                return
            }
            
        }
        menuIndexPath = nil
    }
    
    @objc func onDelete() {
        if menuIndexPath == nil {
            return
        }
        if menuIndexPath.row > 0 {
            let model = dataArray.object(at: menuIndexPath.row) as! IMessageModel
            var index:IndexSet = IndexSet(integer: menuIndexPath.row)
            var indexPaths:[IndexPath] = Array(arrayLiteral: menuIndexPath)
            var err:EMError?
            conversation.deleteMessage(withId: model.messageId, error: &err)
            messsagesSource.remove(model.message as Any)
            if menuIndexPath.row - 1 >= 0 {
                var nextMessage:Any? = nil
                let prevMessage = dataArray.object(at: menuIndexPath.row - 1)
                if menuIndexPath.row + 1 < dataArray.count {
                    nextMessage = dataArray.object(at: menuIndexPath.row + 1)
                }
                if ((nextMessage == nil) && (prevMessage is String)) || ((nextMessage is String) && (prevMessage is String)) {
                    index.insert(menuIndexPath.row - 1)
                    indexPaths.append(IndexPath(row: menuIndexPath.row - 1, section: 0))
                }
            }
            dataArray.removeObjects(at: index)
            tableView.beginUpdates()
            tableView.deleteRows(at: indexPaths, with: .top)
            tableView.endUpdates()
        }
        menuIndexPath = nil
    }
    
    @objc func onCopy() {
        if menuIndexPath == nil {
            return
        }
        let pastBoard = UIPasteboard.general
        if menuIndexPath.row > 0 {
            let model = dataArray.object(at: menuIndexPath.row) as! IMessageModel
            pastBoard.string = model.text
        }
        menuIndexPath = nil
    }
    
    @objc func onAtHim() {
        if menuIndexPath == nil {
            return
        }
        let chatbar = chatToolbar as! EaseChatToolbar
        if atList == nil {
            atList = Array<GroupAtModel?>()
        }
        if let member = (dataArray[menuIndexPath.row] as? BoxinMessageModel)?.member {
            let model = GroupAtModel()
            model.model = member
            model.start = chatbar.inputTextView.text.count
            model.lenth = (member.user_name?.count ?? 0) + 2
            atList?.append(model)
            chatbar.inputTextView.text += String(format: "@%@ ", member.user_name ?? "")
        }else{
            let messageModel = dataArray[menuIndexPath.row] as? BoxinMessageModel
            BoXinUtil.getGroupOneMember(groupID: conversation.conversationId, userID: messageModel!.message.from) { (b) in
                if b {
                    if let member = QueryFriend.shared.getGroupUser(userId: messageModel!.message.from, groupId: self.conversation.conversationId) {
                        let model = GroupAtModel()
                        model.model = member
                        model.start = chatbar.inputTextView.text.count
                        model.lenth = (member.user_name?.count ?? 0) + 2
                        self.atList?.append(model)
                        chatbar.inputTextView.text += String(format: "@%@ ", member.user_name ?? "")
                    }
                }
            }
        }
        menuIndexPath = nil
    }
    
    @objc func onTackOut() {
        if menuIndexPath == nil {
            return
        }
        onMoveOut(indexPath: menuIndexPath)
        menuIndexPath = nil
    }
    
    func recallNotificationServer(_ id:String) {
        DispatchQueue.global().async {
            let model = SaveRevokeMessageRecordSendModel()
            model.group_id = self.conversation.conversationId
            model.message_id = id
            BoXinProvider.request(.SaveRevokeMessageRecord(model: model)) { (r) in
                
            }
        }
    }
    
    override func moreViewPhotoAction(_ moreView: EaseChatBarMoreView!) {
        chatToolbar.endEditing(true)
        isOnPreview = true
        imagePickAction(moreView)
        self.isViewDidAppear = false
        EaseSDKHelper.share()?.isShowingimagePicker = true
    }
    
    override func moreViewTakePicAction(_ moreView: EaseChatBarMoreView!) {
        chatToolbar.endEditing(true)
        isOnPreview = true
        takePicAction(moreView)
        self.isViewDidAppear = false
        EaseSDKHelper.share()?.isShowingimagePicker = true
    }
    
    override func moreViewLiveAction(_ moreView: EaseChatBarMoreView!) {
        isOnPreview = true
        super.moreViewLiveAction(moreView)
    }
    
    override func moreViewLocationAction(_ moreView: EaseChatBarMoreView!) {
        isOnPreview = true
        super.moreViewLocationAction(moreView)
    }
    
    override func moreViewAudioCallAction(_ moreView: EaseChatBarMoreView!) {
        isOnPreview = true
        super.moreViewAudioCallAction(moreView)
    }
    
    override func moreViewVideoCallAction(_ moreView: EaseChatBarMoreView!) {
        isOnPreview = true
        super.moreViewVideoCallAction(moreView)
    }
    
    func takePicAction(_ moreView: EaseChatBarMoreView!) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.view.makeToast("无法使用相机")
            return
        }
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            DispatchQueue.main.async {
                if granted {
                    let m = HXPhotoManager()
                    m.type = .photoAndVideo
                    m.configuration.videoMaximumDuration = 10
                    m.configuration.themeColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
                    m.configuration.sessionPreset = "AVCaptureSessionPreset1280x720"
                    let vc = HXCustomCameraViewController()
                    vc.manager = m
                    vc.delegate = self
                    vc.isOutside = true
                    let nav = HXCustomNavigationController(rootViewController: vc)
                    nav.isCamera = true
                    nav.supportRotation = false
                    nav.modalPresentationStyle = .overFullScreen
                    self.present(nav, animated: true, completion: nil)
                }else{
                    self.view.makeToast("无法使用相机")
                }
            }
        }
    }
    
    func imagePickAction(_ moreView: EaseChatBarMoreView!) {
        let vc = HXAlbumListViewController()
        let m = HXPhotoManager()
        m.configuration.cameraCellShowPreview = false
        m.configuration.downloadICloudAsset = true
        m.configuration.openCamera = false
        m.configuration.lookGifPhoto = true
        m.configuration.lookLivePhoto = false
        m.type = .photoAndVideo
        m.configuration.saveSystemAblum = false
        m.configuration.supportRotation = false
        m.configuration.photoMaxNum = 9
        m.configuration.videoMaxNum = 1
        m.configuration.maxNum = 9
        m.configuration.hideOriginalBtn = false
        m.configuration.photoCanEdit = false
        m.configuration.videoCanEdit = false
        m.configuration.specialModeNeedHideVideoSelectBtn = true
        m.configuration.navBarBackgroudColor = UIColor.hexadecimalColor(hexadecimal: "F7F6F6")
        m.configuration.navigationTitleColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
        m.configuration.themeColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
        m.configuration.videoMaximumSelectDuration = 300
        m.configuration.showDateSectionHeader = false
        vc.manager = m
        vc.delegate = self
        let nav = HXCustomNavigationController(rootViewController: vc)
        nav.supportRotation = false
        nav.navigationBar.tintColor = UIColor.white
        nav.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController()?.present(nav, animated: true, completion: nil)
    }
    
    func albumListViewController(_ albumListViewController: HXAlbumListViewController!, didDoneAllList allList: [HXPhotoModel]!, photos photoList: [HXPhotoModel]!, videos videoList: [HXPhotoModel]!, original: Bool) {
        albumListViewController.dismiss(animated: true, completion: nil)
        self.isViewDidAppear = true
        EaseSDKHelper.share()?.isShowingimagePicker = false
        for photo in photoList {
            let imageRequestOption = PHImageRequestOptions()
            // PHImageRequestOptions是否有效
            imageRequestOption.isSynchronous = true
            // 缩略图的压缩模式设置为无
            imageRequestOption.resizeMode = .none
            imageRequestOption.deliveryMode = .highQualityFormat
            if photo.asset?.isGIF ?? false {
                PHImageManager.default().requestImageData(for: photo.asset!, options: imageRequestOption) { (gifdata, name, org, ext) in
                    let message = EaseSDKHelper.getImageMessage(withImageData: gifdata, to: self.conversation.conversationId, messageType: self._messageTypeFromConversationType(), messageExt: [:])
                    let body = message?.body as! EMImageMessageBody
                    body.compressionRatio = 1
                    message?.body = body
                    self.send(message, isNeedUploadFile: true)
                }
            }else{
                imageRequestOption.deliveryMode = .highQualityFormat
                photo.requestImage(with: imageRequestOption, targetSize: PHImageManagerMaximumSize) { (image, ext) in
                    guard let img = image else {
                        if let pimg = photo.previewPhoto {
                            let message = EaseSDKHelper.getImageMessage(with: pimg, to: self
                                .conversation.conversationId, messageType: self._messageTypeFromConversationType(), messageExt: [:])
                            if original {
                                let body = message?.body as! EMImageMessageBody
                                body.compressionRatio = 1
                                message?.body = body
                            }
                            self.send(message, isNeedUploadFile: true)
                        }
                        return
                    }
                    let message = EaseSDKHelper.getImageMessage(with: img, to: self
                        .conversation.conversationId, messageType: self._messageTypeFromConversationType(), messageExt: [:])
                    if original {
                        let body = message?.body as! EMImageMessageBody
                        body.compressionRatio = 1
                        message?.body = body
                    }
                    self.send(message, isNeedUploadFile: true)
                }
            }
        }
        
        for v in videoList {
            v.exportVideo(withPresetName: AVAssetExportPreset640x480, startRequestICloud: nil, iCloudProgressHandler: nil, exportProgressHandler: { (p, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.showProgress(p)
                }
            }, success: { (url, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                var size:UInt64 = 0
                do{
                    let obj = try FileManager.default.attributesOfItem(atPath: url!.path)
                    size = (obj[.size] as? UInt64)!
                }catch(let e){
                    print(e.localizedDescription)
                }
                if size / 1024 / 1024 >= 10 {
                    DispatchQueue.main.async {
                        UIApplication.shared.keyWindow?.makeToast("视频大于10M不能发送");
                    }
                    return
                }
                self.sendVideoMessage(with: url!)
            }) { (ext, m) in
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.makeToast("获取视频失败");
                }
            }
        }
    }
    
    func customCameraViewController(_ viewController: HXCustomCameraViewController!, didDone model: HXPhotoModel!) {
        viewController.dismiss(animated: true, completion: nil)
        if model.type == .cameraPhoto {
            if let p = model.previewPhoto {
                let message = EaseSDKHelper.getImageMessage(with: p, to: self.conversation.conversationId, messageType: self._messageTypeFromConversationType(), messageExt: [:])
                let body = message?.body as! EMImageMessageBody
                body.compressionRatio = 1
                message?.body = body
                self.send(message, isNeedUploadFile: true)
                return
            }
        }
        if model.type == .cameraVideo {
            model.exportVideo(withPresetName: AVAssetExportPreset640x480, startRequestICloud: nil, iCloudProgressHandler: nil, exportProgressHandler: { (p, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.showProgress(p)
                }
            }, success: { (url, m) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                var size:UInt64 = 0
                do{
                    let obj = try FileManager.default.attributesOfItem(atPath: url!.path)
                    size = (obj[.size] as? UInt64)!
                }catch(let e){
                    print(e.localizedDescription)
                }
                if size / 1024 / 1024 >= 10 {
                    DispatchQueue.main.async {
                        UIApplication.shared.keyWindow?.makeToast("视频大于10M不能发送");
                    }
                    return
                }
                self.sendVideoMessage(with: url!)
            }) { (ext, m) in
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.makeToast("获取视频失败");
                }
            }
        }
        self.isViewDidAppear = true
        EaseSDKHelper.share()?.isShowingimagePicker = false
    }
    
    func customCameraViewControllerDidCancel(_ viewController: HXCustomCameraViewController!) {
        self.isViewDidAppear = true
        EaseSDKHelper.share()?.isShowingimagePicker = false
    }
    
    func albumListViewControllerDidCancel(_ albumListViewController: HXAlbumListViewController!) {
        self.isViewDidAppear = true
        EaseSDKHelper.share()?.isShowingimagePicker = false
    }
    
    override func customDownloadVedioFile(_ aMessage: EMMessage!) {
        if let body = aMessage.body as? EMVideoMessageBody {
            if body.thumbnailLocalPath != nil && FileManager.default.fileExists(atPath: body.thumbnailLocalPath) {
                body.thumbnailDownloadStatus = EMDownloadStatusSucceed
                aMessage.body = body
                DispatchQueue.main.async {
                    super.customDownloadVedioFile(aMessage)
                }
            }
            if body.thumbnailRemotePath == nil {
                return
            }
            let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            var dic = path[path.endIndex - 1]
            dic.appendPathComponent("VedioTemp", isDirectory: true)
            dic.appendPathComponent(((body.thumbnailRemotePath ?? "temp") as NSString).lastPathComponent, isDirectory: false)
            BoXinProvider.request(.DownLoad(url: body.thumbnailRemotePath, filepath: dic.path)) { (_) in
                if FileManager.default.fileExists(atPath: dic.path) {
                    body.thumbnailLocalPath = dic.path
                    body.thumbnailDownloadStatus = EMDownloadStatusSucceed
                    aMessage.body = body
                    DispatchQueue.main.async {
                        super.customDownloadVedioFile(aMessage)
                    }
                }
            }
        }
    }
    
       @objc func messageViewController(_ viewController: EaseMessageViewController!, didSelect moreView: EaseChatBarMoreView!, at index: Int) {
//        if index == 0 {
//            imagePickAction(moreView)
//        }
        if conversation.type == EMConversationTypeChat {
            if conversation.conversationId == "ef1569ada7ab4c528375994e0de246ca" || conversation.conversationId == "2290120c5be7424082216dc8d98179a4" {
                isOnPreview = true
                self.moreViewFileTransferAction(moreView)
                return
            }
            if index == 5 {
                isOnPreview = true
                self.moreViewFileTransferAction(moreView)
            }
            if index == 6
            {
                
                    chatToolbar.endEditing(true)
                    let alert = UIAlertController(title: "温馨提示", message: "您是否要抖一抖吗？", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (a) in
                        
                        let normalbody = EMTextMessageBody(text:"抖好友上线")

                        let textmsg = EMMessage(conversationID: self.conversation.conversationId, from: EMClient.shared()?.currentUsername, to: self.conversation.conversationId, body: normalbody, ext: ["type":"dydfriend","id":EMClient.shared()?.currentUsername,"em_recall":true])
                        textmsg?.chatType = EMChatTypeChat

                        EMClient.shared()?.chatManager.send(textmsg, progress: { (p) in
                            
                        }, completion: { (msg, err) in
                            if err != nil {
                                print(err?.errorDescription)
                            }
                            self.messsagesSource.add(textmsg)
                            self.dataArray.add(self.messageViewController(self, modelFor: textmsg))
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        })
                        
                        
                        let body = EMCmdMessageBody(action: "")
                        let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
                        let msg = EMMessage(conversationID: self.conversation.conversationId, from: EMClient.shared()?.currentUsername, to: self.conversation.conversationId, body: body, ext: ["type":"dydfriend","id":EMClient.shared()?.currentUsername,"name":data?.db?.user_name])
                        msg?.chatType = EMChatTypeChat
                        EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                            
                        }, completion: { (msg, err) in
                            if err != nil {
                                print(err?.errorDescription)
                            }else{
                                self.view.makeToast("已成功发送")
                            }
                        })
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
                alert.modalPresentationStyle = .overFullScreen
                    self.present(alert, animated: true, completion: nil)
            
            }
        }
        if conversation.type == EMConversationTypeGroupChat {
            if index == 3 {
                isOnPreview = true
                self.moreViewFileTransferAction(moreView)
            }
            if index == 4 {
                chatToolbar.endEditing(true)
               let alert = UIAlertController(title: "温馨提示", message: "您确定抖所有人吗？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (a) in
                    self.me = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
                    let normalbody = EMTextMessageBody(text: String(format: "%@抖所有人上线", self.groupModel?.is_admin == 1 ? "群主" : "管理员"))
                    let textmsg = EMMessage(conversationID: self.conversation.conversationId, from: EMClient.shared()?.currentUsername, to: self.conversation.conversationId, body: normalbody, ext: ["type":"dyd","id":self.conversation.conversationId,"groupname":self.groupModel?.groupName,"adminname":self.me?.user_name,"grade":self.groupModel?.is_admin == 1 ? 1 : 2,"em_recall":true])
                    textmsg?.chatType = EMChatTypeGroupChat
                    EMClient.shared()?.chatManager.send(textmsg, progress: { (p) in
                        
                    }, completion: { (msg, err) in
                        if err != nil {
                            print(err?.errorDescription)
                        }
                        self.messsagesSource.add(textmsg)
                        self.dataArray.add(self.messageViewController(self, modelFor: textmsg))
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
                    let body = EMCmdMessageBody(action: "")
                    let msg = EMMessage(conversationID: self.conversation.conversationId, from: EMClient.shared()?.currentUsername, to: self.conversation.conversationId, body: body, ext: ["type":"dyd","id":self.conversation.conversationId,"groupname":self.groupModel?.groupName,"adminname":self.me?.user_name,"grade":self.groupModel?.is_admin == 1 ? 1 : 2])
                    msg?.chatType = EMChatTypeGroupChat
                    EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                        
                    }, completion: { (msg, err) in
                        if err != nil {
                            print(err?.errorDescription)
                        }else{
                            self.view.makeToast("已成功发送")
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
       @objc override func send(_ message: EMMessage!, isNeedUploadFile isUploadFile: Bool) {
        if message.ext != nil {
            if message.ext["NoSend"] as? String == "1" {
                return
            }
            if message.ext["jpzim_is_big_expression"] as? Int == 1 {
                message.body = EMTextMessageBody(text: "[自定义表情]")
            }
        }
        if conversation.type == EMConversationTypeGroupChat {
            if me?.is_shield == 1 && me?.is_manager == 2 && me?.is_administrator == 2 {
                self.chatToolbar.endEditing(true)
                self.view.makeToast("你已被禁言")
                return
            }else{
                if me?.is_manager == 2 && me?.is_administrator == 2 {
                    if groupModel?.is_all_banned == 1 {
                        self.ChangeMuteble(mute: true)
                        self.chatToolbar.endEditing(true)
                        self.view.makeToast("全员禁言中")
                        return
                    }
                    conversation.loadMessagesStart(fromId: nil, count: 100, searchDirection: EMMessageSearchDirectionUp) { (m, e) in
                        if m == nil
                        {
                            message.ext = self.setupMSGext(message: message)
                            if message.body.type == EMMessageBodyTypeText {
                                let body = message.body as! EMTextMessageBody
                                message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
                            }
                            super.send(message, isNeedUploadFile: isUploadFile)
                            return
                        }
                        if m!.count < 10
                        {
                            message.ext = self.setupMSGext(message: message)
                            if message.body.type == EMMessageBodyTypeText {
                                let body = message.body as! EMTextMessageBody
                                message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
                            }
                            super.send(message, isNeedUploadFile: isUploadFile)
                            return
                        }
                        var msgs = m as! [EMMessage]
                        msgs = msgs.filter({ (ms) -> Bool in
                            return ms.from == self.data!.db!.user_id!
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
                            print("\(a.localTime) and\(b.localTime)")
                            return a.localTime > b.localTime
                        })
                        if msgs.count > 9 {
                            if NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970InMilliSecond() - Double(msgs[9].timestamp) > 60 * 1000 {
                                message.ext = self.setupMSGext(message: message)
                                if message.body.type == EMMessageBodyTypeText {
                                    let body = message.body as! EMTextMessageBody
                                    message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
                                }
                                super.send(message, isNeedUploadFile: isUploadFile)
                            }else{
                                self.chatToolbar.endEditing(true)
                                self.view.makeToast("60秒内只可以发10条消息")
                            }
                        }else{
                            message.ext = self.setupMSGext(message: message)
                            if message.body.type == EMMessageBodyTypeText {
                                let body = message.body as! EMTextMessageBody
                                message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
                            }
                            super.send(message, isNeedUploadFile: isUploadFile)
                        }
                    }
                    return
                }
            }
        }
        if message.body.type == EMMessageBodyTypeText {
            let body = message.body as! EMTextMessageBody
            message.body = EMTextMessageBody(text: String(format: "%@_encode", DCEncrypt.Encoade_AES(strToEncode: body.text)))
        }
        message.ext = setupMSGext(message: message)
        super.send(message, isNeedUploadFile: isUploadFile)
        
    }
    
    func setupMSGext(message:EMMessage) -> [AnyHashable:Any]? {
        var ext = message.ext
        if self.atList != nil {
            var at = Array<String?>()
            for m in self.atList! {
                at.append(m?.model?.user_id)
            }
            if ext == nil {
                ext = ["em_at_list":at]
            }else{
                ext?["em_at_list"] = at
            }
            self.atList = nil
        }
        if isAtAll {
            if ext == nil
            {
                ext = ["em_at_list":"ALL"]
            }else
            {
                ext?["em_at_list"] = "ALL"
            }
            self.isAtAll = false
            self.atAllStart = -1
        }
        if ext == nil {
            ext = ["em_apns_ext":"{em_oppo_push_channel_id:\"chuangliao_notification\"}"]
        }else{
            ext?["em_apns_ext"] = "{em_oppo_push_channel_id:\"chuangliao_notification\"}"
        }
        ext?["JPZIsFrom"] = conversation.type == EMConversationTypeChat ? "Chat" : "GroupChat"
        ext?["JPZUserPortrait"] = data?.db?.portrait
        ext?["JPZUserNikeName"] = data?.db?.user_name
        if conversation.type == EMConversationTypeChat && friend == nil {
            let dat = QueryFriend.shared.queryStronger(id: conversation.conversationId)
            ext?["JPZReceivePortrait"] = dat?.portrait
            ext?["JPZReceiveNikeName"] = dat?.name
        }else{
            ext?["JPZReceivePortrait"] = conversation.type == EMConversationTypeChat ? friend?.portrait : groupModel?.portrait
            ext?["JPZReceiveNikeName"] = conversation.type == EMConversationTypeChat ? friend?.friend_self_name : groupModel?.groupName
        }
        ext?["isFired"] = friend?.is_yhjf ?? 0
        return ext
    }
    
       @objc func ChangeMuteble(mute:Bool) {
        if groupModel?.is_admin == 1 || groupModel?.is_menager == 1 {
            DispatchQueue.main.async {
                let chatbar =  self.chatToolbar as! EaseChatToolbar
                chatbar.showVoiceStyleButton(true)
                if self.muteBar != nil {
                    for v in self.muteBar!.subviews {
                        v.removeFromSuperview()
                    }
                    self.muteBar?.removeFromSuperview()
                }
                self.muteBar = nil
                if self.chatToolbar != nil {
                    self.chatToolbar.endEditing(true)
                    self.chatToolbar.isHidden = false
                }
            }
            return
        }
        let chatbar =  self.chatToolbar as! EaseChatToolbar
        chatbar.showVoiceStyleButton(false)
        if mute {
            if muteBar != nil {
                return
            }
            if chatToolbar != nil {
                chatToolbar.endEditing(true)
                chatToolbar.isHidden = true
                muteBar = MuteView(frame: chatToolbar.frame)
            }else{
                muteBar = MuteView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            }
            DispatchQueue.main.async {
                self.view.addSubview(self.muteBar!)
                if self.chatToolbar != nil {
                    self.chatToolbar.endEditing(true)
                }
                self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - EaseChatToolbar.defaultHeight() - (UIScreen.main.bounds.height >= 812 ? 34 : 0))
                self.muteBar?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                    make?.top.equalTo()(self.tableView.mas_bottom)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                    make?.bottom.equalTo()(self.view.mas_bottom)
                })
            }
        }else{
            DispatchQueue.main.async {
                if self.muteBar != nil {
                    for v in self.muteBar!.subviews {
                        v.removeFromSuperview()
                    }
                    self.muteBar?.removeFromSuperview()
                }
                self.muteBar = nil
                if self.chatToolbar != nil {
                    self.chatToolbar.endEditing(true)
                    self.chatToolbar.isHidden = false
                }
            }
        }
    }

       @objc func onMoveOut(indexPath:IndexPath) {
        let md = self.dataArray![indexPath.row] as! BoxinMessageModel
        if md.member == nil {
            let alert = UIAlertController(title: nil, message: "该用户已不在群中", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: "确定要移除TA吗？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (a) in
            let  model = AddBatchSendModel()
            model.group_id = self.groupModel?.groupId
            model.group_user_ids = md.member!.user_id
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
                                    BoXinUtil.getGroupMember(groupID: self.groupModel!.groupId!, Complite: { (b) in
                                        
                                        if b {
                                            let body = EMCmdMessageBody(action: "")
                                            var dic = ["type":"qun","id":self.groupModel!.groupId!]
                                            var err:EMError?
                                            let group = EMClient.shared()?.groupManager.getGroupSpecificationFromServer(withId: self.groupModel!.groupId!, error: &err)
                                            if group!.muteList.count > 0 {
                                                dic.updateValue("2", forKey: "grouptype")
                                            }else{
                                                dic.updateValue("1", forKey: "grouptype")
                                            }
                                            let msg = EMMessage(conversationID: self.groupModel!.groupId!, from: EMClient.shared()?.currentUsername, to: self.groupModel!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                            msg?.chatType = EMChatTypeGroupChat
                                            EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                
                                            }, completion: { (msg, err) in
                                                if err != nil {
                                                    print(err?.errorDescription)
                                                }
                                                
                                            })
                                            self.onUpdate()
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
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                    self.view.makeToast(model.message)
                                }
                            }else{
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }catch{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }else{
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                case .failure(let err):
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
        alert.modalPresentationStyle = .overFullScreen
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onUpdate() {
        DispatchQueue.main.async {
            guard let userId = self.data?.db?.user_id else {
                return
            }
            self.me = QueryFriend.shared.getGroupUser(userId: userId, groupId: self.conversation.conversationId)
            self.groupModel = QueryFriend.shared.queryGroup(id: self.conversation.conversationId)
            self.updateFocus()
            if self.groupModel?.is_all_banned == 1 {
                self.ChangeMuteble(mute: true)
            }
            if self.groupModel?.is_all_banned == 2 {
                self.ChangeMuteble(mute: false)
            }
            weak var weakSelf = self
            if self.groupModel?.is_admin == 1 || self.groupModel?.is_menager == 1 {
                if self.chatBarMoreView.getButtonCount() == 3 {
                    DispatchQueue.main.async {
                        weakSelf?.chatBarMoreView.insertItem(with: UIImage(named: "抖一抖"), highlightedImage: UIImage(named: "抖一抖"), title: "抖一抖")
                    }
                }
            }else{
                if self.chatBarMoreView.getButtonCount() == 4 {
                    DispatchQueue.main.async {
                        weakSelf?.chatBarMoreView.removeItematIndex(4)
                    }
                }
            }
        }
    }
    
    @objc func onSuccImage(Noti:Notification)
    {
        let name = Noti.object as? String
        if name != nil
        {
            if isloading {
                return
            }
            self.isloading = true
            let  model = SaveImageForFace()
            model.phiz_name = name
            
            
            BoXinProvider.request(.SaveImageForFace(model: model)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.isloading = false
                                    SVProgressHUD.showSuccess(withStatus: NSLocalizedString("AddSuccessed", comment: "Add successed"))
                                    SVProgressHUD.dismiss(withDelay: 1.0)
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
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                    self.isloading = false
                                    self.view.makeToast(model.message)
                                }
                                
                            }else{
                                self.isloading = false
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                            
                        }catch{
                            self.isloading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }else{
                        self.isloading = false
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                case .failure(let err):
                    self.isloading = false
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                }
                
            }
            
        }
    }
    
    func FocusDelete(_ recall: EMMessage) {
        if focusDataModel != nil {
            weak var weakSelf = self
            messageQueue.async {
                guard weakSelf?.focusDataModel !=  nil else {
                    return
                }
                for (idx,obj) in (weakSelf?.focusDataModel!.messageDatasource as! [EMMessage]).enumerated() {
                    if obj.messageId == recall.messageId {
                        weakSelf?.focusDataModel?.messageDatasource.remove(at: idx)
                    }
                }
                for (idx,obj) in weakSelf!.focusDataModel!.dataArray.enumerated() {
                    if let msg = obj as? EMMessage {
                        if msg.messageId == recall.messageId {
                            weakSelf?.focusDataModel?.dataArray.remove(at: idx)
                            if idx > 0 {
                                if weakSelf?.focusDataModel?.dataArray[idx-1] is String {
                                    weakSelf?.focusDataModel?.dataArray.remove(at: idx-1)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    weakSelf?.focusTabview?.reloadData()
                }
            }
        }
    }
    
    func FocusDelete(_ id:String) {
        if focusDataModel != nil {
            weak var weakSelf = self
            messageQueue.async {
                guard weakSelf?.focusDataModel !=  nil else {
                    return
                }
                for (idx,obj) in (weakSelf?.focusDataModel!.messageDatasource as! [EMMessage]).enumerated() {
                    if obj.messageId == id {
                        weakSelf?.focusDataModel?.messageDatasource.remove(at: idx)
                    }
                }
                for (idx,obj) in weakSelf!.focusDataModel!.dataArray.enumerated() {
                    if let msg = obj as? EMMessage {
                        if msg.messageId == id {
                            weakSelf?.focusDataModel?.dataArray.remove(at: idx)
                            if idx > 0 {
                                if weakSelf?.focusDataModel?.dataArray[idx-1] is String {
                                    weakSelf?.focusDataModel?.dataArray.remove(at: idx-1)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    weakSelf?.focusTabview?.reloadData()
                }
            }
        }
    }
    
    override func messagesDidRecall(_ aMessages: [Any]!) {
        guard let recallMsgs = aMessages as? [EMMessage] else {
            return
        }
        for recall in recallMsgs {
            if recall.conversationId == conversation.conversationId {
                _Delete(with: recall, text: "", isDelete: true)
            }
            FocusDelete(recall)
        }
    }
    
    override func cmdMessagesDidReceive(_ aCmdMessages: [Any]!) {
        for cmd in aCmdMessages as! [EMMessage] {
            if cmd.conversationId == conversation.conversationId {
                let cmdbody = cmd.body as! EMCmdMessageBody
//                if conversation.type == EMConversationTypeGroupChat {
//                    if cmdbody.action == "TypingBegin" {
//                        var needAdd = true
//                        for username in groupInputList {
//                            if username == cmd.from {
//                                needAdd = false
//                            }
//                        }
//                        if needAdd {
//                            groupInputList.append(cmd.from)
//                        }
//                        var text = ""
//                        for username in groupInputList {
//                            if let data = QueryFriend.shared.getGroupUser(userId: username, groupId: cmd.conversationId) {
//                                if QueryFriend.shared.checkFriend(userID: username) {
//                                    if data.friend_name?.isEmpty ?? true {
//                                        text += String(format: "%@ ", data.user_name!)
//                                    }else{
//                                        text += String(format: "%@ ", data.friend_name!)
//                                    }
//                                }else{
//                                    if data.group_user_nickname?.isEmpty ?? true {
//                                        text += String(format: "%@ ", data.user_name!)
//                                    }else{
//                                        text += String(format: "%@ ", data.group_user_nickname!)
//                                    }
//                                }
//                            }else{
//                                let data = QueryFriend.shared.queryStronger(groupId: conversation.conversationId, id: username)
//                                text += String(format: "%@ ", data?.name ?? "")
//                            }
//                        }
//                        self.title = String(format: "%@正在输入", text)
//                    }
//                    if cmdbody.action == "TypingEnd" {
//                        if groupInputList.count == 0 {
//                            self.title = self.groupModel?.groupName
//                        }else{
//                            var i = 0
//                            for name in groupInputList {
//                                if name == cmd.from {
//                                    break
//                                }
//                                i += 1
//                            }
//                            if i == 0 && groupInputList[0] == cmd.from {
//                                groupInputList.remove(at: 0)
//                            }
//                            if i != 0 {
//                                groupInputList.remove(at: i)
//                            }
//                            if groupInputList.count == 0 {
//                                self.title = self.groupModel?.groupName
//                            }else{
//                                var text = ""
//                                for username in groupInputList {
//                                    if let data = QueryFriend.shared.getGroupUser(userId: username, groupId: cmd.conversationId) {
//                                        if QueryFriend.shared.checkFriend(userID: username) {
//                                            if data.friend_name?.isEmpty ?? true {
//                                                text += String(format: "%@ ", data.user_name!)
//                                            }else{
//                                                text += String(format: "%@ ", data.friend_name!)
//                                            }
//                                        }else{
//                                            if data.group_user_nickname?.isEmpty ?? true {
//                                                text += String(format: "%@ ", data.user_name!)
//                                            }else{
//                                                text += String(format: "%@ ", data.group_user_nickname!)
//                                            }
//                                        }
//                                    }else{
//                                        let data = QueryFriend.shared.queryStronger(groupId: conversation.conversationId, id: username)
//                                        text += String(format: "%@ ", data?.name ?? "")
//                                    }
//                                }
//                                self.title = String(format: "%@正在输入", text)
//                            }
//                        }
//                    }
//                }
                if conversation.type == EMConversationTypeChat {
                    DispatchQueue.main.async {
                        if cmdbody.action == "TypingBegin" {
                            self.title = "对方正在输入"
                        }
                        if cmdbody.action == "TypingEnd" {
                            if let data = QueryFriend.shared.queryFriend(id: self.conversation.conversationId) {
                                self.title = data.name
                            }else{
                                let data = QueryFriend.shared.queryStronger(id: self.conversation.conversationId)
                                self.title = data?.name
                            }
                        }
                    }
                }
            }
        }
    }
    
       @objc override func messagesDidReceive(_ aMessages: [Any]!) {
        if UIMenuController.shared.isMenuVisible {
            if recivedMessages == nil {
                recivedMessages = aMessages
            }else{
                for m in aMessages {
                    recivedMessages?.append(m)
                }
            }
            return
        }
        for msg in (aMessages as! [EMMessage]) {
            if msg.body.type == EMMessageBodyTypeVideo {
                customDownloadVedioFile(msg)
            }
        }
        super.messagesDidReceive(aMessages)
        if focusList != nil {
            if focusDataModel == nil {
                return
            }
            var focusMessages = (aMessages as! [EMMessage]).filter { (m) -> Bool in
                if m.conversationId == self.conversation.conversationId {
                    for f in focusList! {
                        if f == m.from {
                            if focusDataModel == nil {
                                return true
                            }
                            for ms in focusDataModel!.messageDatasource {
                                let n = ms as! EMMessage
                                if n.messageId == m.messageId {
                                    return false
                                }
                            }
                            return true
                        }
                    }
                }
                return false
            }
            focusMessages = focusMessages.filter({ (m) -> Bool in
                if m.body.type == EMMessageBodyTypeCmd {
                    return false
                }
                return true
            })
            if focusMessages.count > 0 {
                if focusView == nil {
                    self.setupFocusView(focusList: focusList!)
                    return
                }
                let msgs = focusMessages.map { (m) -> IMessageModel in
                    return self.messageViewController(self, modelFor: m)
                }
                for m in focusMessages {
                    var ishave = false
                    for mg in self.focusDataModel!.messageDatasource as! [EMMessage] {
                        if mg.messageId == m.messageId {
                            ishave = true
                            break
                        }
                    }
                    if !ishave {
                        self.focusDataModel?.messageDatasource.append(m)
                    }
                }
                for m in msgs {
                    var ishave = false
                    for mg in self.focusDataModel!.dataArray as! [BoxinMessageModel] {
                        if mg.messageId == m.messageId {
                            ishave = true
                            break
                        }
                    }
                    if !ishave {
                        self.focusDataModel?.dataArray.append(m)
                    }
                }
                self.focusDataModel?.messageDatasource = self.focusDataModel!.messageDatasource.sorted(by: { (a1, a2) -> Bool in
                    let m1 = a1 as? EMMessage
                    if m1 == nil {
                        return false
                    }
                    let m2 = a2 as? EMMessage
                    if m2 == nil {
                        return true
                    }
                    return m1!.localTime < m2!.localTime
                })
                self.focusDataModel?.dataArray = self.focusDataModel!.dataArray.sorted(by: { (a1, a2) -> Bool in
                    let b1 = a1 as? BoxinMessageModel
                    let b2 = a2 as? BoxinMessageModel
                    if b1 == nil {
                        return true
                    }
                    if b2 == nil {
                        return false
                    }
                    return b1!.message.localTime < b2!.message.localTime
                    
                })
                DispatchQueue.main.async {
                    self.focusTabview?.reloadData()
                    self.focusTabview?.scrollToRow(at: IndexPath(row: self.focusDataModel!.dataArray.count - 1, section: 0), at: .bottom, animated: false)
                    let m = self.focusDataModel?.dataArray[self.focusDataModel!.dataArray.count - 1] as! BoxinMessageModel
                    if let da = QueryFriend.shared.getGroupUser(userId: m.message.from, groupId: m.message.conversationId) {
                        var text :String? = ""
                        if QueryFriend.shared.checkFriend(userID: da.user_id!) {
                            if da.friend_name != "" {
                                text = da.friend_name
                            }else{
                                text = da.user_name
                            }
                        }else{
                            if da.group_user_nickname != "" {
                                text = da.group_user_nickname;
                            }else{
                                text = da.user_name
                            }
                        }
                        let attr = self.getMSGtext(message: m.message)
                        attr.insert(NSAttributedString(string: String(format: "[关注]%@:", (text ??  ""))), at: 0)
                        self.focusMessageLabel?.attributedText = attr
                    }else{
                        BoXinUtil.getGroupOneMember(groupID: self.conversation.conversationId, userID: m.message.from) { (b) in
                            if b {
                                if let da = QueryFriend.shared.getGroupUser(userId: m.message.from, groupId: m.message.conversationId) {
                                    var text :String? = ""
                                    if QueryFriend.shared.checkFriend(userID: da.user_id!) {
                                        if da.friend_name != "" {
                                            text = da.friend_name
                                        }else{
                                            text = da.user_name
                                        }
                                    }else{
                                        if da.group_user_nickname != "" {
                                            text = da.group_user_nickname;
                                        }else{
                                            text = da.user_name
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        let attr = self.getMSGtext(message: m.message)
                                        attr.insert(NSAttributedString(string: String(format: "[关注]%@: ", (text ??  ""))), at: 0)
                                        self.focusMessageLabel?.attributedText = attr
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    let attr = self.getMSGtext(message: m.message)
                                    attr.insert(NSAttributedString(string: String(format: "[关注]:")), at: 0)
                                    self.focusMessageLabel?.attributedText = attr
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
       @objc func setupFocusView(focusList:[String]) {
        conversation.loadMessagesStart(fromId: nil, count: 100, searchDirection: EMMessageSearchDirectionUp) { (msg, err) in
            if msg != nil {
                var m = (msg as! [EMMessage]).filter({ (mg) -> Bool in
                    for s in focusList {
                        if mg.from == s {
                            return true
                        }
                    }
                    return false
                })
                if m.count == 0 {
                    return
                }
                var focusMessages = Array<EMMessage>()
                m = m.filter({ (ms) -> Bool in
                    if ms.body.type == EMMessageBodyTypeCmd {
                        return false
                    }
                    focusMessages.append(ms)

                    return true
                })

                if self.focusDataModel == nil {
                    self.focusDataModel = ChatFocusModel()
                    self.focusDataModel?.chat = self
                }
                
                DispatchQueue.main.async {
                    self.focusDataModel?.messageDatasource.removeAll()
                    self.focusDataModel?.dataArray.removeAll()
                    for m in stride(from: 0, to: focusMessages.count, by: 1) {
                        self.focusDataModel?.messageDatasource.append(focusMessages[m])
                    self.focusDataModel?.dataArray.append(self.messageViewController(self, modelFor: focusMessages[m]))
                    }
                    if self.focusTabview == nil {
                        self.focusTabview = UITableView(frame: CGRect(x: 0, y: self.tableView.frame.minY, width: UIScreen.main.bounds.width, height: 220))
                        self.view.addSubview(self.focusTabview!)
                        self.focusTabview?.dataSource = self.focusDataModel
                        self.focusTabview?.delegate = self.focusDataModel
                        self.focusTabview?.separatorStyle = .none
                        self.focusTabview?.isHidden = true
                        let backImage = UIImageView(image: UIImage(named: "chat_background"))
                        backImage.contentMode = .scaleAspectFill
                        backImage.layer.opacity = 0.5
                        if !self.bkUrl.isEmpty {
                            backImage.sd_setImage(with: URL(string: self.bkUrl), placeholderImage: UIImage(named: "chat_background"), options: .retryFailed, context: nil)
                        }
                        self.focusTabview?.backgroundView = backImage
                        self.hideButton = UIButton(type: .custom)
                        self.hideButton?.setImage(UIImage(named: "拉起"), for: .normal)
                        self.hideButton?.setImage(UIImage(named: "拉起"), for: .selected)
                        self.hideButton?.setImage(UIImage(named: "拉起"), for: .highlighted)
                        self.hideButton?.setImage(UIImage(named: "拉起"), for: .disabled)
                        self.hideButton?.addTarget(self, action: #selector(self.onHide), for: .touchUpInside)
                        self.view.addSubview(self.hideButton!)
                        self.hideButton?.mas_makeConstraints({ (make) in
                            make?.right.equalTo()(self.focusTabview?.mas_right)?.offset()(-8)
                            make?.bottom.equalTo()(self.focusTabview?.mas_bottom)?.offset()(-4)
                            make?.height.mas_equalTo()(30)
                            make?.width.mas_equalTo()(30)
                        })
                        self.focusTableLines = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                        self.focusTableLines?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "d9d9d9")
                        self.view.addSubview(self.focusTableLines!)
                        self.focusTableLines?.mas_makeConstraints({ (make) in
                            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                            make?.top.equalTo()(self.focusTabview?.mas_bottom)
                            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                            make?.height.mas_equalTo()(0.5)
                        })
                    }
                    if self.focusView == nil {
                        self.focusView = UIView(frame: CGRect(x: 0, y: self.tableView.frame.minY, width: UIScreen.main.bounds.width, height: 50))
                        self.focusView?.backgroundColor = UIColor.white
                        self.view.addSubview(self.focusView!)
                        self.focusMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
                        self.focusMessageLabel?.font = UIFont.systemFont(ofSize: 13)
                        self.focusMessageLabel?.textColor = UIColor.gray
                        self.focusMessageLabel?.numberOfLines = 1
                        self.focusView?.addSubview(self.focusMessageLabel!)
                        self.showButton = UIButton(type: .custom)
                        self.showButton?.setImage(UIImage(named: "show_down"), for: .normal)
                        self.showButton?.setImage(UIImage(named: "show_down"), for: .selected)
                        self.showButton?.setImage(UIImage(named: "show_down"), for: .highlighted)
                        self.showButton?.setImage(UIImage(named: "show_down"), for: .disabled)
                        self.showButton?.addTarget(self, action: #selector(self.onShow), for: .touchUpInside)
                        self.focusView?.addSubview(self.showButton!)
                        self.showButton?.mas_makeConstraints({ (make) in
                            make?.right.equalTo()(self.focusView?.mas_right)?.offset()(-8)
                            make?.height.mas_equalTo()(30)
                            make?.width.mas_equalTo()(30)
                            make?.bottom.equalTo()(self.focusView?.mas_bottom)?.offset()(-4)
                        })
                        self.focusMessageLabel?.mas_makeConstraints({ (make) in
                            make?.left.equalTo()(self.focusView?.mas_left)?.offset()(16)
                            make?.centerY.equalTo()(self.focusView?.mas_centerY)
                            make?.right.mas_lessThanOrEqualTo()(self.showButton?.mas_left)?.offset()(-4)
                        })
                        self.focusViewLines = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                        self.focusViewLines?.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "d9d9d9")
                        self.view.addSubview(self.focusViewLines!)
                        self.focusViewLines?.mas_makeConstraints({ (make) in
                            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                            make?.top.equalTo()(self.focusView?.mas_bottom)
                            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                            make?.height.mas_equalTo()(0.5)
                        })
                    }
                    if focusMessages.count == 0 {
                        return
                    }
                    if self.focusHiden {
                        self.focusTabview?.isHidden = true
                        self.hideButton?.isHidden = true
                        self.focusTableLines?.isHidden = true
                        self.focusView?.isHidden = false
                        self.showButton?.isHidden = false
                        self.focusViewLines?.isHidden = false
                    }else{
                        self.focusTabview?.isHidden = false
                        self.hideButton?.isHidden = false
                        self.focusTableLines?.isHidden = false
                        self.focusView?.isHidden = true
                        self.showButton?.isHidden = true
                        self.focusViewLines?.isHidden = true
                    }
                    self.focusTabview?.reloadData()
                    let msg = focusMessages[focusMessages.count - 1]
                    if let da = QueryFriend.shared.getGroupUser(userId: msg.from, groupId: msg.conversationId) {
                        var text:String? = ""
                        if QueryFriend.shared.checkFriend(userID: da.user_id!) {
                            if da.friend_name != "" {
                                text = da.friend_name
                            }else{
                                text = da.user_name
                            }
                        }else{
                            if da.group_user_nickname != "" {
                                text = da.group_user_nickname;
                            }else{
                                text = da.user_name
                            }
                        }
                        let attr = self.getMSGtext(message: msg)
                        attr.insert(NSAttributedString(string: String(format: "[关注]%@:", (text ?? ""))), at: 0)
                        self.focusMessageLabel?.attributedText = attr
                    }else{
                        BoXinUtil.getGroupOneMember(groupID: self.conversation.conversationId, userID: msg.from) { (b) in
                            if b {
                                if let da = QueryFriend.shared.getGroupUser(userId: msg.from, groupId: msg.conversationId) {
                                    var text:String? = ""
                                    if QueryFriend.shared.checkFriend(userID: da.user_id!) {
                                        if da.friend_name != "" {
                                            text = da.friend_name
                                        }else{
                                            text = da.user_name
                                        }
                                    }else{
                                        if da.group_user_nickname != "" {
                                            text = da.group_user_nickname;
                                        }else{
                                            text = da.user_name
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        let attr = self.getMSGtext(message: msg)
                                        attr.insert(NSAttributedString(string: String(format: "[关注]%@:", (text ?? ""))), at: 0)
                                        self.focusMessageLabel?.attributedText = attr
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    let attr = self.getMSGtext(message: msg)
                                    attr.insert(NSAttributedString(string: "[关注]:"), at: 0)
                                    self.focusMessageLabel?.attributedText = attr
                                }
                            }
                        }
                    }
                }
                if (self.focusDataModel?.dataArray.count ?? 0) > 3 {
                    if self.focusDataModel?.currentIsInBottom == true
                    {
                        self.focusTabview?.scrollToRow(at: IndexPath(row: self.focusDataModel!.dataArray.count - 1, section: 0), at: .top, animated: false)
                    }
                }
            }
        }
    }
    
       @objc func getMSGtext(message:EMMessage) -> NSMutableAttributedString {
        let lastMsg = message.body
        var text:String = ""
        var attrText:NSMutableAttributedString = NSMutableAttributedString()
        switch lastMsg?.type {
        case EMMessageBodyTypeImage:
            text = "[图片]"
            attrText = NSMutableAttributedString(string: text)
        case EMMessageBodyTypeText:
            var msg = lastMsg as! EMTextMessageBody
            if msg.text.hasSuffix("_encode") {
                var messagetext = String(msg.text.split(separator: "_")[0].utf8)
                if messagetext != nil {
                    messagetext = DCEncrypt.Decode_AES(strToDecode: messagetext!)
                }
                if messagetext != nil {
                    msg = EMTextMessageBody(text: messagetext!)
                }
            }
//            text = EaseConvertToCommonEmoticonsHelper.convert(toSystemEmoticons: msg.text)
            attrText = EaseEmotionEscape.attributtedString(fromText: msg.text)
            if message.ext != nil {
                if message.ext["em_is_big_expression"] != nil {
                    text = "[动画表情]"
                    attrText = NSMutableAttributedString(string: text)
                }
                if message.ext["type"] as? String == "person" {
                    text = "[分享名片]"
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
        return attrText
    }
    
    @objc func onShow() {
        self.focusTabview?.isHidden = false
        self.hideButton?.isHidden = false
        self.focusTableLines?.isHidden = false
        self.focusView?.isHidden = true
        self.showButton?.isHidden = true
        self.focusViewLines?.isHidden = true
        if focusTabview == nil {
            return
        }
        focusTabview?.reloadData()
        DispatchQueue.main.async {
            self.focusTabview?.reloadData()
        }
        if focusDataModel!.dataArray.count == 0 {
            return
        }
        DispatchQueue.main.async {
            self.focusTabview?.scrollToRow(at: IndexPath(row: self.focusDataModel!.dataArray.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    @objc func onHide() {
        self.focusTabview?.isHidden = true
        self.hideButton?.isHidden = true
        self.focusTableLines?.isHidden = true
        self.focusView?.isHidden = false
        self.showButton?.isHidden = false
        self.focusViewLines?.isHidden = false
    }
    
    func setupYHJF() {
        if self.friend?.is_yhjf == 1 {
            if yhjfView != nil {
                yhjfView?.backgroundColor = UIColor.white
                yhjfView?.layer.opacity = 0.8
            }else{
                yhjfView = UIImageView()
                yhjfView?.contentMode = .scaleAspectFill
                yhjfView?.layer.masksToBounds = true
                yhjfView?.backgroundColor = UIColor.white
                yhjfView?.layer.opacity = 0.8
                self.view.addSubview(yhjfView!)
                yhjfView?.mas_makeConstraints({ (make) in
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                    make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 40))
                })
            }
            if yhjfImageView != nil {
                yhjfImageView?.image = UIImage(named: "yhjf")
            }else{
                yhjfImageView = UIImageView()
                yhjfImageView?.image = UIImage(named: "yhjf")
                self.view.addSubview(yhjfImageView!)
                yhjfImageView?.mas_makeConstraints({ (make) in
                    make?.centerX.equalTo()(yhjfView)
                    make?.centerY.equalTo()(yhjfView)
                    make?.height.mas_equalTo()(DCUtill.SCRATIO(x: 20))
                    make?.width.mas_equalTo()(DCUtill.SCRATIO(x: 180))
                })
            }
        }else{
            yhjfView?.removeFromSuperview()
            yhjfImageView?.removeFromSuperview()
            yhjfView = nil
            yhjfImageView = nil
        }
    }
    
    func initData() {
        DispatchQueue.global().async {
            if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
                for c in contact {
                    if c != nil && c?.data != nil {
                        for co in c!.data! {
                            if co?.user_id == self.conversation.conversationId {
                                self.friend = co
                                DispatchQueue.main.async {
                                    self.setupYHJF()
                                }
                                self.isFriend = true
                                if self.isNeedDump {
                                    DispatchQueue.main.async {
                                        let vc = UserDetailViewController()
                                        vc.model = self.friend
                                        vc.type = 1
                                        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                                return
                            }
                        }
                    }
                }
            }
            self.isFriend = false
            let model = GetUserByIDSendModel()
            model.user_id = self.conversation.conversationId
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
                                    self.friend = FriendData(data: md.data)
                                    if self.isNeedDump {
                                        DispatchQueue.main.async {
                                            let vc = UserDetailViewController()
                                            vc.model = self.friend
                                            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }
                                }else{
                                    if md.message == "请重新登录" {
                                        DispatchQueue.main.async {
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
    }

    
       @objc func OpenFileGoLookMessage(message:EMMessage)  {
        
        if message.status == EMMessageStatusFailed {
            return
        }
       
        if message.body.type == EMMessageBodyTypeFile
        {
            let file = message.body as! EMFileMessageBody
            if file.remotePath.isEmpty {
                UIApplication.shared.keyWindow?.makeToast("文件已损坏")
                return
            }
            let str:String = file.remotePath
            let TitleStr:String = file.displayName
            if TitleStr.hasSuffix(".mp4") || TitleStr.hasSuffix("MP4") {
                if FileManager.default.fileExists(atPath: file.localPath) {
                    let data = DCVideoData()
                    data.videoURL = URL(fileURLWithPath: file.localPath)
                    let browser = YBImageBrowser()
                    browser.dataSourceArray = [data]
                    browser.currentPage = 0
                    isOnPreview = true
                    browser.show(to: self.navigationController!.view)
                }else{
                    if isDownLoading {
                        return
                    }
                    isDownLoading = true
                    SVProgressHUD.showProgress(0)
                    let view = UIView(frame: self.view.bounds)
                    view.backgroundColor = UIColor.clear
                    view.tag = 100
                    self.view.addSubview(view)
                    let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                    var dic = path[path.endIndex - 1]
                    dic.appendPathComponent("Vedios", isDirectory: true)
                    dic.appendPathComponent(file.displayName, isDirectory: false)
                    BoXinProvider.request(.DownLoad(url: file.remotePath, filepath: dic.path), callbackQueue: DispatchQueue.main, progress: { (p) in
                        if self.isShow {
                            SVProgressHUD.showProgress(Float(p.progress))
                        }
                    }) { (result) in
                        if let v = self.view.viewWithTag(100) {
                            v.removeFromSuperview()
                        }
                        self.isDownLoading = false
                        if FileManager.default.fileExists(atPath: dic.path){
                            SVProgressHUD.showSuccess(withStatus: "下载成功")
                            SVProgressHUD.dismiss(withDelay: 1.0)
                            file.localPath = dic.path
                            let msg = message
                            msg.body = file
                            var err:EMError?
                            self.conversation.updateMessageChange(msg, error: &err)
                            if self.isShow {
                                let data = DCVideoData()
                                data.videoURL = dic
                                let browser = YBImageBrowser()
                                browser.dataSourceArray = [data]
                                browser.currentPage = 0
                                self.isOnPreview = true
                                browser.show(to: self.navigationController!.view)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            SVProgressHUD.showError(withStatus: "下载失败")
                            SVProgressHUD.dismiss(withDelay: 1.0)
                        }
                    }
                }
                return
            }
            if TitleStr.hasSuffix(".png") || TitleStr.hasSuffix(".PNG") || TitleStr.hasSuffix(".jpg") || TitleStr.hasSuffix(".JPG") || TitleStr.hasSuffix(".jpeg") || TitleStr.hasSuffix(".JPEG") || TitleStr.hasSuffix(".gif") || TitleStr.hasSuffix(".GIF") || TitleStr.hasSuffix(".bmp") || TitleStr.hasSuffix(".BMP") || TitleStr.hasSuffix(".webp") || TitleStr.hasSuffix(".WEBP") || TitleStr.hasSuffix(".HEIC") || TitleStr.hasSuffix(".heic") {
                let data = YBIBImageData()
                if file.downloadStatus == EMDownloadStatusSucceed {
                    data.imagePath = file.localPath
                }else{
                    data.imageURL = URL(string: file.remotePath)
                }
                let browser = YBImageBrowser()
                browser.dataSourceArray = [data]
                browser.currentPage = 0
                isOnPreview = true
                browser.show(to: self.navigationController!.view)
                return
            }
            let path = URL(string: str)!
            if FileManager.default.fileExists(atPath: file.localPath) {
                let preview = UIDocumentInteractionController(url: URL(fileURLWithPath: file.localPath))
                preview.delegate = self
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let b = preview.presentPreview(animated: false)
                if !b {
                    self.view.makeToast("文件无效")
                }else{
                    isOnPreview = true
                }
            }else{
                weak var weakSelf = self
                isDownLoading = true
                SVProgressHUD.showProgress(0)
                let view = UIView(frame: self.view.bounds)
                view.backgroundColor = UIColor.clear
                view.tag = 100
                self.view.addSubview(view)
                let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                var dic = path[path.endIndex - 1]
                dic.appendPathComponent("File", isDirectory: true)
                dic.appendPathComponent(file.displayName, isDirectory: false)
                BoXinProvider.request(.DownLoad(url: file.remotePath, filepath: dic.path), callbackQueue: DispatchQueue.main, progress: { (p) in
                    if self.isShow {
                        SVProgressHUD.showProgress(Float(p.progress))
                    }
                }) { (result) in
                    self.isDownLoading = false
                    if FileManager.default.fileExists(atPath: dic.path){
                        SVProgressHUD.showSuccess(withStatus: "下载成功")
                        SVProgressHUD.dismiss(withDelay: 1.0)
                        file.localPath = dic.path
                        let msg = message
                        msg.body = file
                        var err:EMError?
                        self.conversation.updateMessageChange(msg, error: &err)
                        if self.isShow {
                            let preview = UIDocumentInteractionController(url: URL(fileURLWithPath: file.localPath))
                            preview.delegate = self
                            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                            let b = preview.presentPreview(animated: true)
                            if !b {
                                self.view.makeToast("文件无效")
                            }else{
                                self.isOnPreview = true
                            }
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        SVProgressHUD.showError(withStatus: "下载失败")
                        SVProgressHUD.dismiss(withDelay: 1.0)
                    }
                }
//                EMClient.shared()?.chatManager.downloadMessageAttachment(message, progress: { (p) in
//                    SVProgressHUD.showProgress(Float(p), status: "正在下载")
//                }, completion: { (mssg, err) in
//                    if err != nil {
//                        SVProgressHUD.showError(withStatus: "下载失败")
//                    }else{
//                        SVProgressHUD.dismiss()
//                        guard let body = mssg?.body as? EMFileMessageBody else {
//                            return
//                        }
//                        guard FileManager.default.fileExists(atPath: body.localPath) else {
//                            return
//                        }
//                        EMClient.shared()?.chatManager.update(mssg, completion: nil)
//                        guard weakSelf != nil else {
//                            return
//                        }
//
//                    }
//                })
            }
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.navigationController ?? self
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.navigationController?.view ?? self.view
    }

       @objc override func sendImageMessage(_ image: UIImage!) {
        super.sendImageMessage(image)
        
    }
    
//    - (void)textViewDidChange:(EaseTextView*) textView;
//    - (BOOL)textView:(EaseTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

       @objc override func textViewDidChange(_ textView: EaseTextView!) {
        if textView.text.contains("add_DIY") {
            textView.text = textView.text.replacingOccurrences(of: "add_DIY", with: "")
            chatToolbar.endEditing(true)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = DIYFaceViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if !groupSend {
            if conversation.type == EMConversationTypeChat {
                let body = EMCmdMessageBody(action: "TypingBegin")
                body?.isDeliverOnlineOnly = true
                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
                EMClient.shared()?.chatManager.send(message, progress: { (p) in
                    
                }, completion: { (m, e) in
                    
                })
            }
            //                if conversation.type == EMConversationTypeGroupChat {
            //                    let body = EMCmdMessageBody(action: "TypingBegin")
            //                    body?.isDeliverOnlineOnly = true
            //                    let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
            //                    message?.chatType = EMChatTypeGroupChat
            //                    EMClient.shared()?.chatManager.send(message, progress: { (p) in
            //
            //                    }, completion: { (m, e) in
            //
            //                    })
            //                }
        }
    }
    
       @objc override func textView(_ textView: EaseTextView!, shouldChangeTextIn range: NSRange, replacementText text: String!) -> Bool {
        if conversation.type == EMConversationTypeGroupChat
        {
            if textView.markedTextRange != nil {
                return true
            }
            if text == "@"
            {
                if UIViewController.currentViewController() is ChangeGroupOwnerViewController {
                    return false
                }
                chatToolbar.endEditing(true)
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let vc = ChangeGroupOwnerViewController()
                vc.typeID = 2
                dbQuese.async {
                    vc.data = QueryFriend.shared.getGroupMembers(groupId: self.conversation.conversationId)
                    vc.user = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
                    if (vc.data?.count ?? 0 < 1) {
                        SVProgressHUD.show()
                        BoXinUtil.getGroupMember(groupID: self.conversation.conversationId) { (b) in
                            SVProgressHUD.dismiss()
                            if b {
                                dbQuese.async {
                                    vc.data = QueryFriend.shared.getGroupMembers(groupId: self.conversation.conversationId)
                                    vc.user = QueryFriend.shared.getGroupUser(userId: self.data!.db!.user_id!, groupId: self.conversation.conversationId)
                                    DispatchQueue.main.async {
                                        vc.delegate = self
                                        if UIViewController.currentViewController() is ChangeGroupOwnerViewController {
                                            return
                                        }
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.view.makeToast("获取群成员失败")
                                }
                            }
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        vc.delegate = self
                        if UIViewController.currentViewController() is ChangeGroupOwnerViewController {
                            return
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                return false
            }
            if text.isEmpty {
                if isAtAll {
                    if textView.text.count == atAllStart + 6
                    {
                        isAtAll = false
                        
                        textView.text = String(textView.text!.prefix(atAllStart).utf8)
                        atAllStart = -1
                        return false
                    }
                }
                if atList != nil {
                    var i = 0
                    for m in atList!
                    {
                        if textView.text.count == m!.start! + m!.lenth!
                        {
                            atList?.remove(at: i)
                            textView.text = String(textView.text!.prefix(m!.start!).utf8)
                            return false
                        }
                        i += 1
                    }
                }
            }
           
        }
        
         return true
    }
    
        @objc func onAtClick(member: GroupMemberData?) {
        let chatbar = chatToolbar as! EaseChatToolbar
        if member == nil {
            isAtAll = true
            atAllStart = chatbar.inputTextView.text.count
            chatbar.inputTextView.text += "@全体成员 "
            return
        }
        if atList == nil {
            atList = Array<GroupAtModel?>()
        }
        let model = GroupAtModel()
        model.model = member
        model.start = chatbar.inputTextView.text.count
        model.lenth = (member?.user_name!.count)! + 2
        atList?.append(model)
        chatbar.inputTextView.text += String(format: "@%@ ", member!.user_name!)
    }
    
       @objc override func shouldSendHasReadAck(for message: EMMessage!, read: Bool) -> Bool {
        if !isShow {
            return false
        }
        if conversation.type == EMConversationTypeGroupChat {
            conversation.markMessageAsRead(withId: message.messageId, error: nil)
            return false
        }
        return super.shouldSendHasReadAck(for: message, read: read)
    }
    
       @objc func emotionFormessageViewController(_ viewController: EaseMessageViewController!) -> [Any]! {
        var defualface = Array<EaseEmotion>()
        if let emotionDB = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "emotionDB", ofType: "plist")!) {
            for (key,value) in emotionDB {
                defualface.append(EaseEmotion(name: "", emotionId: key as? String, emotionThumbnail: value as? String, emotionOriginal: value as? String, emotionOriginalURL: "", emotionType: EMEmotionType.png))
            }
        }
        defualface.sort { (e1, e2) -> Bool in
            if let ei1 = Int(String(e1.emotionThumbnail.split(separator: "_")[1])) {
                if let ei2 = Int(String(e2.emotionThumbnail.split(separator: "_")[1])) {
                    return ei1 < ei2
                }
            }
            return false
        }
        let menagerDefualt = EaseEmotionManager(type: .png, emotionRow: 3, emotionCol: 7, emotions: defualface, tagImage: UIImage(named: "ee_1"))
        var pngFace = Array<EaseEmotion>()
        pngFace.append(EaseEmotion(name: "", emotionId: "add_DIY", emotionThumbnail: "添加Face", emotionOriginal: "", emotionOriginalURL: "", emotionType: .png))
        let faces = QueryFriend.shared.GetAllFace()     
        for face in faces {
            if face.url != nil && face.path != nil {
                pngFace.append(EaseEmotion(name: "", emotionId: "[自定义表情]", emotionThumbnail: String(format: "%d", face.faceW), emotionOriginal: String(format: "%d", face.faceH), emotionOriginalURL: face.url!, emotionType: .gif))
            }else if face.url != nil {
                pngFace.append(EaseEmotion(name: "", emotionId: "[自定义表情]", emotionThumbnail: String(format: "%d", face.faceW), emotionOriginal: String(format: "%d", face.faceH), emotionOriginalURL: face.url!, emotionType: .gif))
            }
        }
        let menagerDIY = EaseEmotionManager(type: .gif, emotionRow: 2, emotionCol: 5, emotions: pngFace, tagImage: UIImage(named: "心"))
        return [menagerDefualt,menagerDIY]
    }
    
       @objc func emotionExtFormessageViewController(_ viewController: EaseMessageViewController!, easeEmotion: EaseEmotion!) -> [AnyHashable : Any]! {
        if easeEmotion.emotionId == "add_DIY" {
            return ["NoSend":"1"]
        }
        if easeEmotion.emotionId == "[自定义表情]" {
            return ["jpzim_is_big_expression":true,MESSAGE_ATTR_IS_BIG_EXPRESSION:true,"jpzim_big_expression_path":easeEmotion.emotionOriginalURL,
                    "faceW":easeEmotion.emotionThumbnail,"faceH":easeEmotion.emotionOriginal]
        }
        return [:]
    }
    
       @objc func isEmotionMessageFormessageViewController(_ viewController: EaseMessageViewController!, messageModel: IMessageModel!) -> Bool {
        if messageModel.bodyType == EMMessageBodyTypeText && messageModel.message.ext != nil {
            if (messageModel.message.ext["jpzim_is_big_expression"] as? Bool) ?? false {
                return true
            }
        }
        return false
    }
    
    func emotionURLFormessageViewController(_ viewController: EaseMessageViewController!, messageModel: IMessageModel!) -> EaseEmotion! {
        let e = EaseEmotion(name: "", emotionId: "", emotionThumbnail: "", emotionOriginal: "", emotionOriginalURL: String(format: "%@", messageModel.message.ext!["jpzim_big_expression_path"] as! String), emotionType: .gif)
        return e!
    }
    
    
    @objc func onEmojiChanged() {
        DispatchQueue.main.async {
            self.dataSource = self
        }
    }
    
    override func inputTextViewDidBeginEditing(_ inputTextView: EaseTextView!) {
        super.inputTextViewDidBeginEditing(inputTextView)
        if !groupSend {
            if conversation.type == EMConversationTypeChat {
                let body = EMCmdMessageBody(action: "TypingBegin")
                body?.isDeliverOnlineOnly = true
                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
                EMClient.shared()?.chatManager.send(message, progress: { (p) in
                    
                }, completion: { (m, e) in
                    
                })
            }
//            if conversation.type == EMConversationTypeGroupChat {
//                let body = EMCmdMessageBody(action: "TypingBegin")
//                body?.isDeliverOnlineOnly = true
//                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
//                message?.chatType = EMChatTypeGroupChat
//                EMClient.shared()?.chatManager.send(message, progress: { (p) in
//                    
//                }, completion: { (m, e) in
//                    
//                })
//            }
        }
    }
    
    override func didSendText(_ text: String!) {
        let t = text.trimmingCharacters(in: .illegalCharacters)
        super.didSendText(t)
        if !groupSend {
            if conversation.type == EMConversationTypeChat {
                let body = EMCmdMessageBody(action: "TypingEnd")
                body?.isDeliverOnlineOnly = true
                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
                EMClient.shared()?.chatManager.send(message, progress: { (p) in
                    
                }, completion: { (m, e) in
                    
                })
            }
            if conversation.type == EMConversationTypeGroupChat {
                let body = EMCmdMessageBody(action: "TypingEnd")
                body?.isDeliverOnlineOnly = true
                let message = EMMessage(conversationID: conversation.conversationId, from: data!.db!.user_id!, to: conversation.conversationId, body: body, ext: [:])
                message?.chatType = EMChatTypeGroupChat
                EMClient.shared()?.chatManager.send(message, progress: { (p) in
                    
                }, completion: { (m, e) in
                    
                })
            }
        }
    }
    
    override func _reloadTableViewData(with message: EMMessage!) {
        super._reloadTableViewData(with: message)
        if focusList?.contains(message.from) ?? false {
            DispatchQueue(label: "fmsg").async {
                for (index,obj) in self.focusDataModel?.messageDatasource.enumerated() ?? [].enumerated() {
                    if let msg = obj as? EMMessage {
                        if msg.messageId == msg.messageId {
                            self.focusDataModel?.messageDatasource[index] = message as Any
                            break
                        }
                    }
                }
                var row = -1
                for (index, obj) in self.focusDataModel?.dataArray.enumerated() ?? [].enumerated() {
                    if let model = obj as? IMessageModel {
                        if model.messageId == message.messageId {
                            self.focusDataModel?.dataArray[index] = self.messageViewController(self, modelFor: message) as Any
                            row = index
                            break
                        }
                    }
                }
                let wait = DispatchSemaphore(value: 01)
                DispatchQueue.main.async {
                    self.focusTabview?.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                    wait.signal()
                }
                wait.wait()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            chatToolbar.endEditing(true)
            UIMenuController.shared.setMenuVisible(false, animated: false)
        }
    }
    
    func uploadFile(_ message:EMMessage, _ complite:@escaping (String)-> Void) {
        if message.body.type == EMMessageBodyTypeVoice {
            let body = message.body as? EMVoiceMessageBody
            let put = OSSPutObjectRequest()
            put.bucketName = "hgjt-oss"
            put.uploadingFileURL = URL(fileURLWithPath: body!.localPath)
            let Filename = String(put.uploadingFileURL.lastPathComponent.split(separator: ".")[0]).md5()+".amr"
            put.objectKey = String(format: "im19060501/%@", Filename)
            let app = UIApplication.shared.delegate as! AppDelegate
            let task = app.ossClient?.putObject(put)
            task?.continue({ (t) -> Any? in
                if t.error == nil {
                    body?.remotePath = "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/" + Filename
                    message.body = body
                    complite(Filename)
                }else{
                    print(t.error.debugDescription)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                    }
                }
                return nil
            })
            return
        }
        if message.body.type == EMMessageBodyTypeImage {
            let body = message.body as? EMImageMessageBody
            let put = OSSPutObjectRequest()
            put.bucketName = "hgjt-oss"
            put.uploadingFileURL = URL(fileURLWithPath: body!.localPath)
            let Filename = String(put.uploadingFileURL.lastPathComponent.split(separator: ".")[0]).md5()+".jpg"
            put.objectKey = String(format: "im19060501/%@", Filename)
            let app = UIApplication.shared.delegate as! AppDelegate
            let task = app.ossClient?.putObject(put)
            task?.continue({ (t) -> Any? in
                if t.error == nil {
                    body?.remotePath = "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/" + Filename
                    message.body = body
                    complite(Filename)
                }else{
                    print(t.error.debugDescription)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                    }
                }
                return nil
            })
            return
        }
        if message.body.type == EMMessageBodyTypeVideo {
            let body = message.body as? EMVideoMessageBody
            let put = OSSPutObjectRequest()
            put.bucketName = "hgjt-oss"
            put.uploadingFileURL = URL(fileURLWithPath: body!.thumbnailLocalPath)
            var Filename = String(put.uploadingFileURL.lastPathComponent.split(separator: ".")[0]).md5()+".jpg"
            put.objectKey = String(format: "im19060501/%@", Filename)
            let app = UIApplication.shared.delegate as! AppDelegate
            let task = app.ossClient?.putObject(put)
            task?.continue({ (t) -> Any? in
                if t.error == nil {
                    body?.thumbnailRemotePath = "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/" + Filename
                    message.body = body
                    DispatchQueue.main.async {
                        let put1 = OSSPutObjectRequest()
                        put1.bucketName = "hgjt-oss"
                        put1.uploadingFileURL = URL(fileURLWithPath: body!.localPath)
                        Filename = String(put.uploadingFileURL.lastPathComponent.split(separator: ".")[0]).md5()+".mp4"
                        put1.objectKey = String(format: "im19060501/%@", Filename)
                        let app = UIApplication.shared.delegate as! AppDelegate
                        let task1 = app.ossClient?.putObject(put1)
                        task1?.continue({ (t) -> Any? in
                            if t.error == nil {
                                body?.remotePath = "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/" + Filename
                                message.body = body
                                complite(Filename)
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
                }else{
                    print(t.error.debugDescription)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                    }
                }
                return nil
            })
            return
        }
        if message.body.type == EMMessageBodyTypeFile {
            let body = message.body as? EMFileMessageBody
            let put = OSSPutObjectRequest()
            put.bucketName = "hgjt-oss"
            put.uploadingFileURL = URL(fileURLWithPath: body!.localPath)
            let Filename = body?.displayName ?? UUID().uuidString.replacingOccurrences(of: "-", with: "")
            put.objectKey = String(format: "im19060501/%@", Filename)
            let app = UIApplication.shared.delegate as! AppDelegate
            let task = app.ossClient?.putObject(put)
            task?.continue({ (t) -> Any? in
                if t.error == nil {
                    body?.remotePath = "http://hgjt-oss.oss-cn-hongkong.aliyuncs.com/im19060501/" + Filename
                    message.body = body
                    complite(Filename)
                }else{
                    print(t.error.debugDescription)
                    DispatchQueue.main.async {
                        
                        SVProgressHUD.dismiss()
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                    }
                }
                return nil
            })
            return
        }
    }
    
    func collection(_ message:EMMessage!) {
        let model = SubmitCollectionSendModel(message)
        BoXinProvider.request(.SubmitCollection(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    if let model = SubmitConlectionReciveModel.deserialize(from: try? res.mapString()) {
                        guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                            return
                        }
                        if model.code == 200 {
                            SVProgressHUD.showSuccess(withStatus: "收藏成功")
                        }else{
                            DispatchQueue.main.async {
                                self.view.makeToast(model.message)
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                           self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.view.makeToast("服务器连接失败")
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
            }
        }
    }
    
    func downloadFile(_ message:EMMessage, _ complite:@escaping (String?)-> Void) {
        self.messageQueue.async {
            var url = ""
            var file = ""
            if message.body.type == EMMessageBodyTypeVoice {
                let body = message.body as? EMVoiceMessageBody
                if let p = body?.localPath {
                    if FileManager.default.fileExists(atPath:p) {
                        message.status = EMMessageStatusSucceed
                        complite(p)
                        return
                    }
                }
                url = body?.remotePath ?? ""
                let path = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
                var dic = path[path.count - 1]
                dic.appendPathComponent("appdata", isDirectory: true)
                dic.appendPathComponent("chatbuffer", isDirectory: true)
                var b:ObjCBool = ObjCBool(false)
                if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                    if !b.boolValue {
                        try? FileManager.default.removeItem(at: dic)
                        try? FileManager.default.createDirectory(atPath: dic.path, withIntermediateDirectories: true, attributes: nil)
                    }
                }else{
                    try? FileManager.default.createDirectory(atPath: dic.path, withIntermediateDirectories: true, attributes: nil)
                }
                dic.appendPathComponent(UUID().uuidString.replacingOccurrences(of: "-", with: "")+".amr", isDirectory: false)
                file = dic.path
                if FileManager.default.fileExists(atPath: file){
                    body?.localPath = file
                    message.body = body
                    message.status = EMMessageStatusSucceed
                    self.conversation.updateMessageChange(message, error: nil)
                    complite(file)
                    return
                }
            }
            if message.body.type == EMMessageBodyTypeFile {
                let body = message.body as? EMFileMessageBody
                if let p = body?.localPath {
                    if FileManager.default.fileExists(atPath:p) {
                        message.status = EMMessageStatusSucceed
                        self.conversation.updateMessageChange(message, error: nil)
                        complite(p)
                        return
                    }
                }
                url = body?.remotePath ?? ""
                let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                var dic = path[path.count - 1]
                dic.appendPathComponent("chatbuffer", isDirectory: true)
                var b:ObjCBool = ObjCBool(false)
                if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                    if !b.boolValue {
                        try? FileManager.default.createDirectory(atPath: dic.path, withIntermediateDirectories: true, attributes: nil)
                    }
                }else{
                    try? FileManager.default.createDirectory(atPath: dic.path, withIntermediateDirectories: true, attributes: nil)
                }
                dic.appendPathComponent(body?.displayName ?? UUID().uuidString.replacingOccurrences(of: "-", with: ""), isDirectory: false)
                file = dic.path
                if FileManager.default.fileExists(atPath: file){
                    body?.localPath = file
                    message.body = body
                    message.status = EMMessageStatusSucceed
                    self.conversation.updateMessageChange(message, error: nil)
                    complite(file)
                    return
                }
            }
            if message.body.type ==  EMMessageBodyTypeImage {
                let body = message.body as? EMImageMessageBody
                if let p = body?.localPath {
                    if UIImage(contentsOfFile: p) != nil {
                        message.status = EMMessageStatusSucceed
                        message.body = body
                        self.conversation.updateMessageChange(message, error: nil)
                        complite(p)
                        return
                    }
                }
                url = body?.remotePath ?? ""
                let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                var dic = path[path.count - 1]
                dic.appendPathComponent("chatbuffer", isDirectory: true)
                var b:ObjCBool = ObjCBool(false)
                if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                    if !b.boolValue {
                        try? FileManager.default.removeItem(at: dic)
                        try? FileManager.default.createDirectory(atPath: dic.path, withIntermediateDirectories: true, attributes: nil)
                    }
                }else{
                    try? FileManager.default.createDirectory(atPath: dic.path, withIntermediateDirectories: true, attributes: nil)
                }
                dic.appendPathComponent(body?.displayName ?? UUID().uuidString.replacingOccurrences(of: "-", with: "")+".jpg", isDirectory: false)
                file = dic.path
                if UIImage(contentsOfFile: file) != nil{
                    body?.localPath = file
                    message.body = body
                    message.status = EMMessageStatusSucceed
                    self.conversation.updateMessageChange(message, error: nil)
                    complite(file)
                    return
                }
            }
            if message.body.type == EMMessageBodyTypeVideo {
                let body = message.body as? EMVideoMessageBody
                if let p = body?.localPath {
                    if FileManager.default.fileExists(atPath:p) && FileManager.default.fileExists(atPath: body?.thumbnailLocalPath ?? "") {
                        message.status = EMMessageStatusSucceed
                        self.conversation.updateMessageChange(message, error: nil)
                        complite(p)
                        return
                    }
                }
                url = body?.remotePath ?? ""
                let path = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
                var dic = path[path.count - 1]
                dic.appendPathComponent("appdata", isDirectory: true)
                dic.appendPathComponent("chatbuffer", isDirectory: true)
                var b:ObjCBool = ObjCBool(false)
                if FileManager.default.fileExists(atPath: dic.path, isDirectory: &b) {
                    if !b.boolValue {
                        try? FileManager.default.createDirectory(atPath: dic.path, withIntermediateDirectories: true, attributes: nil)
                    }
                }else{
                    try? FileManager.default.createDirectory(atPath: dic.path, withIntermediateDirectories: true, attributes: nil)
                }
                dic.appendPathComponent(body?.displayName ?? UUID().uuidString.replacingOccurrences(of: "-", with: "")+".mp4", isDirectory: false)
                file = dic.path
                var dic1 = path[path.count - 1]
                dic1.appendPathComponent("appdata", isDirectory: true)
                dic1.appendPathComponent("chatbuffer", isDirectory: true)
                dic1.appendPathComponent( UUID().uuidString.replacingOccurrences(of: "-", with: "")+".jpg", isDirectory: false)
                if FileManager.default.fileExists(atPath: file){
                    body?.localPath = file
                    message.body = body
                    message.status = EMMessageStatusSucceed
                    self.conversation.updateMessageChange(message, error: nil)
                    complite(file)
                    return
                }
            }
            BoXinProvider.request(.DownLoad(url: url, filepath: file)) { (result) in
                if FileManager.default.fileExists(atPath: file) {
                    if message.body.type == EMMessageBodyTypeImage {
                        let b1 = message.body as? EMImageMessageBody
                        b1?.localPath = file
                        b1?.thumbnailLocalPath = file
                        message.body = b1
                        message.status = EMMessageStatusSucceed
                        self.conversation.updateMessageChange(message, error: nil)
                        complite(file)
                        return
                    }
                    let body = message.body as? EMFileMessageBody
                    body?.localPath = file
                    message.body = body
                    message.status = EMMessageStatusSucceed
                    self.conversation.updateMessageChange(message, error: nil)
                    complite(file)
                }else{
                    complite(nil)
                }
            }
        }
    }
    
}
