//
//  BoXinUtil.swift
//  boxin
//
//  Created by guduzhonglao on 6/19/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import Foundation

let dbQuese = DispatchQueue(label: "dbQuese")


@objc class BoXinUtil:NSObject {
    
    @objc static func getAllFace() -> NSArray {
        return NSArray(array: QueryFriend.shared.GetAllFace())
    }
    
    @objc static func getUserInfo() -> UserModel {
        let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
        let model = UserModel()
        model.userID = data?.db?.user_id ?? ""
        model.userName=data?.db?.user_name ?? ""
        model.userIDCard = data?.db?.id_card ?? ""
        model.userImg=data?.db?.portrait ?? ""
        return model
    }
        
    @objc static func getNikeName(id:String) -> String {
        let data = QueryFriend.shared.queryFriend(id: id)
        if data != nil {
            return data!.name!
        }
        let da = QueryFriend.shared.queryStronger(id: id)
        return da?.name ?? ""
    }
    
    /// 获取通话用户信息
    ///
    /// - Parameter id: 用户ID
    /// - Returns: 用户信息
    @objc static func getCallModel(id:String) -> callPhoneUserModel {
        let data = QueryFriend.shared.queryFriend(id: id)
        if data != nil {
            let model = callPhoneUserModel()
            model.user_Name = data?.name ?? ""
            model.user_Pic = data?.portrait ?? ""
            return model
        }
        let da = QueryFriend.shared.queryStronger(id: id)
        let model = callPhoneUserModel()
        model.user_Name = da?.name ?? ""
        model.user_Pic = da?.portrait ?? ""
        return model
    }
    
    /// 读取通知栏响应点击
    @objc static func dissmissGotoChat() {
        let app = UIApplication.shared.delegate as? AppDelegate
        DispatchQueue.main.async {
            if let apns = app?.apnsData {
                if let group = apns.g {
                    if let chat = UIViewController.currentViewController() as? ChatViewController {
                        if chat.conversation.conversationId == group {
                            return
                        }
                        UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
                    }
                    UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                    let vc = ChatViewController(conversationChatter: group, conversationType: EMConversationTypeGroupChat)
                    if let data = QueryFriend.shared.queryGroup(id: group) {
                        vc?.title = data.groupName
                    }else{
                        if let da = QueryFriend.shared.getGroupName(id: group){
                            vc?.title = da
                        }
                    }
                    UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
                    app?.apnsData = nil
                }else{
                    if let chat = UIViewController.currentViewController() as? ChatViewController {
                        if chat.conversation.conversationId == apns.f {
                            return
                        }
                        UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
                    }
                    UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                    let vc = ChatViewController(conversationChatter: apns.f, conversationType: EMConversationTypeChat)
                    if apns.f != nil {
                        if let data = QueryFriend.shared.queryFriend(id: apns.f!) {
                            vc?.title = data.name
                        }else{
                            if let da = QueryFriend.shared.queryStronger(id: apns.f!) {
                                vc?.title = da.name
                            }
                        }
                    }
                    UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
                    app?.apnsData = nil
                }
            }
        }
    }
    
    /// 获取个人信息
    ///
    /// - Returns: 获取个人信息
    @objc static func getMySelfInfo() -> MySelfModel {
        let data = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
        let model = MySelfModel()
        model.userID = data?.db?.user_id
        model.headURL = data?.db?.portrait
        model.idCard = data?.db?.id_card
        model.phone = data?.db?.mobile
        model.userName = data?.db?.user_name
        return model
    }
    
