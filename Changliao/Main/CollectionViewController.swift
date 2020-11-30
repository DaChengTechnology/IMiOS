//
//  CollectionViewController.swift
//  boxin
//
//  Created by guduzhonglao on 11/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

@objc class CollectionViewController: ChatViewController {
    
    var pageIndex = 0
    var isDeleting = false

    override func viewDidLoad() {
        groupSend = true
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "我的收藏"
        chatBarMoreView.removeItematIndex(6)
        chatBarMoreView.removeItematIndex(4)
        chatBarMoreView.removeItematIndex(3)
        self.navigationItem.rightBarButtonItem = nil
    }
    
    override func emotionFormessageViewController(_ viewController: EaseMessageViewController!) -> [Any]! {
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
        return [menagerDefualt]
    }
    
    override func messageViewController(_ viewController: EaseMessageViewController!, didSelect moreView: EaseChatBarMoreView!, at index: Int) {
        if index == 3 {
            moreViewFileTransferAction(moreView)
        }
    }
    
    override func showMenuViewController(_ showInView: UIView!, andIndexPath indexPath: IndexPath!, messageType: EMMessageBodyType) {
        if menuController == nil {
            menuController = UIMenuController.shared
        }
        let zhuanfa = UIMenuItem(title: "转发", action: #selector(onSendOther))
        let delete = UIMenuItem(title: "删除", action: #selector(onDeleteCollection))
        menuController.menuItems = [zhuanfa,delete]
        menuController.setTargetRect(showInView.frame, in: showInView.superview!)
        menuController.setMenuVisible(true, animated: true)
    }
    
    @objc func onDeleteCollection() {
        if menuIndexPath == nil {
            return
        }
        if menuIndexPath.row >= dataArray.count {
            return
        }
        if let msg = dataArray[menuIndexPath.row] as? BoxinMessageModel {
            if msg.message.status == EMMessageStatusDelivering {
                chatToolbar.endEditing(true)
                self.view.makeToast("正在收藏此消息，请稍后")
                return
            }
            if isDeleting {
                chatToolbar.endEditing(true)
                self.view.makeToast("正在删除其他消息，请稍后")
                return
            }
            isDeleting = true
            let model = DeleteCollectionSendModel()
            model.collection_id = msg.message.messageId
            self.messageQueue.async {
                BoXinProvider.request(.DeleteCollection(model: model)) { (result) in
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                                if model.code == 200 {
                                    UserDefaults.standard.removeObject(forKey: "DeleteCollection")
                                    UserDefaults.standard.synchronize()
                                    if let arr = self.messsagesSource.filter({ (a) -> Bool in
                                        if let b = a as? EMMessage {
                                            if b.messageId == msg.messageId {
                                                return false
                                            }
                                        }
                                        return true
                                    }) as? NSMutableArray {
                                        self.messsagesSource = arr
                                    }
                                    for (inx, obj) in self.dataArray.enumerated() {
                                        if let m = obj as? BoxinMessageModel {
                                            if m.message.messageId == msg.messageId {
                                                self.dataArray.removeObject(at: inx)
                                                if inx > 0 {
                                                    if self.dataArray[inx-1] is String {
                                                        self.dataArray.removeObject(at: inx - 1)
                                                    }
                                                }
                                                DispatchQueue.main.async {
                                                    self.tableView.reloadData()
                                                }
                                                break
                                            }
                                        }
                                    }
                                    self.conversation.deleteMessage(withId: msg.messageId, error: nil)
                                    self.isDeleting = false
                                }else{
                                    if model.message?.contains("收藏数据") ?? false {
                                        UserDefaults.standard.removeObject(forKey: "DeleteCollection")
                                        UserDefaults.standard.synchronize()
                                        if let arr = self.messsagesSource.filter({ (a) -> Bool in
                                            if let b = a as? EMMessage {
                                                if b.messageId == msg.messageId {
                                                    return false
                                                }
                                            }
                                            return true
                                        }) as? NSMutableArray {
                                            self.messsagesSource = arr
                                        }
                                        for (inx, obj) in self.dataArray.enumerated() {
                                            if let m = obj as? BoxinMessageModel {
                                                if m.message.messageId == msg.messageId {
                                                    self.dataArray.removeObject(at: inx)
                                                    if inx > 0 {
                                                        if self.dataArray[inx-1] is String {
                                                            self.dataArray.removeObject(at: inx - 1)
                                                        }
                                                    }
                                                    DispatchQueue.main.async {
                                                        self.tableView.reloadData()
                                                    }
                                                    break
                                                }
                                            }
                                        }
                                        self.conversation.deleteMessage(withId: msg.messageId, error: nil)
                                        self.isDeleting = false
                                        DispatchQueue.main.async {
                                            self.chatToolbar.endEditing(true)
                                            self.view.makeToast(model.message)
                                        }
                                    }else{
                                        self.isDeleting = false
                                        DispatchQueue.main.async {
                                            self.chatToolbar.endEditing(true)
                                            self.view.makeToast(model.message)
                                        }
                                    }
                                }
                            }else{
                                self.isDeleting = false
                                DispatchQueue.main.async {
                                    self.chatToolbar.endEditing(true)
                                    self.view.makeToast("删除失败")
                                }
                            }
                        }else{
                            self.isDeleting = false
                            DispatchQueue.main.async {
                                self.chatToolbar.endEditing(true)
                                self.view.makeToast("删除失败")
                            }
                        }
                    case .failure(_):
                        self.isDeleting = false
                        DispatchQueue.main.async {
                            self.chatToolbar.endEditing(true)
                            self.view.makeToast("删除失败")
                        }
                    }
                }
            }
        }
    }
    
    override func onSendOther() {
        if menuIndexPath == nil {
            return
        }
        if menuIndexPath.row >= dataArray.count {
            return
        }
        if let msg = dataArray[menuIndexPath.row] as? BoxinMessageModel {
            if msg.message.status == EMMessageStatusDelivering {
                chatToolbar.endEditing(true)
                self.view.makeToast("正在收藏此消息，请稍后")
                return
            }
            if msg.message.body is EMFileMessageBody {
                downloadFile(msg.message) { (a) in
                    self.conversation.updateMessageChange(msg.message, error: nil)
                    DispatchQueue.main.async {
                        self._reloadTableViewData(with: msg.message)
                        super.onSendOther()
                    }
                }
            }else{
                super.onSendOther()
            }
        }
    }
    
    override func send(_ message: EMMessage!, isNeedUploadFile isUploadFile: Bool) {
        self.messageQueue.async {
            if message.body.type == EMMessageBodyTypeVoice {
                message.status = EMMessageStatusDelivering
                self.addMessage(toDataSource: message, progress: nil)
                DispatchQueue.main.async {
                    self.uploadFile(message) { (a) in
                        self.messageQueue.async {
                            self.collection(message)
                        }
                    }
                }
                return
            }
            if message.body.type == EMMessageBodyTypeFile {
                message.status = EMMessageStatusDelivering
                self.addMessage(toDataSource: message, progress: nil)
                DispatchQueue.main.async {
                    self.uploadFile(message) { (a) in
                        self.messageQueue.async {
                            self.collection(message)
                        }
                    }
                }
                return
            }
            if message.body.type == EMMessageBodyTypeImage {
                message.status = EMMessageStatusDelivering
                self.addMessage(toDataSource: message, progress: nil)
                DispatchQueue.main.async {
                    self.uploadFile(message) { (a) in
                        self.messageQueue.async {
                            self.collection(message)
                        }
                    }
                }
                return
            }
            if message.body.type == EMMessageBodyTypeVideo {
                message.status = EMMessageStatusDelivering
                self.addMessage(toDataSource: message, progress: nil)
                DispatchQueue.main.async {
                    self.uploadFile(message) { (a) in
                        self.messageQueue.async {
                            self.collection(message)
                        }
                    }
                }
                return
            }
            if message.body.type == EMMessageBodyTypeCmd {
                return
            }
            message.status = EMMessageStatusDelivering
            self.addMessage(toDataSource: message, progress: nil)
            self.collection(message)
        }
    }
    
    override func collection(_ message:EMMessage!) {
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
                            UserDefaults.standard.removeObject(forKey: "DeleteCollection")
                            UserDefaults.standard.synchronize()
                            message.timestamp = model.data?.time ?? 0
                            message.status = EMMessageStatusSucceed
                            message.messageId = model.data?.id
                            self.conversation.insert(message, error: nil)
                            DispatchQueue.main.async {
                                self._reloadTableViewData(with: message)
                            }
                        }
                    }else{
                        message.status = EMMessageStatusFailed
                        DispatchQueue.main.async {
                            self._reloadTableViewData(with: message)
                        }
                    }
                }else{
                    message.status = EMMessageStatusFailed
                    DispatchQueue.main.async {
                        self._reloadTableViewData(with: message)
                    }
                }
            case .failure(_):
                message.status = EMMessageStatusFailed
                DispatchQueue.main.async {
                    self._reloadTableViewData(with: message)
                }
            }
        }
    }
    
    override func tableViewDidTriggerHeaderRefresh() {
        pageIndex += 1
        if let first = messsagesSource.firstObject as? EMMessage {
            conversation.loadMessagesStart(fromId: first.messageId, count: 20, searchDirection: EMMessageSearchDirectionUp) { (messages, err) in
                self.messageQueue.async {
                    self.loadMoreMessage(first.messageId, messages: messages)
                    guard let msgs = messages as? [EMMessage] else {
                        return
                    }
                    for (idx, obj) in msgs.enumerated() {
                        self.messsagesSource.insert(obj, at: idx)
                    }
                    let msgdata =  self.formatMessages(messages)
                    for (idx, obj) in msgdata!.enumerated() {
                        self.dataArray.insert(obj, at: idx)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    for m in msgs {
                        if m.body.type == EMMessageBodyTypeImage {
                            self.downloadThumbnailImage(m) {
                                DispatchQueue.main.async {
                                    self._reloadTableViewData(with: m)
                                }
                            }
                        }
                        if m.body.type == EMMessageBodyTypeVoice {
                            self.downloadFile(m) { (f) in
                                self.conversation.updateMessageChange(m, error: nil)
                                DispatchQueue.main.async {
                                    self._reloadTableViewData(with: m)
                                }
                            }
                            
                        }
                        if m.body.type == EMMessageBodyTypeVideo {
                            self.customDownloadVedioFile(m)
                        }
                    }
                }
            }
        }else{
            conversation.loadMessagesStart(fromId: nil, count: 20, searchDirection: EMMessageSearchDirectionUp) { (messages, err) in
                self.messageQueue.async {
                    guard let msgs = messages as? [EMMessage] else {
                        return
                    }
                    if messages?.count == 0 {
                        return
                    }
                    for (idx, obj) in msgs.enumerated() {
                        self.messsagesSource.insert(obj, at: idx)
                    }
                    let msgdata =  self.formatMessages(messages)
                    for (idx, obj) in msgdata!.enumerated() {
                        self.dataArray.insert(obj, at: idx)
                    }
                    self.conversation.markAllMessages(asRead: nil)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        if self.pageIndex == 1 && self.dataArray.count > 0 {
                            self.tableView.scrollToRow(at: IndexPath(row: self.dataArray.count - 1, section: 0), at: .top, animated: false)
                        }
                    }
                    for m in msgs {
                        if m.body.type == EMMessageBodyTypeImage {
                            self.downloadThumbnailImage(m) {
                                DispatchQueue.main.async {
                                    self._reloadTableViewData(with: m)
                                }
                            }
                        }
                        if m.body.type == EMMessageBodyTypeVoice {
                            self.downloadFile(m) { (f) in
                                 self.conversation.updateMessageChange(m, error: nil)
                                DispatchQueue.main.async {
                                    self._reloadTableViewData(with: m)
                                }
                            }
                            
                        }
                        if m.body.type == EMMessageBodyTypeVideo {
                            self.customDownloadVedioFile(m)
                        }
                    }
                }
                self.messageQueue.async {
                    let model = GetConllectionListSendModel()
                    model.pageIndex = 1
                    BoXinProvider.request(.GetConllectionList(model: model), callbackQueue: DispatchQueue.global()) { (result) in
                        switch result {
                        case .success(let res):
                            if res.statusCode == 200 {
                                if let model = GetConllectionListReciveModel.deserialize(from: try? res.mapString()) {
                                    guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                        return
                                    }
                                    if model.code == 200 {
                                        guard let servermsgs = model.data else {
                                            DispatchQueue.main.async {
                                                self.tableView.mj_header?.endRefreshing()
                                            }
                                            return
                                        }
                                        self.messageQueue.async {
                                            if servermsgs.count == 0 {
                                                DispatchQueue.main.async {
                                                    self.tableView.mj_header?.endRefreshing()
                                                }
                                                return
                                            }
                                            let msgs = servermsgs.sorted { (a, b) -> Bool in
                                                return a?.create_time ?? 0 < b?.create_time ?? 1
                                            }.map { (a) -> EMMessage? in
                                                guard let m = a?.toMessage() else {
                                                    return a?.toMessage()
                                                }
                                                return m
                                            }
                                            var marr = Array<EMMessage>()
                                            for m in msgs {
                                                if m != nil {
                                                    var needAdd = true
                                                    guard let msgsourse = self.messsagesSource as? [EMMessage] else {
                                                        marr.append(m!)
                                                         self.conversation.insert(m, error: nil)
                                                        continue
                                                    }
                                                    for ms in msgsourse {
                                                        if ms.messageId == m?.messageId {
                                                            needAdd = false
                                                            break
                                                        }
                                                    }
                                                    if needAdd {
                                                        if msgsourse.count == 0 {
                                                            self.messsagesSource.insert(m as Any, at: 0)
                                                            self.conversation.insert(m, error: nil)
                                                            continue
                                                        }
                                                        for (idx,obj) in msgsourse.enumerated() {
                                                            if idx == 0 && m?.timestamp ?? 0 < obj.timestamp {
                                                                self.messsagesSource.insert(m as Any, at: 0)
                                                                self.conversation.insert(m, error: nil)
                                                                break
                                                            }
                                                            if idx + 1 < msgsourse.count {
                                                                if obj.timestamp < m?.timestamp ?? 0 && msgsourse[idx+1].timestamp > m?.timestamp ?? 0 {
                                                                    self.messsagesSource.insert(m as Any, at: idx + 1)
                                                                    self.conversation.insert(m, error: nil)
                                                                    break
                                                                }
                                                            }else{
                                                                self.messsagesSource.add(m as Any)
                                                                self.conversation.insert(m, error: nil)
                                                                break
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            self.conversation.markAllMessages(asRead: nil)
                                            DispatchQueue.main.async {
                                                self.tableView.mj_header?.endRefreshing()
                                            }
                                            self.messageTimeIntervalTag = 0
                                            if let msgarr = self.formatMessages(self.messsagesSource as? [Any]) {
                                                self.dataArray.removeAllObjects()
                                                self.dataArray.addObjects(from: msgarr)
                                                DispatchQueue.main.async {
                                                    self.tableView.reloadData()
                                                    if self.dataArray.count > 1 {
                                                        self.tableView.scrollToRow(at: IndexPath(row: self.dataArray.count - 1, section: 0), at: .top, animated: false)
                                                    }
                                                }
                                                for m in marr {
                                                    if m.body.type == EMMessageBodyTypeImage {
                                                       self.downloadThumbnailImage(m) {
                                                           DispatchQueue.main.async {
                                                               self._reloadTableViewData(with: m)
                                                           }
                                                       }
                                                    }
                                                    if m.body.type == EMMessageBodyTypeVoice {
                                                        self.downloadFile(m) { (f) in
                                                            self.conversation.updateMessageChange(m, error: nil)
                                                            DispatchQueue.main.async {
                                                                self._reloadTableViewData(with: m)
                                                            }
                                                        }
                                                        
                                                    }
                                                    if m.body.type == EMMessageBodyTypeVideo {
                                                        self.customDownloadVedioFile(m)
                                                    }
                                                }
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
                                                let sb = UIStoryboard(name: "Main", bundle: nil)
                                                let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                                vc.modalPresentationStyle = .overFullScreen
                                                UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                            }
                                        }
                                        DispatchQueue.main.async {
                                            self.tableView.mj_header?.endRefreshing()
                                        }
                                        DispatchQueue.main.async {
                                            UIApplication.shared.keyWindow?.makeToast(model.message)
                                        }
                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        self.tableView.mj_header?.endRefreshing()
                                    }
                                    DispatchQueue.main.async {
                                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.tableView.mj_header?.endRefreshing()
                                }
                                DispatchQueue.main.async {
                                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                                }
                            }
                        case .failure(_):
                            DispatchQueue.main.async {
                                self.tableView.mj_header?.endRefreshing()
                            }
                            DispatchQueue.main.async {
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadMoreMessage(_ messageId:String, messages:[Any]?) {
        let model = GetCollectionListBeginWithIDSendModel()
        model.collection_id = messageId
        BoXinProvider.request(.GetCollectionListBeginWithID(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    if let model = GetConllectionListReciveModel.deserialize(from: try? res.mapString()) {
                        guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                            return
                        }
                        if model.code == 200 {
                            self.messageQueue.async {
                                var messageNeedAdd = messages as? [EMMessage]
                                if messageNeedAdd == nil {
                                    messageNeedAdd = Array<EMMessage>()
                                }
                                guard let servermsgs = model.data else {
                                    if messageNeedAdd!.count > 0 {
                                        for (idx, obj) in messageNeedAdd!.enumerated() {
                                            self.messsagesSource.insert(obj, at: idx)
                                        }
                                        let msgdata =  self.formatMessages(messageNeedAdd)
                                        for (idx, obj) in msgdata!.enumerated() {
                                            self.dataArray.insert(obj, at: idx)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        DispatchQueue.main.async {
                                            self.tableView.mj_header?.endRefreshing()
                                        }
                                        self.tableView.reloadData()
                                    }
                                    return
                                }
                                let msgs = servermsgs.sorted { (a, b) -> Bool in
                                    return a?.create_time ?? 0 < b?.create_time ?? 1
                                }.map { (a) -> EMMessage? in
                                    guard let m = a?.toMessage() else {
                                        return a?.toMessage()
                                    }
                                    return m
                                }
                                for m in msgs {
                                    if m != nil {
                                        var needAdd = true
                                        for ms in messageNeedAdd! {
                                            if ms.messageId == m?.messageId {
                                                needAdd = false
                                                break
                                            }
                                        }
                                        if needAdd {
                                            for (idx,obj) in messageNeedAdd!.enumerated() {
                                                if idx == 0 && m?.timestamp ?? 0 < obj.timestamp {
                                                    messageNeedAdd?.insert(m!, at: 0)
                                                    self.conversation.insert(m, error: nil)
                                                    break
                                                }
                                                if idx + 1 < messageNeedAdd!.count {
                                                    if obj.timestamp < m?.timestamp ?? 0 && messageNeedAdd![idx+1].timestamp > m?.timestamp ?? 0 {
                                                        messageNeedAdd!.insert(m!, at: idx + 1)
                                                        self.conversation.insert(m, error: nil)
                                                        break
                                                    }
                                                }else{
                                                    messageNeedAdd?.append(m!)
                                                    self.conversation.insert(m, error: nil)
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                                for (idx, obj) in messageNeedAdd!.enumerated() {
                                    self.messsagesSource.insert(obj, at: idx)
                                }
                                self.conversation.markAllMessages(asRead: nil)
                                let msgdata =  self.formatMessages(messageNeedAdd)
                                for (idx, obj) in msgdata!.enumerated() {
                                    self.dataArray.insert(obj, at: idx)
                                }
                                DispatchQueue.main.async {
                                    DispatchQueue.main.async {
                                        self.tableView.mj_header?.endRefreshing()
                                    }
                                    self.tableView.reloadData()
                                }
                                for m in messageNeedAdd! {
                                    if m.body.type == EMMessageBodyTypeImage {
                                     
                                        self.downloadThumbnailImage(m) {
                                            DispatchQueue.main.async {
                                                self._reloadTableViewData(with: m)
                                            }
                                        }
                                    }
                                    if m.body.type == EMMessageBodyTypeVoice {
                                        self.downloadFile(m) { (f) in
                                            self.conversation.updateMessageChange(m, error: nil)
                                            DispatchQueue.main.async {
                                                self._reloadTableViewData(with: m)
                                            }
                                        }
                                        
                                    }
                                    if m.body.type == EMMessageBodyTypeVideo {
                                        self.customDownloadVedioFile(m)
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.tableView.mj_header?.endRefreshing()
                }
            }
        }
    }
    
    override func statusButtonSelcted(_ model: IMessageModel!, with messageCell: EaseMessageCell!) {
        if model.messageStatus == EMMessageStatusFailed {
            send(model.message, isNeedUploadFile: false)
        }
    }
    
    func downloadThumbnailImage(_ message:EMMessage, _ Complite:@escaping ()-> Void) {
        let body = message.body as! EMImageMessageBody
        if let path = SDImageCache.shared.cachePath(forKey: body.thumbnailRemotePath) {
            body.thumbnailLocalPath = path
            if let image = UIImage(contentsOfFile: path) {
                body.thumbnailSize = image.size
                message.body = body
                conversation.updateMessageChange(message, error: nil)
                Complite()
                return
            }
        }
        SDWebImageDownloader.shared.downloadImage(with: URL(string: body.thumbnailRemotePath), options: .allowInvalidSSLCertificates, progress: nil) { (img, data, err, f) in
            if let path = SDImageCache.shared.cachePath(forKey: body.thumbnailRemotePath) {
                body.thumbnailLocalPath = path
                body.thumbnailSize = img?.size ?? CGSize.zero
                message.body = body
                self.conversation.updateMessageChange(message, error: nil)
                Complite()
            }else{
                SDImageCache.shared.store(img, forKey: body.thumbnailRemotePath) {
                    body.thumbnailLocalPath = SDImageCache.shared.cachePath(forKey: body.thumbnailRemotePath)
                    body.thumbnailSize = img?.size ?? CGSize.zero
                    message.body = body
                    self.conversation.updateMessageChange(message, error: nil)
                    Complite()
                }
            }
        }
    }

}
