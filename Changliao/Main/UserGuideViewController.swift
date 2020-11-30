//
//  UserGuideViewController.swift
//  boxin
//
//  Created by guduzhonglao on 7/28/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import Masonry

class UserGuideViewController: UIViewController,UIScrollViewDelegate {
    
    var urls:[String] = Array<String>()
    var guideScrollView:UIScrollView = UIScrollView(frame: CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    var pageControll:UIPageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 4, height: 0))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if page == urls.count - 1 {
            let swipe = UISwipeGestureRecognizer(target: nil, action: nil)
            if swipe.direction == .right {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.toLoginOrWelcomeCOntroller(animated: false, complete: {() in
                        let app = UIApplication.shared.delegate as! AppDelegate
                        if app.isNeedLogin {
                            let sb = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                            //                    vc.view.makeToast("请重新登录")
                            vc.modalPresentationStyle = .overFullScreen
                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                            return
                        }
                        if let group = app.group {
                            let sb = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sb.instantiateViewController(withIdentifier: "Shake") as! ShakeViewController
                            vc.groupId = group.id
                            vc.groupOwnerName = group.name
                            vc.modalPresentationStyle = .overFullScreen
                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                            app.group = nil
                            return
                        }
                        if let person = app.person {
                            let vc = shakeVc()
                            vc.username = person.name!
                            vc.userIcon = person.portrait!
                            vc.userId = person.id!
                            vc.modalPresentationStyle = .overFullScreen
                            UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                            app.person = nil
                            return
                        }
                        if let apns = app.apnsData {
                            if let group = apns.g {
                                if let chat = UIViewController.currentViewController() as? ChatViewController {
                                    if chat.conversation.conversationId == group {
                                        return
                                    }
                                    UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
                                }
                                let vc = ChatViewController(conversationChatter: group, conversationType: EMConversationTypeGroupChat)
                                UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
                                app.apnsData = nil
                            }else{
                                if let chat = UIViewController.currentViewController() as? ChatViewController {
                                    if chat.conversation.conversationId == apns.f {
                                        return
                                    }
                                    UIViewController.currentViewController()?.navigationController?.popToRootViewController(animated: false)
                                }
                                let vc = ChatViewController(conversationChatter: apns.f, conversationType: EMConversationTypeChat)
                                UIViewController.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
                                app.apnsData = nil
                            }
                        }
                    })
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = guideScrollView.contentOffset.x
        let pageNum : Int = Int(offsetX/UIScreen.main.bounds.size.width)
        pageControll.currentPage = pageNum
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
