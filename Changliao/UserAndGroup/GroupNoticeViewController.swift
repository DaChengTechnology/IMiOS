//
//  GroupNoticeViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry
import SVProgressHUD

class GroupNoticeViewController: UIViewController,UITextViewDelegate {
    
    var textView:UITextView?
    var model:GroupViewModel?
    var notice:String?
    var isLoading:Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        textView?.delegate = self
        textView?.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(textView!)
        textView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            make?.height.mas_equalTo()(200)
        })
        if model?.administrator_id == EMClient.shared()?.currentUsername {
            textView?.isEditable = true
        }else{
            textView?.isEditable = false
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.view.addGestureRecognizer(tap)
        title = NSLocalizedString("GroupAnnouncement", comment: "Group announcement")
        textView?.text = model?.notice
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
    }
    
    @objc func onTap() {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        if model?.administrator_id == EMClient.shared()?.currentUsername {
            let right = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(addNotice))
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = right
        }
    }
    
    @objc func addNotice() {
        if isLoading {
            return
        }
        self.isLoading = true
        SVProgressHUD.show()
        let  model = SubmitNoticeSendModel()
        model.group_id = self.model?.groupId
        model.notice = textView?.text
        BoXinProvider.request(.SubmitNotice(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    do{
                        if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                            guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                return
                            }
                            if model.code == 200 {
                                self.isLoading = false
                                BoXinUtil.getGroupInfo(groupId: self.model!.groupId!, Complite: { (b) in
                                    
                                    if b {
                                        let body = EMCmdMessageBody(action: "")
                                        var dic = ["type":"qun","id":self.model?.groupId]
                                        if self.model?.is_all_banned == 1 {
                                            dic.updateValue("2", forKey: "grouptype")
                                        }else{
                                            dic.updateValue("1", forKey: "grouptype")
                                        }
                                        let msg = EMMessage(conversationID: self.model!.groupId!, from: EMClient.shared()?.currentUsername, to: self.model!.groupId!, body: body, ext: dic as [AnyHashable : Any])
                                        msg?.chatType = EMChatTypeGroupChat
                                        EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                            
                                        }, completion: { (msg, err) in
                                            if err != nil {
                                                print(err?.errorDescription)
                                            }
                                            
                                        })
                                        SVProgressHUD.dismiss()
                                        self.navigationController?.popViewController(animated: true)
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
                                    self.present(vc, animated: false, completion: nil)
                                }
                                self.isLoading = false
                                self.view.makeToast(model.message)
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.isLoading = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }catch{
                        self.isLoading = false
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        SVProgressHUD.dismiss()
                    }
                }else{
                    self.isLoading = false
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                    SVProgressHUD.dismiss()
                }
            case .failure(let err):
                self.isLoading = false
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
                SVProgressHUD.dismiss()
            }
        }
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
