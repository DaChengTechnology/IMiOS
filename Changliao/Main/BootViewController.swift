//
//  BootViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

typealias BootComplite = () -> Void

class BootViewController: UIViewController,UIScrollViewDelegate {
    
    weak var rootController:UINavigationController?
    var isFirst = true
    var urls:[String] = Array<String>()
    var guideScrollView:UIScrollView = UIScrollView(frame: CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    var pageControll:UIPageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 4, height: 0))
    var needShowBoot:Bool = false
    private var complete:(() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(onShowAD), name: Notification.Name("AdvCompilit"), object: nil)
        if UserDefaults.standard.string(forKey: "token") == nil {
            let app = UIApplication.shared.delegate as! AppDelegate
            app.isNeedLogin = true
        }
    }
    
    func setComplite(finash:@escaping BootComplite) {
        complete = finash
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirst {
            isFirst = false
        }else{
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            if self.needShowBoot {
                return
            }
            self.complete?()
//            let app = UIApplication.shared.delegate as! AppDelegate
//            self.dismiss(animated: false, completion: {
//                if app.isNeedLogin {
//                    if UIViewController.currentViewController() is MainChangeLoginVc {
//                        return
//                    }
//                    if UIViewController.currentViewController() is LoginViewController {
//                        return
//                    }
//                    let sb = UIStoryboard(name: "Main", bundle: nil)
//                    let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
////                    vc.view.makeToast("请重新登录")
//                    UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
//                    return
//                }
//                if let group = app.group {
//                    let sb = UIStoryboard(name: "Main", bundle: nil)
//                    let vc = sb.instantiateViewController(withIdentifier: "Shake") as! ShakeViewController
//                    vc.groupId = group.id
//                    vc.groupOwnerName = group.name
//                    UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
//                    app.group = nil
//                    return
//                }
//                if let person = app.person {
//                    let vc = shakeVc()
//                    vc.username = person.name!
//                    vc.userIcon = person.portrait!
//                    vc.userId = person.id!
//                    UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
//                    app.person = nil
//                    return
//                }
//                if let apns = app.apnsData {
//                    if let group = apns.g {
//                        if let chat = UIViewController.currentViewController() as? ChatViewController {
//                            if chat.conversation.conversationId == group {
//                                return
//                            }
//                            UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
//                        }
//                        let vc = ChatViewController(conversationChatter: group, conversationType: EMConversationTypeGroupChat)
//                        UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
//                        app.apnsData = nil
//                    }else{
//                        if let chat = UIViewController.currentViewController() as? ChatViewController {
//                            if chat.conversation.conversationId == apns.f {
//                                return
//                            }
//                            UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
//                        }
//                        let vc = ChatViewController(conversationChatter: apns.f, conversationType: EMConversationTypeChat)
//                        UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
//                        app.apnsData = nil
//                    }
//                }
//            })
        }
    }

    @objc func onShowAD(){
        let app = UIApplication.shared.delegate as! AppDelegate
        urls = Array<String>()
        if app.adv!.count > 0 {
            needShowBoot = true
            for data in app.adv! {
                urls.append(data!.picture_url!)
            }
            guideScrollView.backgroundColor = UIColor.white
            guideScrollView.contentSize = CGSize(width: CGFloat(urls.count) * UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            guideScrollView.isUserInteractionEnabled = true
            guideScrollView.isScrollEnabled = true
            guideScrollView.isPagingEnabled = true
            guideScrollView.showsVerticalScrollIndicator = false
            guideScrollView.showsHorizontalScrollIndicator = false
            guideScrollView.bounces = false
            guideScrollView.autoresizingMask = .flexibleWidth
            guideScrollView.delegate = self
            self.view.addSubview(guideScrollView)
            for i in 0 ..< urls.count {
                let imageView = UIImageView(frame: CGRect(x: CGFloat(i) * UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = .scaleAspectFill
                imageView.layer.masksToBounds = true
                imageView.sd_setImage(with: URL(string: urls[i]), completed: nil)
                guideScrollView.addSubview(imageView)
            }
            pageControll.numberOfPages = urls.count
            self.view.addSubview(pageControll)
            pageControll.mas_makeConstraints { (make) in
                make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-16)
                make?.centerX.equalTo()(guideScrollView)
                make?.width.mas_equalTo()(250)
                make?.height.mas_equalTo()(50)
            }
            Thread.sleep(forTimeInterval: 2)
            UIView.animate(withDuration: 0.3) {
                self.guideScrollView.frame = UIScreen.main.bounds
            }
        }else{
            needShowBoot = false

        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if page == urls.count - 1 {
            let swipe = UISwipeGestureRecognizer(target: nil, action: nil)
            if swipe.direction == .right {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.complete?()
//                    self.toLoginOrWelcomeCOntroller(animated: false, complete: {() in
//                        if UserDefaults.standard.string(forKey: "token") == nil {
//                            if (UIViewController.currentViewController() as? BootViewController) != nil {
//                                let app = UIApplication.shared.delegate as! AppDelegate
//                                app.isNeedLogin = true
//                                return
//                            }
//                            if UIViewController.currentViewController() is MainChangeLoginVc {
//                                return
//                            }
//                            if UIViewController.currentViewController() is LoginViewController {
//                                return
//                            }
//                            if ((UserDefaults.standard.string(forKey: "FirstLogin") != "YES"))
//                            {
//                                let vc = MainChangeLoginVc()
//                                self.present(vc, animated: true, completion: nil)
//                                UserDefaults.standard.set("YES", forKey: "FirstLogin")
//                                
//                            }else
//                            {
//                                let sb = UIStoryboard(name: "Main", bundle: nil)
//                                let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
//                                self.present(vc, animated: false, completion: nil)
//                            }
//                            return
//                        }
//                        let app = UIApplication.shared.delegate as! AppDelegate
//                        if app.isNeedLogin {
//                            let sb = UIStoryboard(name: "Main", bundle: nil)
//                            let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
//                            //                    vc.view.makeToast("请重新登录")
//                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
//                            return
//                        }
//                        if let group = app.group {
//                            let sb = UIStoryboard(name: "Main", bundle: nil)
//                            let vc = sb.instantiateViewController(withIdentifier: "Shake") as! ShakeViewController
//                            vc.groupId = group.id
//                            vc.groupOwnerName = group.name
//                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
//                            app.group = nil
//                            return
//                        }
//                        if let person = app.person {
//                            let vc = shakeVc()
//                            vc.username = person.name!
//                            vc.userIcon = person.portrait!
//                            vc.userId = person.id!
//                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
//                            app.person = nil
//                            return
//                        }
//                        if let apns = app.apnsData {
//                            if let group = apns.g {
//                                if let chat = UIViewController.currentViewController() as? ChatViewController {
//                                    if chat.conversation.conversationId == group {
//                                        return
//                                    }
//                                    UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
//                                }
//                                let vc = ChatViewController(conversationChatter: group, conversationType: EMConversationTypeGroupChat)
//                                UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
//                                app.apnsData = nil
//                            }else{
//                                if let chat = UIViewController.currentViewController() as? ChatViewController {
//                                    if chat.conversation.conversationId == apns.f {
//                                        return
//                                    }
//                                    UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
//                                }
//                                let vc = ChatViewController(conversationChatter: apns.f, conversationType: EMConversationTypeChat)
//                                UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
//                                app.apnsData = nil
//                            }
//                        }
//                    })
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = guideScrollView.contentOffset.x
        let pageNum : Int = Int(offsetX/UIScreen.main.bounds.size.width)
        pageControll.currentPage = pageNum
    }

}
