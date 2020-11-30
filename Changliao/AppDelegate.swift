//
//  AppDelegate.swift
//  boxin
//
//  Created by guduzhonglao on 6/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Toast_Swift
import AudioToolbox
import Alamofire
import IQKeyboardManagerSwift
import CoreTelephony

let debugHXKey = "1120190605065481#boxin"
let HXKey = "1111190610211907#boxin-final"
let kaixinliaoKey="1121190827085520#kaixinliao"
let reqquestQueue = OperationQueue()

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate,EMClientDelegate,EMChatManagerDelegate,EMGroupManagerDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var soundID:SystemSoundID = 0
    var isNeedLogin: Bool = false
  @objc  weak var player:AVAudioPlayer?
  @objc  weak var timer:DispatchSourceTimer?
    var apnsData:APNSDaataModel?
    @objc var ossClient:OSSClient?
    var group:SQLData?
    var person:SQLData?
    var networkState:NetworkReachabilityManager.NetworkReachabilityStatus?
    var adv:[AdvertData?]?
    var addFriendCount:Int = 0
    var haveFriendRequest:Bool = false
    var shortcutType:String?
    var isAutoLogin:Bool = false
    let netTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue(label: "net.onlineCheck"))
    
    @objc var isNetworkConnect:Bool {
        return (networkState == .reachable(.ethernetOrWiFi)) || (networkState == .reachable(.wwan))
    }
    func checkNetWork() {
        let cellularData = CTCellularData()
        let auth = cellularData.restrictedState
        if auth == .restricted {
            let alert = UIAlertController(title: "已为\"畅聊\"关闭蜂窝移动数据", message:
                "您可以在\"设置\"中为此应用程序打开蜂窝移动数据", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "设置", style: .default, handler: { (a) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
            UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        getNetWork()
        checkNetWork()
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            self.shortcutType = shortcutItem.type
        }
        if let apns = launchOptions?[.remoteNotification] as? [String:Any] {
            if let apnss = APNSDaataModel.deserialize(from: apns) {
                apnsData = apnss
            }
        }
        reqquestQueue.maxConcurrentOperationCount = 5
        reqquestQueue.name = "cn.bj.chaangliao"
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Boot") as! BootViewController
        vc.setComplite {
            self.window?.rootViewController = sb.instantiateViewController(withIdentifier: "MainNav")
            self.window?.makeKeyAndVisible()
        }
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatViewController.self]
        loadData()
        let options = EMOptions(appkey: HXKey)
        options?.apnsCertName = "new_cll"
        EMClient.shared()?.initializeSDK(with: options!)
        EaseSDKHelper.share()?.hyphenateApplication(application, didFinishLaunchingWithOptions: launchOptions)
        EMClient.shared()?.chatManager.remove(self)
        EMClient.shared()?.add(self, delegateQueue: DispatchQueue(label: "Boxin.Client.Queue"))
        EMClient.shared()?.chatManager.add(self, delegateQueue: DispatchQueue(label: "Boxin.Message.Queue"))
        UNUserNotificationCenter.current().requestAuthorization(options: .init(arrayLiteral: .badge,.sound)) { (result, err) in
            if result {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        if UserDefaults.standard.string(forKey: "newMessage") == nil {
            UserDefaults.standard.set("1", forKey: "newMessage")
            UserDefaults.standard.set("1", forKey: "sound")
            UserDefaults.standard.set("1", forKey: "shake")
            UserDefaults.standard.set("Add", forKey: "add")
            UserDefaults.standard.set("Dele", forKey: "dele")
        }
        AudioServicesCreateSystemSoundID(URL(fileURLWithPath: Bundle.main.path(forResource: "ding", ofType: "mp3")!) as CFURL, &soundID)
        let config = BuglyConfig()
        // 设置自定义日志上报的级别，默认不上报自定义日志
        config.reportLogLevel = .verbose
        Bugly.start(withAppId: "39d6147494", config: config)
        EaseEmotionEscape.sharedInstance()?.setEaseEmotionEscapePattern("\\[(.*?)\\]")
        var dic = NSMutableDictionary(dictionary: ["[:voice]":"voiseCall","[:vedio]":"vedioCall"])
        if let emotionDB = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "emotionDB", ofType: "plist")!) {
            for (key,value) in emotionDB {
                dic.setValue(value, forKey: key as! String)
            }
            DispatchQueue.global().async {
                for (_,value) in emotionDB {
                    UIImage(named: value as! String)
                }
            }
        }
        EaseEmotionEscape.sharedInstance()?.setEaseEmotionEscape(dic as? [AnyHashable : Any])
        let credential = OSSStsTokenCredentialProvider(accessKeyId: "LTAIV3Bi486ZiSiB", secretKeyId: "ps10ksRcHlClI1EMZJPmJ3Q9SWBCnU", securityToken: "")
        ossClient = OSSClient(endpoint: "oss-cn-hongkong.aliyuncs.com", credentialProvider: credential)
        if let dics = launchOptions?[.remoteNotification] {
            if let data = APNSDaataModel.deserialize(from: dics as? Dictionary) {
                apnsData = data
            }
        }
        let manager = NetworkReachabilityManager()
        manager?.listener = { stats in
            self.networkState = stats
        }
        manager?.startListening()
        YBIBCopywriter.shared().type = .simplifiedChinese
        reqquestQueue.addOperation {
            self.getAD()
        }
        reqquestQueue.addOperation {
            self.getVersion()
        }
        netTimer.schedule(deadline: .now() + 10, repeating: 30)
        netTimer.setEventHandler {
            let lasttime = UserDefaults.standard.double(forKey: "lastNetRequest")
            let now = Date().timeIntervalSince1970
            if now - lasttime > 90 {
                self.callServerOnline()
            }
        }
        netTimer.resume()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let apnss = APNSDaataModel.deserialize(from: userInfo as? [String:Any]) {
            apnsData = apnss
            completionHandler(.newData)
        }
        completionHandler(.noData)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "ScanQRCode" {
            if let root = window?.rootViewController as? MainRootViewController {
                if self.isNeedLogin {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                if let vc = UIViewController.currentViewController() as? WelcomeViewController {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                if UIViewController.currentViewController() is LoginPhoneViewController {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                if UIViewController.currentViewController() is LoginPasswordViewController {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                if UIViewController.currentViewController() is RegisterViewController {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                root.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                let vc = NewSaoSaoViewController()
                vc.saoyisaoBlock={(Str)in
                    self.onScaned(qrcode: Str)
                }
                root.pushViewController(vc, animated: true)
            }else{
                shortcutType = shortcutItem.type
                completionHandler(true)
                return
            }
        }
        if shortcutItem.type == "MyQRCode" {
            if let root = window?.rootViewController as? MainRootViewController {
                if self.isNeedLogin {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                if let vc = UIViewController.currentViewController() as? WelcomeViewController {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                if UIViewController.currentViewController() is LoginPhoneViewController {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                if UIViewController.currentViewController() is LoginPasswordViewController {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                if UIViewController.currentViewController() is RegisterViewController {
                    shortcutType = shortcutItem.type
                    completionHandler(true)
                    return
                }
                let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo"))
                let m = QRcodeModel()
                m.id = model?.db?.user_id
                root.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
                let vc = ErWeiMaViewController()
                vc.jsonStr = m.toJSONString() ?? ""
                root.pushViewController(vc, animated: true)
            }else{
                shortcutType = shortcutItem.type
                completionHandler(true)
                return
            }
        }
        completionHandler(false)
    }
    
    func getVersion() {
        BoXinProvider.request(.GetVersion) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = VersionReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                if let buildVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey! as String] as? String {
                                    if let newVersion = model.data?.newVersion {
                                        if Int(newVersion) ?? 0 > Int(buildVersion) ?? 0 {
                                            let alert = UIAlertController(title: "有新版本", message: nil, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
                                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (a) in
                                                UIApplication.shared.open(URL(string: model.data?.apkUrl ?? "https://www.baidu.com")!, options: [:],
                                                                          completionHandler: {
                                                                            (success) in
                                                })
                                            }))
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                                                alert.modalPresentationStyle = .overFullScreen
                                                UIAlertController.currentViewController()?.present(alert, animated: true, completion: nil)
                                            })
                                        }
                                    }
                                }
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
            case .failure(let err):
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }
    
    func getAD() {
        BoXinProvider.request(.AdvertQuery) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = AdvertQueryReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.adv = model.data
                                NotificationCenter.default.post(Notification(name: Notification.Name("AdvCompilit")))
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
            case .failure(let err):
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
                print(err.errorDescription!)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NotificationCenter.default.post(name: NSNotification.Name("EndCall"), object: nil)
        EMClient.shared()?.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        EMClient.shared()?.applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
        if response.notification.request.content.userInfo["type"] as? Int == 1 {
            UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            let vc = ChatViewController(conversationChatter: response.notification.request.content.userInfo["conversationID"] as? String, conversationType: EMConversationTypeChat)
            if let data = QueryFriend.shared.queryFriend(id: response.notification.request.content.userInfo["conversationID"] as! String) {
                vc?.title = data.name
            }else{
                if let da = QueryFriend.shared.queryStronger(id: response.notification.request.content.userInfo["conversationID"] as! String) {
                    vc?.title = da.name
                }
            }
            UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
        }
        if response.notification.request.content.userInfo["type"] as? Int == 2 {
            UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
            let vc = ChatViewController(conversationChatter: response.notification.request.content.userInfo["conversationID"] as? String, conversationType: EMConversationTypeGroupChat)
            if let data = QueryFriend.shared.queryGroup(id: response.notification.request.content.userInfo["conversationID"] as! String) {
                vc?.title = data.groupName
            }else{
                if let da = QueryFriend.shared.getGroupName(id: response.notification.request.content.userInfo["conversationID"] as! String){
                    vc?.title = da
                }
            }
            UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        if #available(iOS 13.0, *) {
//            DispatchQueue.global().async {
//                let b = deviceToken.bytes
//                var token = ""
//                var imtoken = ""
//                for i in 0 ..< 8 {
//                    token += String(format: "%02.2hhx", b[i])
//                    imtoken += String(format: "%02x", b[i])
//                }
//                let tokendate = deviceToken.subdata(in: Range<Data.Index>(uncheckedBounds: (lower: Data.Index(0), upper: Data.Index(8))))
//                UserDefaults.standard.setValue(imtoken, forKeyPath: "deviceToken")
//                EMClient.shared()?.bindDeviceToken(tokendate)
//            }
//        }else{
//            DispatchQueue.global().async {
//                let b = deviceToken.bytes
//                var token = ""
//                var imtoken = ""
//                for i in 0 ..< 8 {
//                    token += String(format: "%08x", b[i])
//                    imtoken += String(format: "%02x", b[i])
//                }
//                UserDefaults.standard.setValue(imtoken, forKeyPath: "deviceToken")
//                EMClient.shared()?.bindDeviceToken(deviceToken)
//            }
//        }
//    }
    
    func autoLoginDidCompleteWithError(_ aError: EMError!) {
        if aError != nil {
            DispatchQueue.main.async {
                if (UIViewController.currentViewController() as? BootViewController) != nil {
                    self.isNeedLogin = true
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
    }
    
    func connectionStateDidChange(_ aConnectionState: EMConnectionState) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EMConnectionState"), object: aConnectionState)
    }
    
    func userAccountDidLoginFromOtherDevice() {
        DispatchQueue.main.async {
            if (UIViewController.currentViewController() as? BootViewController) != nil {
                self.isNeedLogin = true
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "boxin")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func messagesDidReceive(_ aMessages: [Any]!) {
        let msg = aMessages as! [EMMessage]
        if checkAppState() {
            for i in stride(from: 0, to: msg.count, by: 1) {
                if msg[i].chatType == EMChatTypeChat {
                    let contract = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
                    if contract == nil {
                        return
                    }
                    for con in contract! {
                        for c in con!.data! {
                            if c?.user_id == msg[i].from {
                                if c?.is_shield == 1 {
                                    return
                                }
                                if c?.is_shield == 2 {
                                    if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                                        if UserDefaults.standard.string(forKey: "sound") == "1" && UserDefaults.standard.string(forKey: "shake") == "1"
                                        {
                                            DispatchQueue.main.async {
                                                AudioServicesPlayAlertSound(self.soundID)
                                            }
                                            return
                                        }else if UserDefaults.standard.string(forKey: "sound") == "1" && UserDefaults.standard.string(forKey: "shake") == "2" {
                                            DispatchQueue.main.async {
                                                AudioServicesPlaySystemSound(self.soundID)
                                            }
                                        }else if UserDefaults.standard.string(forKey: "sound") == "2" && UserDefaults.standard.string(forKey: "shake") == "1" {
                                            DispatchQueue.main.async {
                                                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                        if UserDefaults.standard.string(forKey: "sound") == "1" && UserDefaults.standard.string(forKey: "shake") == "1"
                        {
                            DispatchQueue.main.async {
                                AudioServicesPlayAlertSound(self.soundID)
                            }
                            return
                        }else if UserDefaults.standard.string(forKey: "sound") == "1" && UserDefaults.standard.string(forKey: "shake") == "2" {
                            DispatchQueue.main.async {
                                AudioServicesPlaySystemSound(self.soundID)
                            }
                        }else if UserDefaults.standard.string(forKey: "sound") == "2" && UserDefaults.standard.string(forKey: "shake") == "1" {
                            DispatchQueue.main.async {
                                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                            }
                        }
                    }
                }else{
                    let data = QueryFriend.shared.queryGroup(id: msg[i].conversationId)
                    if data?.is_pingbi == 2 {
                        if UserDefaults.standard.string(forKey: "newMessage") == "1" {
                            if UserDefaults.standard.string(forKey: "sound") == "1" && UserDefaults.standard.string(forKey: "shake") == "1"
                            {
                                DispatchQueue.main.async {
                                    AudioServicesPlayAlertSound(self.soundID)
                                }
                                return
                            }else if UserDefaults.standard.string(forKey: "sound") == "1" && UserDefaults.standard.string(forKey: "shake") == "2" {
                                DispatchQueue.main.async {
                                    AudioServicesPlaySystemSound(self.soundID)
                                }
                            }else if UserDefaults.standard.string(forKey: "sound") == "2" && UserDefaults.standard.string(forKey: "shake") == "1" {
                                DispatchQueue.main.async {
                                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                }
                            }
                        }
                    }
                }
            }
        }else{
            for i in stride(from: 0, to: msg.count, by: 1) {
                if msg[i].chatType == EMChatTypeChat {
                    let contract = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
                    if contract == nil {
                        return
                    }
                    for con in contract! {
                        for c in con!.data! {
                            if c?.user_id == msg[i].from {
                                if c?.is_shield == 2 {
                                    let content = UNMutableNotificationContent()
                                    content.title = c?.target_user_nickname ?? msg[i].from
                                    content.body = getLastMessageText(message: msg[i])
                                    content.sound = UNNotificationSound.default
                                    content.userInfo = ["type":1,"conversationID":msg[i].from,"msgID":msg[i].messageId]
                                    let request = UNNotificationRequest(identifier: "畅聊", content: content, trigger: nil)
                                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                }else{
                                    return
                                }
                            }
                        }
                    }
                }else{
                    let data = QueryFriend.shared.queryGroup(id: msg[i].conversationId)
                    if data?.is_pingbi == 2 {
                        let content = UNMutableNotificationContent()
                        content.title = data?.groupName ?? msg[i].conversationId
                        content.body =  getLastMessageText(message: msg[i])
                        content.sound = UNNotificationSound.default
                        content.userInfo = ["type":2,"conversationID":msg[i].conversationId,"msgID":msg[i].messageId]
                        let request = UNNotificationRequest(identifier: "畅聊", content: content, trigger: nil)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    }else{
                        return
                    }
                }
            }
        }
    }
    func cmdMessagesDidReceive(_ aCmdMessages: [Any]!) {
        for msg in aCmdMessages as! [EMMessage] {
            if msg.ext != nil {
                if (msg.ext["AllMsg"] as? Bool) ?? false {
                    guard let own = msg.ext["own"] as? String else {
                        continue
                    }
                    if let json = [MessageDeleteModel].deserialize(from: own) {
                        for model in json {
                            var err :EMError?
                            let con = EMClient.shared()?.chatManager.getConversation(model?.userid, type: EMConversationTypeChat, createIfNotExist: false)
                            con?.deleteMessage(withId: model?.mesasageId, error: &err)
                        }
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                    }
                }
                if msg.ext["type"] as? String == "msgid" {
                    let conversation = EMClient.shared()?.chatManager.getConversation(msg.ext["id"] as? String, type: EMConversationTypeGroupChat, createIfNotExist: true)
                    var error:EMError?
                    guard let msgid = msg.ext["msgid"] as? String else {
                        continue
                    }
                    if msg.ext["userid"] as? String == EMClient.shared()?.currentUsername {
                        guard let rcmsg = conversation?.loadMessage(withId: msgid, error: &error) else {
                            continue
                        }
                        DispatchQueue.main.async {
                            if let vc = UIViewController.currentViewController() as? ChatViewController {
                                vc._recall(with: rcmsg, text: "群主撤回一条消息", isSave: true)
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                            }else{
                                let msge = EaseSDKHelper.getTextMessage("群主撤回一条消息", to: msg.conversationId, messageType: EMChatTypeGroupChat, messageExt: ["em_recall":true])
                                conversation?.deleteMessage(withId: rcmsg.messageId, error: &error)
                                msge?.timestamp = rcmsg.timestamp
                                msge?.localTime = rcmsg.localTime
                                conversation?.insert(msge, error: &error)
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                            }
                        }
                        EMClient.shared()?.chatManager.recall(rcmsg, completion: { (m, err) in
                            if err != nil {
                                print(err?.errorDescription)
                            }
                        })
                    }else{
                        if let m = conversation?.loadMessage(withId: msgid, error: &error) {
                            DispatchQueue.main.async {
                                if let vc = UIViewController.currentViewController() as? ChatViewController {
                                    vc._recall(with: m, text: "群主撤回一条消息", isSave: true)
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                }else{
                                    let msge = EaseSDKHelper.getTextMessage("群主撤回一条消息", to: msg.conversationId, messageType: EMChatTypeGroupChat, messageExt: ["em_recall":true])
                                    conversation?.deleteMessage(withId: m.messageId, error: &error)
                                    msge?.timestamp = m.timestamp
                                    msge?.localTime = m.localTime
                                    conversation?.insert(msge, error: &error)
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                }
                            }
                        }
                    }
                }
                if msg.ext["type"] as? String == "personMSG" {
                    let conversation = EMClient.shared()?.chatManager.getConversation(msg.conversationId, type: EMConversationTypeChat, createIfNotExist: true)
                    var error:EMError?
                    if msg.ext["userid"] != nil {
                        guard let msgid = msg.ext["msgid"] as? String else {
                            continue
                        }
                        if EMClient.shared()?.currentUsername == msg.ext["userid"] as? String {
                            let m = conversation?.loadMessage(withId: msgid, error: &error)
                            if m == nil {
                                continue
                            }
                            DispatchQueue.main.async {
                                if let vc = UIViewController.currentViewController() as? ChatViewController {
                                    if vc.conversation.conversationId == msg.from {
                                        vc._Delete(withMessageID: msgid, text: "", isDelete: true)
                                     vc.FocusDelete(msgid)
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    }else{
                                        conversation?.deleteMessage(withId: msgid, error: &error)
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    }
                                }else{
                                    conversation?.deleteMessage(withId: msgid, error: &error)
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                }
                            }
                            EMClient.shared()?.chatManager.recall(m, completion: { (m, err) in
                               
                            })
                        }else{
                            DispatchQueue.main.async {
                                if let vc = UIViewController.currentViewController() as? ChatViewController {
                                    if vc.conversation.conversationId == msg.from {
                                        vc._Delete(withMessageID: msgid, text: "", isDelete: true)
                                        vc.FocusDelete(msgid)
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    }else{
                                        conversation?.deleteMessage(withId: msgid, error: &error)
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    }
                                }else{
                                    conversation?.deleteMessage(withId: msgid, error: &error)
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                }
                            }
                        }
                    }
                }
                if msg.ext["type"] as? String == "deleteMSG" {
                    let conversation = EMClient.shared()?.chatManager.getConversation(msg.ext["id"] as? String, type: EMConversationTypeGroupChat, createIfNotExist: true)
                    var error:EMError?
                    if msg.ext["userid"] != nil {
                        guard let msgid = msg.ext["msgid"] as? String else {
                            continue
                        }
                        if EMClient.shared()?.currentUsername == msg.ext["userid"] as? String {
                            guard let rcmsg = conversation?.loadMessage(withId: msgid, error: &error) else {
                                conversation?.deleteMessage(withId: msgid, error: &error)
                                continue
                            }
                            DispatchQueue.main.async {
                                if let vc = UIViewController.currentViewController() as? ChatViewController {
                                    if vc.conversation.conversationId == msg.ext["id"] as? String {
                                        vc._Delete(withMessageID: msgid, text: "", isDelete: true)
                                        vc.FocusDelete(msgid)
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    }else{
                                        conversation?.deleteMessage(withId: msgid, error: &error)
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    }
                                }else{
                                    conversation?.deleteMessage(withId: msgid, error: &error)
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                }
                            }
                            EMClient.shared()?.chatManager.recall(rcmsg, completion: { (m, err) in
                                if err != nil {
                                    print(err?.errorDescription)
                                }
                            })
                        }else{
                            DispatchQueue.main.async {
                                if let vc = UIViewController.currentViewController() as? ChatViewController {
                                    if let m = conversation?.loadMessage(withId: msgid, error: &error) {
                                        vc._Delete(with: m, text: "", isDelete: true)
                                        vc.FocusDelete(msgid)
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    }else{
                                        vc._Delete(withMessageID: msgid, text: "", isDelete: true)
                                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                    }
                                }else{
                                    conversation?.deleteMessage(withId: msgid, error: &error)
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateMessage")))
                                }
                            }
                        }
                    }
                }
                if msg.ext["type"] as? String == "dyd" {
                    guard let groupId = msg.ext["id"] as? String else {
                        continue
                    }
                    if let group = QueryFriend.shared.queryGroup(id: groupId) {
                        DispatchQueue.main.async {
                            if UIViewController.currentViewController() is BootViewController {
                                self.group = SQLData()
                                self.group?.id = msg.ext["id"] as? String
                                self.group?.name = msg.ext["adminname"] as? String
                                return
                            }
                            if UIViewController.currentViewController() is WelcomeViewController {
                                self.group = SQLData()
                                self.group?.id = msg.ext["id"] as? String
                                self.group?.name = msg.ext["adminname"] as? String
                                return
                            }
                            if UIViewController.currentViewController() is PersonalShakeViewController {
                                return
                            }
                            if UIViewController.currentViewController() is GroupShakeViewController {
                                return
                            }else{
                                if UIViewController.currentViewController() is UIAlertController {
                                    UIViewController.currentViewController()?.dismiss(animated: false, completion: {
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = sb.instantiateViewController(withIdentifier: "GroupShake") as! GroupShakeViewController
                                        vc.groupId = msg.ext["id"] as? String
                                        vc.groupOwnerName = msg.ext["adminname"] as? String
                                        if msg.ext["grade"] as? Int == 1 {
                                            vc.grade = "群主"
                                        }else{
                                            vc.grade = "管理员"
                                        }
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    })
                                    return
                                }
                                let sb = UIStoryboard(name: "Main", bundle: nil)
                                let vc = sb.instantiateViewController(withIdentifier: "GroupShake") as! GroupShakeViewController
                                vc.groupId = msg.ext["id"] as? String
                                vc.groupOwnerName = msg.ext["adminname"] as? String
                                if msg.ext["grade"] as? Int == 1 {
                                    vc.grade = "群主"
                                }else{
                                    vc.grade = "管理员"
                                }
                                vc.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                        }
                        }
                    }else{
                        BoXinUtil.getGroupInfo(groupId: groupId) { (b) in
                            DispatchQueue.main.async {
                                if UIViewController.currentViewController() is BootViewController {
                                    self.group = SQLData()
                                    self.group?.id = msg.ext["id"] as? String
                                    self.group?.name = msg.ext["adminname"] as? String
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
                                if UIViewController.currentViewController() is PersonalShakeViewController {
                                    return
                                }
                                if UIViewController.currentViewController() is GroupShakeViewController {
                                    return
                                }else{
                                    if UIViewController.currentViewController() is UIAlertController {
                                        UIViewController.currentViewController()?.dismiss(animated: false, completion: {
                                            let sb = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = sb.instantiateViewController(withIdentifier: "GroupShake") as! GroupShakeViewController
                                            vc.groupId = msg.ext["id"] as? String
                                            vc.groupOwnerName = msg.ext["adminname"] as? String
                                            if msg.ext["grade"] as? Int == 1 {
                                                vc.grade = "群主"
                                            }else{
                                                vc.grade = "管理员"
                                            }
                                            vc.modalPresentationStyle = .overFullScreen
                                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                        })
                                        return
                                    }
                                    let sb = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = sb.instantiateViewController(withIdentifier: "GroupShake") as! GroupShakeViewController
                                    vc.groupId = msg.ext["id"] as? String
                                    vc.groupOwnerName = msg.ext["adminname"] as? String
                                    if msg.ext["grade"] as? Int == 1 {
                                        vc.grade = "群主"
                                    }else{
                                        vc.grade = "管理员"
                                    }
                                    vc.modalPresentationStyle = .overFullScreen
                                    UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                }
                            }
                        }
                    }
                }
                if msg.ext["type"] as? String == "dydfriend" {
                    guard let userid = msg.ext["id"] as? String else {
                        continue
                    }
                    if userid == EMClient.shared()?.currentUsername {
                        continue
                    }
                    if let friend = QueryFriend.shared.queryFriend(id: msg.ext["id"] as! String) {
                        DispatchQueue.main.async {
                            if UIViewController.currentViewController() is BootViewController {
                                self.person = friend
                                return
                            }
                            if UIViewController.currentViewController() is GroupShakeViewController {
                                return
                            }
                            if UIViewController.currentViewController() is shakeVc {
                                return
                            }else{
                                if UIViewController.currentViewController() is UIAlertController {
                                    UIViewController.currentViewController()?.dismiss(animated: true, completion: {
                                        let vc = shakeVc()
                                        vc.username = friend.name ?? ""
                                        vc.userIcon = friend.portrait ?? ""
                                        vc.userId = friend.id ?? ""
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    })
                                    return
                                }
//                                let sb = UIStoryboard(name: "Main", bundle: nil)
//                                let vc = sb.instantiateViewController(withIdentifier: "PersonalShake") as! PersonalShakeViewController
//                                vc.model = friend
                                let vc = shakeVc()
                                vc.username = friend.name ?? ""
                                vc.userIcon = friend.portrait ?? ""
                                vc.userId = friend.id ?? ""
                                vc.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                            }
                        }
                    }else{
                        BoXinUtil.getFriends{ (b) in
                            if let friend = QueryFriend.shared.queryFriend(id: msg.ext["id"] as! String) {
                                DispatchQueue.main.async {
                                    if UIViewController.currentViewController() is BootViewController {
                                        self.person = friend
                                        return
                                    }
                                    if UIViewController.currentViewController() is GroupShakeViewController {
                                        return
                                    }
                                    if UIViewController.currentViewController() is PersonalShakeViewController {
                                        return
                                    }else{
                                        if UIViewController.currentViewController() is UIAlertController {
                                            UIViewController.currentViewController()?.dismiss(animated: true, completion: {
                                                let vc = shakeVc()
                                                vc.username = friend.name ?? ""
                                                vc.userIcon = friend.portrait ?? ""
                                                vc.userId = friend.id ?? ""
                                                vc.modalPresentationStyle = .overFullScreen
                                                UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                            })
                                            return
                                        }
                                        let vc = shakeVc()
                                        vc.username = friend.name ?? ""
                                        vc.userIcon = friend.portrait ?? ""
                                        vc.userId = friend.id ?? ""
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    if UIViewController.currentViewController() is GroupShakeViewController {
                                        return
                                    }
                                    if UIViewController.currentViewController() is PersonalShakeViewController {
                                        return
                                    }else{
                                        if let model = QueryFriend.shared.queryStronger(id: msg.ext["id"] as! String){
                                            let vc = shakeVc()
                                            vc.username = model.name ?? ""
                                            vc.userIcon = model.portrait ?? ""
                                            vc.userId = model.id ?? ""
                                            vc.modalPresentationStyle = .overFullScreen
                                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                if msg.ext["type"] as? String == "qunAdmin" {
                    DispatchQueue.main.async {
                        if EMClient.shared()?.currentUsername == msg.ext["oldadmin"] as? String {
                            if UIViewController.currentViewController() is ChatViewController {
                                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
                                let alert = UIAlertController(title: nil, message: "你已不是群主", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                                alert.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                            }
                            if UIViewController.currentViewController() is GroupInfoViewController {
                                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
                                let alert = UIAlertController(title: nil, message: "你已不是群主", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                                alert.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                            }
                            if UIViewController.currentViewController() is GroupNoticeViewController {
                                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
                                let alert = UIAlertController(title: nil, message: "你已不是群主", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                                alert.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                            }
                            if UIViewController.currentViewController() is GroupMenagerTableViewController {
                                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
                                let alert = UIAlertController(title: nil, message: "你已不是群主", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                                alert.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                            }
                            if UIViewController.currentViewController() is ChangeGroupOwnerViewController {
                                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
                                let alert = UIAlertController(title: nil, message: "你已不是群主", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                                alert.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                            }
                            if UIViewController.currentViewController() is TakeOutGroupMemberViewController {
                                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
                                let alert = UIAlertController(title: nil, message: "你已不是群主", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                                UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                            }
                            if UIViewController.currentViewController() is SearchGroupMemberViewController {
                                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
                                let alert = UIAlertController(title: nil, message: "你已不是群主", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                                alert.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                            }
                            if UIViewController.currentViewController() is OperationGroupMenagerViewController {
                                UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: true)
                                let alert = UIAlertController(title: nil, message: "你已不是群主", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: nil))
                                alert.modalPresentationStyle = .overFullScreen
                                UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    guard let groupID = msg.ext["id"] as? String else {
                        continue
                    }
                    BoXinUtil.getGroupInfo(groupId: groupID) { (b) in
                        if b {
                            NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                        }
                    }
                }
                if msg.ext["type"] as? String == "qun" {
                    guard let groupID = msg.ext["id"] as? String else {
                        continue
                    }
                    BoXinUtil.getGroupInfo(groupId: groupID) { (b) in
                        if b {
                            NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                        }
                    }
                }
                if msg.ext["type"] as? String == "fire" {
                    BoXinUtil.getFriends { (b) in
                        if b {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fireUpdate"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fireUpdateFromFriend"), object: nil)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateMessage"), object: nil)
                        }
                    }
                }
                if msg.ext["type"] as? String == "qun_shield" {
                    guard let groupID = msg.ext["id"] as? String else {
                        continue
                    }
                    BoXinUtil.getGroupOneMember(groupID: groupID, userID: EMClient.shared()!.currentUsername) { (b) in
                        if b {
                            if let userID = msg.ext["userid"] as? String {
                                if userID == EMClient.shared()?.currentUsername {
                                    NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                                }
                            }else{
                                NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                            }
                        }else{
                            if let userID = msg.ext["userid"] as? String {
                                if userID == EMClient.shared()?.currentUsername {
                                    let member = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: groupID)
                                    if msg.ext["qun_shield"] as? String == "1" {
                                        member?.is_shield = 1
                                    }else{
                                        member?.is_shield = 2
                                    }
                                    QueryFriend.shared.addGroupUser(model: member)
                                    NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                                }
                            }else{
                                let member = QueryFriend.shared.getGroupUser(userId: EMClient.shared()!.currentUsername, groupId: groupID)
                                if msg.ext["qun_shield"] as? String == "1" {
                                    member?.is_shield = 1
                                }else{
                                    member?.is_shield = 2
                                }
                                QueryFriend.shared.addGroupUser(model: member)
                                NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getLastMessageText(message:EMMessage) -> String {
        let lastMsg = message.body
        var text:String = ""
        switch lastMsg?.type {
        case EMMessageBodyTypeImage:
            text = "[图片]"
        case EMMessageBodyTypeText:
            let body = lastMsg as! EMTextMessageBody
            var txt:String = ""
            if body.text.hasSuffix("_encode") {
                let messagetext = String(body.text.split(separator: "_")[0].utf8)
                if messagetext != nil {
                    txt = DCEncrypt.Decode_AES(strToDecode: messagetext!)
                }
            }else{
                txt = body.text
            }
            text = EaseEmotionEscape.string(forInputView: txt)
            if message.ext != nil {
                if message.ext["em_is_big_expression"] != nil {
                    text = "[动画表情]"
                }
                if message.ext["type"] as? String == "person" {
                    text = "[分享名片]"
                }
            }
        case EMMessageBodyTypeVoice:
            text = "[语音]"
        case EMMessageBodyTypeVideo:
            text = "[视频]"
        case EMMessageBodyTypeLocation:
            text = "[位置]"
        case EMMessageBodyTypeFile:
            text = "[文件]"
        default:
            break
        }
        if message.direction == EMMessageDirectionReceive {
            if message.chatType == EMChatTypeChat {
                let contract = [FriendViewModel].deserialize(from: UserDefaults.standard.string(forKey: "Contact"))
                if contract == nil {
                    return text
                }
                if contract != nil {
                    for c in contract! {
                        for a in (c?.data)! {
                            if a?.user_id == message.from {
                                text = a!.target_user_nickname! + ":" + text
                            }
                        }
                    }
                }
            }
            if message.chatType == EMChatTypeGroupChat {
                let data = QueryFriend.shared.getGroupUser(userId: message.from, groupId: message.conversationId)
                if data != nil {
                    if QueryFriend.shared.checkFriend(userID: data!.user_id!) {
                        if data?.friend_name != "" {
                            text = data!.friend_name! + ":" + text
                        }else{
                            text = data!.user_name! + ":" + text
                        }
                    }else{
                        if data?.group_user_nickname != "" {
                            text = data!.group_user_nickname! + ":" + text
                        }else{
                            text = data!.user_name! + ":" + text
                        }
                    }
                }else{
                    let d = QueryFriend.shared.queryFriend(id: message.from)
                    if d != nil {
                        text = d!.name! + ":" + text
                    }
                }
            }
        }
        return text
    }
    
    func loadData() {
        BoXinProvider.request(.InviteList(model: UserInfoSendModel())) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = InviteListReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.addFriendCount = model.data?.count ?? 0
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
                            }
                        }
                    }catch{
                        
                    }
                }else{
                    
                }
            case .failure(let err):
                print(err.errorDescription!)
            }
        }
    }
    
    func onScaned(qrcode: String) {
        BoXinUtil.onScaned(qrcode: qrcode)
    }
    
    func callServerOnline() {
        BoXinProvider.request(.HeartBeat(model: UserInfoSendModel())) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                        guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                            return
                        }
                    }
                }
            case .failure(_):
                return
            }
        }
    }
    
    func userAccountDidRemoveFromServer() {
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
            UIViewController.currentViewController()?.present(nav, animated: false, completion: {
                let alert = UIAlertController(title: "请重新登陆", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                nav.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func userDidForbidByServer() {
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
            UIViewController.currentViewController()?.present(nav, animated: false, completion: {
                let alert = UIAlertController(title: "此账号已被服务器限制", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                nav.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func checkAppState() -> Bool {
        let wait = DispatchSemaphore(value: 1000)
        var result = false
        DispatchQueue.main.async {
            result = UIApplication.shared.applicationState == .active
            wait.signal()
        }
        wait.wait()
        return result
    }
}

