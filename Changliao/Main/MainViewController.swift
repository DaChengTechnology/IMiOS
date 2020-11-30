//
//  MainViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage

@objc class MainViewController: UITabBarController,EMChatManagerDelegate,EMContactManagerDelegate,UITabBarControllerDelegate {
    
    var isFirst:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tabBar.unselectedItemTintColor = UIColor.hexadecimalColor(hexadecimal: "#DAD9DC")
        self.navigationController?.navigationBar.isTranslucent = false
        self.delegate = self
        self.navigationController?.navigationBar.shadowImage = UIImage()
        NotificationCenter.default.addObserver(self, selector: #selector(successLogin), name: NSNotification.Name("Logined"), object: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.addFriendCount != 0 {
            self.tabBar.items?[1].badgeValue = String(format: "%d", app.addFriendCount)
        }else{
            self.tabBar.items?[1].badgeValue = nil
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.addFriendCount != 0 {
            self.tabBar.items?[1].badgeValue = String(format: "%d", app.addFriendCount)
        }else{
            self.tabBar.items?[1].badgeValue = nil
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.addFriendCount != 0 {
            self.tabBar.items?[1].badgeValue = String(format: "%d", app.addFriendCount)
        }else{
            self.tabBar.items?[1].badgeValue = nil
        }
        NotificationCenter.default.addObserver(self, selector: #selector(successLogin), name: Notification.Name("LoginSuccess"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        if UserDefaults.standard.string(forKey: "token") == nil {
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
        super.viewDidAppear(animated)
        if isFirst {
            isFirst = false
            firstBoot()
        }
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.addFriendCount != 0 {
            self.tabBar.items?[1].badgeValue = String(format: "%d", app.addFriendCount)
        }else{
            self.tabBar.items?[1].badgeValue = nil
        }
        if let short = app.shortcutType {
            if short == "ScanQRCode" {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                let vc = NewSaoSaoViewController()
                vc.saoyisaoBlock={(Str)in
                    self.onScaned(qrcode: Str)
                }
                self.navigationController?.pushViewController(vc, animated: false)
                app.shortcutType = nil
            }
            if short == "MyQRCode" {
                 self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
                let m = QRcodeModel()
                m.id = model?.db?.user_id
                let vc = ErWeiMaViewController()
                vc.jsonStr = m.toJSONString() ?? ""
                self.navigationController?.pushViewController(vc, animated: false)
                app.shortcutType = nil
            }
            return
        }
        if let group = app.group {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "GroupShake") as! GroupShakeViewController
            vc.groupId = group.id
            vc.groupOwnerName = group.name
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
            app.group = nil
            return
        }
        if let person = app.person {
            let vc = shakeVc()
            vc.username = person.name!
            vc.userIcon = person.portrait!
            vc.userId = person.id!
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false, completion: nil)
            app.person = nil
            return
        }
        if let apns = app.apnsData {
            if let group = apns.g {
                 self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                let vc = ChatViewController(conversationChatter: group, conversationType: EMConversationTypeGroupChat)
                let group1 = QueryFriend.shared.queryGroup(id: group)
                vc?.title = group1?.groupName
                self.navigationController?.pushViewController(vc!, animated: false)
                app.apnsData = nil
            }else{
                 self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                let vc = ChatViewController(conversationChatter: apns.f, conversationType: EMConversationTypeChat)
                if let person = QueryFriend.shared.queryFriend(id: apns.f!) {
                    vc?.title = person.name
                }else{
                    let p = QueryFriend.shared.queryStronger(id: apns.f!)
                    vc?.title = p?.name
                }
                self.navigationController?.pushViewController(vc!, animated: false)
                app.apnsData = nil
            }
            return
        }
    }
    
    func firstBoot() {
        if let _ = UserDefaults.standard.string(forKey: "token"){
            reqquestQueue.addOperation {
                BoXinUtil.getUserInfo(Complite: nil)
            }
            reqquestQueue.addOperation {
                BoXinUtil.GetAllFace(Complite: nil)
            }
            reqquestQueue.addOperation {
                BoXinUtil.getFriends(nil)
            }
            reqquestQueue.addOperation {
                BoXinUtil.getMyGroup(nil)
            }
            reqquestQueue.addOperation {
                BoXinUtil.getChatTop(Complite: nil)
            }
            EMClient.shared()?.login(withUsername: UserDefaults.standard.object(forKey: "username") as? String, password: UserDefaults.standard.object(forKey: "password") as? String, completion: { (username, err) in
                if let e = err{
                    print(e)
                }else{
                    EMClient.shared()?.options.isAutoLogin = true
                }
            })
        }
        DemoCallManager.shared()
        EMClient.shared()?.chatManager.add(self, delegateQueue: DispatchQueue.global())
        EMClient.shared()?.contactManager.add(self, delegateQueue: DispatchQueue.main)
    }
    @objc func  successLogin()
    {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
        NotificationCenter.default.post(name: NSNotification.Name("UpdateFriend"), object: nil)
        NotificationCenter.default.post(Notification(name: Notification.Name("UserInfoSuccess")))
        DispatchQueue.main.async {
            self.selectedIndex = 0
            self.fd_prefersNavigationBarHidden = false
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationBar.shadowImage = UIImage(named: "渐变填充1")
        }
        reqquestQueue.addOperation {
            BoXinUtil.GetAllFace(Complite: nil)
        }
        reqquestQueue.addOperation {
            BoXinUtil.getFriends(nil)
        }
        reqquestQueue.addOperation {
            BoXinUtil.getMyGroup(nil)
        }
        reqquestQueue.addOperation {
            BoXinUtil.getChatTop(Complite: nil)
        }
    }
    
    func onLogin() {
        reqquestQueue.addOperation {
            BoXinUtil.GetAllFace(Complite: nil)
        }
        reqquestQueue.addOperation {
            BoXinUtil.getFriends({(b) in
                NotificationCenter.default.post(name: NSNotification.Name("UpdateFriend"), object: nil)
            })
        }
        reqquestQueue.addOperation {
            BoXinUtil.getMyGroup(nil)
        }
        reqquestQueue.addOperation {
            BoXinUtil.getChatTop(Complite: nil)
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
    }
    
    func friendRequestDidReceive(fromUser aUsername: String!, message aMessage: String!) {
        NotificationCenter.default.post(Notification(name: Notification.Name("friendRequestDidReceive")))
        let app = UIApplication.shared.delegate as! AppDelegate
        if UserDefaults.standard.string(forKey: "newMessage") == "1" {
            if UserDefaults.standard.string(forKey: "sound") == "1" && UserDefaults.standard.string(forKey: "shake") == "1"
            {
                AudioServicesPlayAlertSound(app.soundID)
                return
            }else if UserDefaults.standard.string(forKey: "sound") == "1" && UserDefaults.standard.string(forKey: "shake") == "2" {
                AudioServicesPlaySystemSound(app.soundID)
            }else if UserDefaults.standard.string(forKey: "sound") == "2" && UserDefaults.standard.string(forKey: "shake") == "1" {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
        if app.addFriendCount < 0 {
            app.addFriendCount = 0
        }
        app.addFriendCount += 1
        self.tabBar.items?[1].badgeValue = String(format: "%d", app.addFriendCount)
    }
    
    func onScaned(qrcode: String) {
        BoXinUtil.onScaned(qrcode: qrcode)
    }
}
