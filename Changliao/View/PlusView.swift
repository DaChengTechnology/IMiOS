//
//  PlusView.swift
//  boxin
//
//  Created by guduzhonglao on 6/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SDWebImage
import SVProgressHUD
class PlusView: UIView,ScannerQRCodeDelegate{
    func onScaned(qrcode: String) {
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
                                    UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                                    let vc = UserDetailViewController()
                                    vc.model = FriendData(data: md.data)
                                    QueryFriend.shared.addStranger(id: md.data!.user_id!, user_name: md.data!.user_name!, portrait1: md.data!.portrait!, card: md.data!.id_card!)
                                    DispatchQueue.main.async {
                                        UIViewController.currentViewController()?.navigationController?.pushViewController(vc, animated: false)
                                    }
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
                                        let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                        vc.modalPresentationStyle = .overFullScreen
                                        UIViewController.currentViewController()?.present(vc, animated: false, completion: nil)
                                    }
                                    UIViewController.currentViewController()?.view.makeToast(md.message)
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        print(res.statusCode)
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    UIViewController.currentViewController()?.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    print(err.errorDescription)
                    SVProgressHUD.dismiss()
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
        SVProgressHUD.dismiss()
    
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var bk:UIView
    var trigon:UIImageView
    
    init() {
        bk = UIView(frame: UIScreen.main.bounds)
        bk.backgroundColor = UIColor.clear
        trigon = UIImageView(image: UIImage(named: "三角"))
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        guard let navView = UIViewController.currentViewController()?.navigationController?.view else {
            return
        }
        navView.addSubview(bk)
        navView.addSubview(self)
        navView.addSubview(trigon)
        self.mas_makeConstraints { (make) in
            make?.top.equalTo()(UIViewController.currentViewController()?.navigationController?.navigationBar.mas_bottom)?.offset()(10)
            make?.right.equalTo()(navView.mas_safeAreaLayoutGuideRight)?.offset()(10)
            make?.width.mas_equalTo()(140)
            make?.height.mas_equalTo()(20)
        }
        trigon.mas_makeConstraints { (make) in
            make?.top.equalTo()(UIViewController.currentViewController()?.navigationController?.navigationBar.mas_bottom)
            make?.right.equalTo()(navView.mas_safeAreaLayoutGuideRight)?.offset()(-20)
            make?.width.mas_equalTo()(15)
            make?.height.mas_equalTo()(11)
        }
        let addGroupChaatView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 56))
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(onAddGroupChat(g:)))
        addGroupChaatView.addGestureRecognizer(tap1)
        addGroupChaatView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "00000099")
        self.addSubview(addGroupChaatView)
        addGroupChaatView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.mas_left)
            make?.top.equalTo()(self.mas_top)
            make?.right.equalTo()(self.mas_right)
            make?.height.mas_equalTo()(56)
        }
        let image1 = UIImageView(image: UIImage(named: "群聊11111"))
        image1.frame = CGRect(x: 25, y: 16, width: 24, height: 24)
        addGroupChaatView.addSubview(image1)
        image1.mas_makeConstraints { (make) in
            make?.left.equalTo()(addGroupChaatView)?.offset()(25)
            make?.top.equalTo()(addGroupChaatView)?.offset()(18)
            make?.width.mas_equalTo()(24)
            make?.height.mas_equalTo()(20)
        }
        let label1 = UILabel(frame: CGRect(x: 57, y: 19, width: 70, height: 18))
        label1.font = UIFont.systemFont(ofSize: 15)
        label1.textColor = UIColor.white
        label1.textAlignment = .left
        label1.text = "发起群聊"
        addGroupChaatView.addSubview(label1)
        label1.mas_makeConstraints { (make) in
            make?.left.equalTo()(image1.mas_right)?.offset()(8)
            make?.top.equalTo()(addGroupChaatView)?.offset()(19)
        }
        let bt1 = UIView(frame: CGRect(x: 0, y: 55, width: 140, height: 1))
        bt1.backgroundColor = UIColor.white
        addGroupChaatView.addSubview(bt1)
        bt1.mas_makeConstraints { (make) in
            make?.left.equalTo()(addGroupChaatView)
            make?.bottom.equalTo()(addGroupChaatView)
            make?.right.equalTo()(addGroupChaatView)
            make?.height.mas_equalTo()(1)
        }
        let addFriendView = UIView(frame: CGRect(x: 0, y: 56, width: 140, height: 56))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(onAddFriend(g:)))
        addFriendView.addGestureRecognizer(tap2)
        addFriendView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "00000099")
        self.addSubview(addFriendView)
        addFriendView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.mas_left)
            make?.top.equalTo()(addGroupChaatView.mas_bottom)
            make?.right.equalTo()(self.mas_right)
            make?.height.mas_equalTo()(56)
        }
        let image2 = UIImageView(image: UIImage(named: "添加111111"))
        image2.frame = CGRect(x: 25, y: 16, width: 24, height: 24)
        addFriendView.addSubview(image2)
        image2.mas_makeConstraints { (make) in
            make?.left.equalTo()(addFriendView)?.offset()(25)
            make?.top.equalTo()(addFriendView)?.offset()(18)
            make?.width.mas_equalTo()(20)
            make?.height.mas_equalTo()(20)
        }
        let label2 = UILabel(frame: CGRect(x: 57, y: 19, width: 70, height: 18))
        label2.font = UIFont.systemFont(ofSize: 15)
        label2.textColor = UIColor.white
        label2.textAlignment = .left
        label2.text = "添加好友"
        addFriendView.addSubview(label2)
        label2.mas_makeConstraints { (make) in
            make?.left.equalTo()(image2.mas_right)?.offset()(8)
            make?.top.equalTo()(addFriendView)?.offset()(19)
        }
        let bt2 = UIView(frame: CGRect(x: 0, y: 55, width: 140, height: 1))
        bt2.backgroundColor = UIColor.white
        addFriendView.addSubview(bt2)
        bt2.mas_makeConstraints { (make) in
            make?.left.equalTo()(addFriendView)
            make?.bottom.equalTo()(addFriendView)
            make?.right.equalTo()(addFriendView)
            make?.height.mas_equalTo()(1)
        }
        let CodeView = UIView(frame: CGRect(x: 0, y: 112, width: 140, height: 56))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(onCode(g:)))
        CodeView.addGestureRecognizer(tap3)
        CodeView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "00000099")
        self.addSubview(CodeView)
        CodeView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.mas_left)
            make?.top.equalTo()(addFriendView.mas_bottom)
            make?.right.equalTo()(self.mas_right)
            make?.height.mas_equalTo()(56)
        }
        let image3 = UIImageView(image: UIImage(named: "SCode"))
        image3.frame = CGRect(x: 10, y: 16, width: 24, height: 24)
        CodeView.addSubview(image3)
        image3.mas_makeConstraints { (make) in
            make?.left.equalTo()(CodeView)?.offset()(25)
            make?.top.equalTo()(CodeView)?.offset()(18)
            make?.width.mas_equalTo()(20)
            make?.height.mas_equalTo()(20)
        }
        let label3 = UILabel(frame: CGRect(x: 42, y: 19, width: 70, height: 18))
        label3.font = UIFont.systemFont(ofSize: 15)
        label3.textColor = UIColor.white
        label3.textAlignment = .left
        label3.text = "扫一扫"
        CodeView.addSubview(label3)
        label3.mas_makeConstraints { (make) in
            make?.left.equalTo()(image3.mas_right)?.offset()(18)
            make?.top.equalTo()(CodeView)?.offset()(19)
        }
    }
    
    func show() {
        guard let navView = UIViewController.currentViewController()?.navigationController?.view else {
            trigon.removeFromSuperview()
            bk.removeFromSuperview()
            self.removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.mas_updateConstraints({ (make) in
                make?.top.equalTo()(UIViewController.currentViewController()?.navigationController?.navigationBar.mas_bottom)?.offset()(10)
                make?.right.equalTo()(navView.mas_safeAreaLayoutGuideRight)?.offset()(-13)
                make?.width.mas_equalTo()(140)
                make?.height.mas_equalTo()(56*3)
            })
        }, completion: { (b) in
            let back = UITapGestureRecognizer(target: self, action: #selector(PlusView.onBack(g:)))
            self.bk.addGestureRecognizer(back)
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        bk = UIView(frame: (UIViewController.currentViewController()?.view.bounds)!)
        bk.backgroundColor = UIColor.clear
        trigon = UIImageView(image: UIImage(named: "三角"))
        super.init(coder: aDecoder)
    }
    
    @objc func onAddGroupChat(g:UIGestureRecognizer){
        trigon.removeFromSuperview()
        bk.removeFromSuperview()
        self.removeFromSuperview()
        let alert = UIAlertController(title: nil, message: "选择群类型", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "普通群", style: .default, handler: { (a) in
            UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddGroup") as! AddGroupChatViewController
            UIViewController.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "工作群", style: .default, handler: { (a) in
            UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddGroup") as! AddGroupChatViewController
            vc.groupType = 1
            UIViewController.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
        alert.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController()?.present(alert, animated: true, completion: nil)
    }
    
    @objc func onAddFriend(g:UIGestureRecognizer){
        trigon.removeFromSuperview()
        bk.removeFromSuperview()
        self.removeFromSuperview()
        UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        UIViewController.currentViewController()?.navigationController?.pushViewController(AddFriendViewController(), animated: true)
    }
    @objc func onCode(g:UIGestureRecognizer)
    {
        trigon.removeFromSuperview()
        bk.removeFromSuperview()
        self.removeFromSuperview()
        UIViewController.currentViewController()?.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        let vc = NewSaoSaoViewController()
        vc.saoyisaoBlock={(Str)in
            self.onScaned(qrcode: Str)
        }
        UIViewController.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func onBack(g:UIGestureRecognizer) {
        if g.state == .ended {
            weak var weakself = self
            UIView.animate(withDuration: 0.5, animations: {
                self.mas_updateConstraints({ (make) in
                    make?.top.equalTo()(UIViewController.currentViewController()?.navigationController?.navigationBar.mas_bottom)?.offset()(10)
                    make?.right.equalTo()(UIViewController.currentViewController()?.navigationController?.view.mas_safeAreaLayoutGuideRight)?.offset()(-13)
                    make?.width.mas_equalTo()(140)
                    make?.height.mas_equalTo()(20)
                })
            }, completion: { (b) in
                weakself?.bk.removeFromSuperview()
                weakself?.removeFromSuperview()
                weakself?.trigon.removeFromSuperview()
            })
        }
        
    }
    
}