    /// 修改头像
    ///
    /// - Parameters:
    ///   - image: 头像
    ///   - complite: 修改头像完成回调
    @objc static func uploadPortrait(image:UIImage, complite:((Bool) -> Void)?) {
        if image == nil {
            complite?(false)
            return
        }
        let v = UIView(frame: UIScreen.main.bounds)
        v.backgroundColor = UIColor.clear
        UIApplication.shared.keyWindow?.addSubview(v)
        let app = UIApplication.shared.delegate as! AppDelegate
        SVProgressHUD.show()
        reqquestQueue.addOperation {
            let put = OSSPutObjectRequest()
            put.bucketName = "hgjt-oss"
            put.uploadingData = image.jpegData(compressionQuality: 1)!
            let filename = String(format: "%@.jpg", UUID().uuidString.replacingOccurrences(of: "-", with: ""))
            put.objectKey = String(format: "im19060501/%@", filename)
            let task = app.ossClient?.putObject(put)
            task?.continue({ (t) -> Any? in
                if t.error == nil {
                    reqquestQueue.addOperation {
                        BoXinUtil.changePortrait(fileName: filename, complite: complite, view: v)
                    }
                }else{
                    print(t.error.debugDescription)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        v.removeFromSuperview()
                        complite?(false)
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("UploadFileFailed",  comment: "Upload file failed"))
                    }
                }
                return nil
            })
        }
    }
    
    static func changePortrait(fileName:String?, complite:((Bool) -> Void)?,view:UIView) {
        let model = ChangePortraitSendModel()
        model.portrait = fileName
        BoXinProvider.request(.ChangePortrait(model: model)) { (result) in
            switch(result){
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            if model.code == 200 {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                BoXinUtil.getUserInfo { (b) in
                                    DispatchQueue.main.async {
                                        view.removeFromSuperview()
                                        complite?(true)
                                        UIApplication.shared.keyWindow?.makeToast("修改头像成功")
                                    }
                                }
                                BoXinUtil.getMyGroup({ (b) in
                                    
                                })
                                SVProgressHUD.dismiss()
                                
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
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                    UIApplication.shared.keyWindow?.makeToast(model.message)
                                    SVProgressHUD.dismiss()
                                    view.removeFromSuperview()
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                complite?(false)
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                                view.removeFromSuperview()
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            complite?(false)
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                            view.removeFromSuperview()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        complite?(false)
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        SVProgressHUD.dismiss()
                        view.removeFromSuperview()
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    complite?(false)
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    /// 二维码扫码后解析
    ///
    /// - Parameter qrcode: 二维码
    @objc static func onScaned(qrcode: String) {
        SVProgressHUD.show()
        let m = QRcodeModel.deserialize(from: qrcode)
        if m == nil {
            SVProgressHUD.dismiss()
            return
        }
        if m?.type == 1 {
            guard let uid = m?.id else {
                SVProgressHUD.dismiss()
                return
            }
            if QueryFriend.shared.checkFriend(userID: uid) {
                if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
                    for c in contact {
                        if c?.data != nil {
                            for d in c!.data! {
                                if d?.user_id == uid {
                                    let vc = UserDetailViewController()
                                    vc.model=d
                                    vc.type=4
                                    UIViewController.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
                                    SVProgressHUD.dismiss()
                                    return
                                }
                            }
                        }
                    }
                }
            }
            reqquestQueue.addOperation {
                let model = GetUserByIDSendModel()
                model.user_id = m?.id
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
                                        SVProgressHUD.dismiss()
                                        UIViewController.getCurrentVC().navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
                                        let vc = UserDetailViewController()
                                        vc.model = FriendData(data: md.data)
                                        QueryFriend.shared.addStranger(id: md.data!.user_id!, user_name: md.data!.user_name!, portrait1: md.data!.portrait!, card: md.data!.id_card!)
                                        DispatchQueue.main.async {
                                            UIViewController.getCurrentVC().navigationController?.pushViewController(vc, animated: false)
                                        }
                                    }else{
                                        if md.message == "请重新登录" {
                                            BoXinUtil.Logout()
                                            if (UIViewController.getCurrentVC() as? BootViewController) != nil {
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
                                        UIApplication.shared.keyWindow?.makeToast(md.message)
                                        SVProgressHUD.dismiss()
                                    }
                                }else{
                                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    SVProgressHUD.dismiss()
                                }
                            }catch{
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            print(res.statusCode)
                            SVProgressHUD.dismiss()
                        }
                    case .failure(let err):
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        print(err.errorDescription)
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
        if m?.type == 2 {
            SVProgressHUD.dismiss()
            return
        }
        if m?.type == 3 {
            let vc = ScanQRCodeLoginViewController()
            vc.qr_id = m?.id
            UIViewController.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
            SVProgressHUD.dismiss()
            return
        }
    }
    
    /// 从服务器拉取好友
    ///
    /// - Parameters:
    ///   - id: 好友ID
    ///   - complete: 完成回调
    @objc static func getFriendFronServer(id:String,complete:@escaping (FriendData?)->Void) {
        reqquestQueue.addOperation {
            let friend = BoXinUtil.getFriendData(id: id)
            let m = GetUserByIDSendModel()
            m.user_id = id
            BoXinProvider.request(.GetUserByID(model: m)) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let md = GetUserByIDReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(md.code ?? 0) else {
                                    return
                                }
                                if md.code == 200 {
                                    friend?.id_card = md.data?.id_card
                                    friend?.friend_self_name = md.data?.user_name
                                    friend?.portrait = md.data?.portrait
                                    complete(friend)
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
                                        DispatchQueue.main.async {
                                            let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                            vc.modalPresentationStyle = .overFullScreen
                                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        UIApplication.shared.keyWindow?.makeToast(md.message)
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
                        print(res.statusCode)
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        print(err)
                    }
                }
            }
        }
    }
    
    /// 获取好友模型
    ///
    /// - Parameter id: 好友ID
    /// - Returns: 好友模型可能为空
    @objc static func getFriendData(id:String) -> FriendData? {
        if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
            for c in contact {
                if c?.data != nil {
                    for d in c!.data! {
                        if d?.user_id == id {
                            return d!
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// 获取群组模型
    ///
    /// - Parameter groupId: 群组ID
    /// - Returns: 群组模型
    @objc static func getGroupViewModel(groupId:String) -> GroupViewModel? {
        return QueryFriend.shared.queryGroup(id: groupId)
    }
    
    /// 获取群成员模型
    ///
    /// - Parameters:
    ///   - groupId: 群ID
    ///   - userId: 成员ID
    /// - Returns: 成员模型
    @objc static func getGroupMemberModel(groupId:String, userId:String) -> GroupMemberData? {
        return QueryFriend.shared.getGroupUser(userId: userId, groupId: groupId)
    }
    
    /// 从服务器获取群成员
    ///
    /// - Parameters:
    ///   - groupId: 群ID
    ///   - userId: 用户ID
    ///   - complite: 完成回调
    @objc static func getGroupMemberFromServer(groupId:String, userId:String, complite:@escaping (GroupMemberData?) -> Void) {
        BoXinUtil.getGroupOneMember(groupID: groupId, userID: userId) { (b) in
            complite(BoXinUtil.getGroupMemberModel(groupId: groupId, userId: userId))
        }
    }
    
    /// 设置群内关注
    ///
    /// - Parameters:
    ///   - groupMember: 成员模型
    ///   - isFocus: 当前是否关注
    ///   - complite: 完成回调
    @objc static func setGroupMemberFocus(groupMember:GroupMemberData?,isFocus:Bool,complite:@escaping (Bool) -> Void) {
        SVProgressHUD.show()
        if isFocus {
            reqquestQueue.addOperation {
                let model = FocusSendModel()
                model.group_id = groupMember?.group_id
                model.focusUserId = groupMember?.user_id
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
                                        QueryFriend.shared.deleteFocus(userId: groupMember!.user_id!, groupId: groupMember!.group_id!)
                                        NotificationCenter.default.post(Notification(name: Notification.Name("UpdateFocus")))
                                        complite(true)
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
                                            let nav = UINavigationController(rootViewController: WelcomeViewController())
                                            nav.modalPresentationStyle = .overFullScreen
                                            UIViewController.currentViewController()?.present(nav, animated: false, completion: nil)
                                        }
                                        UIApplication.shared.keyWindow?.makeToast(model.message)
                                        complite(false)
                                        SVProgressHUD.dismiss()
                                    }
                                }else{
                                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    complite(false)
                                    SVProgressHUD.dismiss()
                                }
                            }catch{
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                complite(false)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            complite(false)
                            SVProgressHUD.dismiss()
                        }
                    case .failure(let err):
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                        complite(false)
                        print(err.errorDescription!)
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }else{
            reqquestQueue.addOperation {
                let model = FocusSendModel()
                model.group_id = groupMember?.group_id
                model.focusUserId = groupMember?.user_id
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
                                        QueryFriend.shared.addFocus(groupId: groupMember!.group_id!, id: EMClient.shared()!.currentUsername, target: groupMember!.user_id!)
                                        NotificationCenter.default.post(Notification(name: Notification.Name("UpdateFocus")))
                                        complite(true)
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
                                            let nav = UINavigationController(rootViewController: WelcomeViewController())
                                            nav.modalPresentationStyle = .overFullScreen
                                            UIViewController.currentViewController()?.present(nav, animated: false, completion: nil)
                                        }
                                        UIApplication.shared.keyWindow?.makeToast(model.message)
                                        complite(false)
                                        SVProgressHUD.dismiss()
                                    }
                                }else{
                                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    complite(false)
                                    SVProgressHUD.dismiss()
                                }
                            }catch{
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                complite(false)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            complite(false)
                            SVProgressHUD.dismiss()
                        }
                    case .failure(let err):
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                        complite(false)
                        print(err.errorDescription!)
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    @objc static func setShieldSingle(groupMember:GroupMemberData?,complite:@escaping (Bool) -> Void) {
        SVProgressHUD.show()
        reqquestQueue.addOperation {
            let  model = ShieldSigleSendModel()
            model.group_id = groupMember?.group_id
            model.groupUserId = groupMember?.user_id
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
                                    BoXinUtil.getGroupMember(groupID: groupMember!.group_id!, Complite: { (b) in
                                        
                                        if b {
                                            DispatchQueue.main.async {
                                                let body = EMCmdMessageBody(action: "")
                                                let dic = ["type":"qun_shield","id":groupMember!.group_id!,"userid":groupMember?.user_id,"qun_shield":"1"]
                                                let msg = EMMessage(conversationID: groupMember!.group_id!, from: EMClient.shared()!.currentUsername, to: groupMember!.group_id!, body: body, ext: dic as [AnyHashable : Any])
                                                msg?.chatType = EMChatTypeGroupChat
                                                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                    
                                                }, completion: { (msg, err) in
                                                    if err != nil {
                                                        print(err?.errorDescription)
                                                    }
                                                    
                                                })
                                                NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                                                complite(true)
                                                SVProgressHUD.dismiss()
                                            }
                                        }else
                                        {
                                            UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
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
                                    UIApplication.shared.keyWindow?.makeToast(model.message)
                                    complite(false)
                                    SVProgressHUD.dismiss()
                                    
                                }
                            }else{
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                complite(false)
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            complite(false)
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        complite(false)
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    complite(false)
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @objc static func cancelShieldSingle(groupMember:GroupMemberData?,complite:@escaping (Bool) -> Void) {
        SVProgressHUD.show()
        reqquestQueue.addOperation {
            let  model = ShieldSigleSendModel()
            model.group_id = groupMember?.group_id
            model.groupUserId = groupMember?.user_id
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
                                    BoXinUtil.getGroupMember(groupID: groupMember!.group_id!, Complite: { (b) in
                                        
                                        if b {
                                            DispatchQueue.main.async {
                                                let body = EMCmdMessageBody(action: "")
                                                let dic = ["type":"qun_shield","id":groupMember?.group_id,"userid":groupMember!.user_id,"qun_shield":"2"]
                                                let msg = EMMessage(conversationID: groupMember!.group_id!, from: EMClient.shared()!.currentUsername, to: groupMember!.group_id!, body: body, ext: dic as [AnyHashable : Any])
                                                msg?.chatType = EMChatTypeGroupChat
                                                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                    
                                                }, completion: { (msg, err) in
                                                    if err != nil {
                                                        print(err?.errorDescription)
                                                    }
                                                    
                                                })
                                                NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                                                complite(true)
                                                SVProgressHUD.dismiss()
                                            }
                                        }else
                                        {
                                            UIViewController.getCurrentVC().navigationController?.popToRootViewController(animated: true)
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
                                    UIApplication.shared.keyWindow?.makeToast(model.message)
                                    complite(false)
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                complite(false)
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            complite(false)
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        complite(false)
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    complite(false)
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @objc static func tackOutGroupMember(group:GroupViewModel?,groupMember:GroupMemberData?,complite:@escaping (Bool) -> Void) {
        SVProgressHUD.show()
        reqquestQueue.addOperation {
            let  model = AddBatchSendModel()
            model.group_id = groupMember?.group_id
            model.group_user_ids = groupMember?.user_id
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
                                    BoXinUtil.getGroupMember(groupID:groupMember!.group_id!, Complite: { (b) in
                                        
                                        if b {
                                            DispatchQueue.main.async {
                                                let body = EMCmdMessageBody(action: "")
                                                var dic = ["type":"qun","id":groupMember?.group_id]
                                                if group?.is_all_banned == 1 {
                                                    dic.updateValue("2", forKey: "grouptype")
                                                }else{
                                                    dic.updateValue("1", forKey: "grouptype")
                                                }
                                                let msg = EMMessage(conversationID: group!.groupId!, from: EMClient.shared()!.currentUsername, to: group!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                                msg?.chatType = EMChatTypeGroupChat
                                                EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                                    
                                                }, completion: { (msg, err) in
                                                    if err != nil {
                                                        print(err?.errorDescription)
                                                    }
                                                    
                                                })
                                                NotificationCenter.default.post(name: Notification.Name("UpdateGroup"), object: nil)
                                                UIViewController.getCurrentVC().navigationController?.popViewController(animated: true)
                                                complite(true)
                                                SVProgressHUD.dismiss()
                                            }
                                        }else
                                        {
                                            UIViewController.getCurrentVC().navigationController?.popToRootViewController(animated: true)
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
                                    UIApplication.shared.keyWindow?.makeToast(model.message)
                                    complite(false)
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                complite(false)
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            complite(false)
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        complite(false)
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    complite(false)
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @objc static func getFocusList(groupId:String) -> [String]? {
        return QueryFriend.shared.queryFocus(id: EMClient.shared()!.currentUsername, groupId: groupId)
    }
    
    static func getUserInfo(Complite:((Bool) -> Void)?) {
        BoXinProvider.request(.UserInfo(model: UserInfoSendModel()), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = UserInfoReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            res.request?.allHTTPHeaderFields
                            if model.code == 200 {
                                UserDefaults.standard.set(model.data?.toJSONString(), forKey: "userInfo")
                                DispatchQueue.main.async {
                                    Complite?(true)
                                }
                            }else{
                                if model.message == "请重新登录" {
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
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    UIViewController.currentViewController()?.view.makeToast(model.message)
                                    Complite?(false)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                Complite?(false)
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            Complite?(false)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        
                        Complite?(false)
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    Complite?(false)
                }
                print(err.errorDescription!)
            }
        }
        BoXinProvider.request(.UserInfo(model: UserInfoSendModel())) { (result) in
            
        }
    }
    
    static func getOnlyMyGroup(complite:@escaping ([GroupViewModel]?) -> Void) {
        BoXinProvider.request(.GetMyGroup(model: UserInfoSendModel()), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = GetMyGroupReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                if model.data == nil {
                                    complite(nil)
                                    return
                                }
                                var groups = Array<GroupViewModel>()
                                for g in model.data! {
                                    if g != nil {
                                        groups.append(g!.toGroupModel())
                                    }
                                }
                                complite(groups)
                                var conversation = EMClient.shared()?.chatManager.getAllConversations() as? [EMConversation]
                                conversation = conversation?.filter({ (c) -> Bool in
                                    if c.type == EMConversationTypeGroupChat {
                                        for data in model.data! {
                                            if data?.group_id == c.conversationId {
                                                return true
                                            }
                                        }
                                        EMClient.shared()?.chatManager.deleteConversation(c.conversationId, isDeleteMessages: true, completion: { (g, e) in
                                            return
                                        })
                                        return false
                                    }
                                    
                                    return true
                                })
                            }else{
                                if model.message == "请重新登录" {
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
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    UIViewController.currentViewController()?.view.makeToast(model.message)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }
    
    static func getMyGroup(_ Complite:((Bool) -> Void)?) {
        BoXinProvider.request(.GetMyGroup(model: UserInfoSendModel()), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = GetMyGroupReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                if model.data == nil {
                                    Complite?(true)
                                    return
                                }
                                for data in model.data! {
                                    dbQuese.async {
                                        QueryFriend.shared.addGroupTemp(group: data)
                                        DispatchQueue.global().async {
                                            if QueryFriend.shared.isNeedLoadGroup(id: data!.group_id!) {
                                                reqquestQueue.addOperation {
                                                    BoXinUtil.getGroupMember(groupID: data!.group_id!, Complite: nil)
                                                }
                                            }
                                        }
                                    }
                                }
                                var conversation = EMClient.shared()?.chatManager.getAllConversations() as? [EMConversation]
                                conversation = conversation?.filter({ (c) -> Bool in
                                    if c.type == EMConversationTypeGroupChat {
                                        for data in model.data! {
                                            if data?.group_id == c.conversationId {
                                                return true
                                            }
                                        }
                                        EMClient.shared()?.chatManager.deleteConversation(c.conversationId, isDeleteMessages: true, completion: { (g, e) in
                                            return
                                        })
                                        return false
                                    }
                                    
                                    return true
                                })
                                Complite?(true)
                            }else{
                                if model.message == "请重新登录" {
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
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    UIViewController.currentViewController()?.view.makeToast(model.message)
                                    Complite?(false)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                Complite?(false)
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            Complite?(false)
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        
                        Complite?(false)
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    
                    Complite?(false)
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }
    
    static func getGroupInfo(groupId:String, Complite:((Bool) -> Void)?) {
        reqquestQueue.addOperation {
            let model = DeleteGroupSendModel()
            model.group_id = groupId
            BoXinProvider.request(.GetGroupInfo(model: model), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
                switch result {
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = GroupInfoReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    dbQuese.async {
                                        QueryFriend.shared.deleteGroup(id: groupId)
                                        QueryFriend.shared.addGroup(id: model.data!.group_id!, nickName: model.data!.group_name!, portrait1: model.data!.group_portrait!, admin_id: model.data!.administrator_id!, is_admin1: model.data!.is_admin!, is_mg: model.data!.is_manager!, notice1: model.data?.notice, type: model.data!.group_type!, allMute: model.data!.is_all_banned!, pingbi: model.data!.is_pingbi!, userSum: model.data?.groupUserSum ?? 0)
                                        if model.data!.focusList != nil {
                                            for f in model.data!.focusList! {
                                                QueryFriend.shared.addFocus(groupId: model.data!.group_id!, id:f!.user_id!, target: f!.target_user_id!)
                                            }
                                        }
                                    }
                                    reqquestQueue.addOperation {
                                        BoXinUtil.getGroupMember(groupID: model.data!.group_id!, Complite: Complite)
                                    }
                                }else{
                                    if model.message == "请重新登录" {
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
                                            UIViewController.currentViewController()?.present(nav, animated: false, completion: nil)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        Complite?(false)
                                        UIViewController.currentViewController()?.view.makeToast(model.message)
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    Complite?(false)
                                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                }
                            }
                        }catch{
                            DispatchQueue.main.async {
                                Complite?(false)
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            Complite?(false)
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        }
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        Complite?(false)
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    }
                    print(err.errorDescription!)
                }
            }
        }
    }
    
    static func getGroupOnlyInfo(groupId:String, Complite:((Bool) -> Void)?) {
        let model = DeleteGroupSendModel()
        model.group_id = groupId
        BoXinProvider.request(.GetGroupInfo(model: model), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = GroupInfoReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                QueryFriend.shared.deleteGroup(id: groupId)
                                QueryFriend.shared.addGroup(id: model.data!.group_id!, nickName: model.data!.group_name!, portrait1: model.data!.group_portrait!, admin_id: model.data!.administrator_id!, is_admin1: model.data!.is_admin!, is_mg: model.data!.is_manager!, notice1: model.data?.notice, type: model.data!.group_type!, allMute: model.data!.is_all_banned!, pingbi: model.data!.is_pingbi!, userSum: model.data?.groupUserSum ?? 0)
                                if model.data!.focusList != nil {
                                    for f in model.data!.focusList! {
                                        QueryFriend.shared.addFocus(groupId: model.data!.group_id!, id:f!.user_id!, target: f!.target_user_id!)
                                    }
                                }
                                Complite?(true)
                            }else{
                                if model.message == "请重新登录" {
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
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    Complite?(false)
                                    UIViewController.currentViewController()?.view.makeToast(model.message)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                Complite?(false)
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            Complite?(false)
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        Complite?(false)
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    Complite?(false)
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }
    @objc static func GetFace() -> NSMutableArray
    {
        return NSMutableArray(array: QueryFriend.shared.GetAllFace())
    }
    
    static func getGroupOneMember(groupID:String, userID:String, Complite:((Bool) -> Void)?) {
        let model = GetOneGroupUserInfoSendModel()
        model.group_id = groupID
        model.target_user_id = userID
        BoXinProvider.request(.GetOneGroupUserInfo(model: model), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let mo = GetOneGroupUserInfoReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(mo.code ?? 0) else {
                                return
                            }
                            if mo.code == 200 {
                                dbQuese.async {
                                    QueryFriend.shared.addGroupUser(model: mo.data!)
                                    QueryFriend.shared.addStronger(member: mo.data!)
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    DispatchQueue.main.async {
                                        Complite?(true)
                                    }
                                }
                            }else{
                                if mo.message == "请重新登录" {
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
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    Complite?(false)
                                    UIViewController.currentViewController()?.view.makeToast(mo.message)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                Complite?(false)
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            Complite?(false)
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        Complite?(false)
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    Complite?(false)
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }
    
    static func getGroupMember(groupID:String, Complite:((Bool) -> Void)?) {
        let model = DeleteGroupSendModel()
        model.group_id = groupID
        BoXinProvider.request(.GroupMemberList(model: model), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let mo = GetGroupMemberListReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(mo.code ?? 0) else {
                                return
                            }
                            if mo.code == 200 {
                                dbQuese.async {
                                    QueryFriend.shared.deleteGroupMember(id: groupID)
                                    for member in mo.data! {
                                        QueryFriend.shared.addGroupUser(model: member)
                                        QueryFriend.shared.addStronger(member: member!)
                                        
                                    }
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    DispatchQueue.main.async {
                                        Complite?(true)
                                    }
                                }
                            }else{
                                if mo.message == "请重新登录" {
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
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    Complite?(false)
                                    UIViewController.currentViewController()?.view.makeToast(mo.message)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                Complite?(false)
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            Complite?(false)
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        Complite?(false)
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    Complite?(false)
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }
    
    static func getFriends(_ Complite:((Bool) -> Void)?) {
        BoXinProvider.request(.FriendListWithFenzu(model: UserInfoSendModel()), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = GetFriendWithGroupReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                let friendGroupInfo = model.data.map { (f) -> FriendGroupInfoData in
                                    let fd = FriendGroupInfoData()
                                    fd.fenzu_id = f.fenzu_id
                                    fd.fenzu_name = f.fenzu_name
                                    fd.sort_num = f.sort_num
                                    return fd
                                }
                                UserDefaults.standard.set(friendGroupInfo.toJSONString(), forKey: "FriendGroup")
                                dbQuese.async {
                                    for fd in model.data {
                                        for f in fd.friendList {
                                            QueryFriend.shared.addFriend(f)
                                        }
                                    }
                                }
                                UserDefaults.standard.setValue(model.data.toJSONString(), forKey: "Contact1")
                                UserDefaults.standard.synchronize()
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
                                    Complite?(false)
                                    UIApplication.shared.keyWindow?.makeToast(model.message)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                Complite?(false)
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            Complite?(false)
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        Complite?(false)
                        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    Complite?(false)
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
        BoXinProvider.request(.FriendList(model: UserInfoSendModel()), callbackQueue: DispatchQueue.global(), progress: nil) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = FriendListReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                BoXinUtil.sorted(model: model.data, Complite: Complite)
                            }else{
                                if (model.message?.contains("请重新登录"))! {
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
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async {
                                    UIViewController.currentViewController()?.view.makeToast(model.message)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            }
                        }
                    }catch{
                        DispatchQueue.main.async {
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    }
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }
    
    static func sorted(model :[FriendData?]?, Complite:((Bool) -> Void)?) {
        if model == nil {
            BoXinUtil.getFriends(Complite)
            return
        }
        var dataArray:Array = Array<FriendViewModel?>()
        var data = model
        var star:FriendViewModel?
        var isEnd = false
        while !isEnd {
            if let m = data {
                if m.count == 0 {
                    isEnd = true
                    if star != nil {
                        dataArray.append(star)
                        star =  nil
                    }
                }
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
            var lastCount:Int = 0
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
                        if lastCount == star?.data?.count {
                            dataArray.append(star)
                            star =  nil
                        }else{
                            lastCount = star!.data!.count
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
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
        Complite?(true)
    }
    
    static func getFriendModel(_ id:String) -> FriendData? {
        if let contact = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact")) {
            for co in contact {
                guard let d = co?.data else {
                    continue
                }
                for c in d {
                    if id == c?.user_id {
                        return c
                    }
                }
            }
        }
        return nil
    }
    
    static func checkChatTop(id:String?) -> Bool {
        if let data = [ChatTapData].deserialize(from: UserDefaults.standard.string(forKey: "ChatTop")) {
            for i in stride(from: 0, to: data.count, by: 1) {
                if data[i]?.target_id == id {
                    return true
                }
            }
        }
        return false
    }
    
    static func getChatTop(Complite:((Bool) -> Void)?) {
        BoXinProvider.request(.GetChatTap(model: UserInfoSendModel())) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = GetChatTopReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                if let data = model.data as? [ChatTapData] {
                                    let str = data.toJSONString()
                                    UserDefaults.standard.setValue(str, forKey: "ChatTop")
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    DispatchQueue.main.async {
                                        Complite?(true)
                                    }
                                }else{
                                    Complite?(false)
                                }
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
                                    UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                }
                                UIViewController.currentViewController()?.view.makeToast(model.message)
                                Complite?(false)
                            }
                        }else{
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            Complite?(false)
                        }
                    }catch{
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        Complite?(false)
                    }
                }else{
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    Complite?(false)
                }
            case .failure(let err):
                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                Complite?(false)
            }
        }
    }
    
    /// 退出登录
    @objc static func Logout() {
        DispatchQueue.global().async {
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "userInfo")
            UserDefaults.standard.removeObject(forKey: "Contact")
            UserDefaults.standard.removeObject(forKey: "Contact1")
            UserDefaults.standard.removeObject(forKey: "DeleteCollection")
            EMClient.shared()?.chatManager.deleteConversation("collection", isDeleteMessages: true, completion: nil)
            BoXinProvider.manager.session.reset {
                
            }
            reqquestQueue.cancelAllOperations()
            QueryFriend.shared.clearFriend()
            QueryFriend.shared.clearGroup()
            QueryFriend.shared.clearGroupUser()
            QueryFriend.shared.clearFocus()
            QueryFriend.shared.cleanFace()
            QueryFriend.shared.clearGroupTemp()
            QueryFriend.shared.cleanChatBK()
            EMClient.shared()?.options.isAutoLogin = false
            EMClient.shared()?.logout(true)
        }
        DispatchQueue.main.async {
            let app = UIApplication.shared.delegate as! AppDelegate
            app.addFriendCount = 0
            UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    static func GetAllFace(Complite:((Bool) -> Void)?) {
        QueryFriend.shared.cleanFace()
        BoXinProvider.request(.AllFaceList(model: UserInfoSendModel())) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = AllFaceListModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                if model.data != nil
                                {
                                    QueryFriend.shared.cleanFace()
                                    for d in model.data!
                                    {
                                        if d != nil
                                        {
                                            QueryFriend.shared.AddFace(id: d!.phiz_id!)
                                            let face = FaceViewModel()
                                            face.url = d?.phiz_url
                                            face.id = d?.phiz_id
                                            if let path = SDImageCache.shared.cachePath(forKey: face.url) {
                                                face.path = path
                                                let image = SDImageCache.shared.imageFromDiskCache(forKey: face.url)
                                                SDImageCache.shared.storeImage(toMemory: image, forKey: face.url)
                                                guard let img = image else {
                                                    face.faceH = Int(d?.high ?? "") ?? 0
                                                    face.faceW = Int(d?.width ?? "") ?? 0
                                                    QueryFriend.shared.updateFace(model: face)
                                                    continue
                                                }
                                                face.faceH = Int(img.size.height)
                                                    
                                                face.faceW = Int(img.size.width)
                                                QueryFriend.shared.updateFace(model: face)
                                            }else{
                                                SDWebImageDownloader.shared.downloadImage(with: URL(string: face.url!), options: .scaleDownLargeImages, progress: nil, completed: { (image, data, err, fanish) in
                                                    if fanish {
                                                        SDImageCache.shared.store(image, forKey: face.url, completion: {
                                                            face.path = SDImageCache.shared.cachePath(forKey: face.url)
                                                            face.faceH = Int(image?.size.height ?? 0)
                                                            
                                                        face.faceW = Int(image?.size.width ?? 0)
                                                            QueryFriend.shared.updateFace(model: face)
                                                            NotificationCenter.default.post(Notification(name: Notification.Name("onEmojiChanged")))
                                                        })
                                                    }
                                                })
                                            }
                                        }
                                    }
                                    NotificationCenter.default.post(Notification(name: Notification.Name("onEmojiChanged")))
                                    Complite?(true)
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
                                Complite?(false)
                                UIViewController.currentViewController()?.view.makeToast(model.message)
                            }
                        }else{
                            Complite?(false)
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                        
                    }catch{
                        Complite?(false)
                        UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                    }
                }else{
                    Complite?(false)
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                }
            case .failure(let err):
                Complite?(false)
                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
            }
            
        }
    }
    
    @objc static func isTokenExpired(_ code:Int) -> Bool {
        if code == 502 {
            BoXinUtil.Logout()
            DispatchQueue.main.async {
                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
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
            return false
        }
        return true
    }
    
    @objc static func getIMEI() -> String {
        if let token = UserDefaults.standard.string(forKey: "IMUUID") {
            return token
        }
        if let token = UserDefaults.standard.string(forKey: "deviceToken") {
            return token
        }
        let token = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        UserDefaults.standard.set(token, forKey: "IMUUID")
        UserDefaults.standard.synchronize()
        return token
    }
    
    static func getTime() -> String {
        let t = Date().timeIntervalSince1970*1000
        return String(format: "%.0f", t)
    }
}
