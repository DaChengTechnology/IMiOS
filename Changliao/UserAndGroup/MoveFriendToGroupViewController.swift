//
//  MoveFriendToGroupViewController.swift
//  boxin
//
//  Created by guduzhonglao on 11/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit

@objc class MoveFriendToGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,NewFriendGroupDelefate {
    
    var tableView = UITableView(frame: CGRect.zero)
    var friendGroup = [FriendGroupInfoData].deserialize(from: UserDefaults.standard.string(forKey: "FriendGroup"))
    var isloading = false
    @objc var userId:String?
    var friendGroupID:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EFEFEF")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "#EFEFEF")
        tableView.separatorStyle = .none
        self.navigationItem.title = "移动分组"
        self.view.addSubview(tableView)
        tableView.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
            make?.right.equalTo()(self.view)
            make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
        }
        guard let contract = [FriendGroupData].deserialize(from: UserDefaults.standard.string(forKey: "Contact1")) else{
            return
        }
        for c in contract {
            guard c != nil else {
                continue
            }
            for f in c!.friendList {
                if f.user_id == userId {
                    friendGroupID = c?.fenzu_id
                    break
                }
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return friendGroup?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 2 {
                return DCUtill.SCRATIO(x: 10)
            }
        }
        return DCUtill.SCRATIO(x: 50)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 2 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "HCell") else {
                    let cell = UITableViewCell(style: .default, reuseIdentifier: "HCell")
                    cell.backgroundColor = UIColor.clear
                    cell.contentView.backgroundColor  = UIColor.clear
                    cell.selectionStyle = .none
                    return cell
                }
                cell.backgroundColor = UIColor.clear
                cell.contentView.backgroundColor  = UIColor.clear
                cell.selectionStyle = .none
                return cell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewGroupCell") else {
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "NewGroupCell")
                cell.textLabel?.text = "添加到新的分组"
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
                return cell
            }
            cell.textLabel?.text = "添加到新的分组"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendGroup") as? FriendGroupCell else {
            let cell = FriendGroupCell(style: .default, reuseIdentifier: "FriendGroup")
            cell.groupNameLable.text = friendGroup?[indexPath.row]?.fenzu_name
            if friendGroup?[indexPath.row]?.fenzu_id  == friendGroupID {
                cell.haveImage.image = UIImage(named: "friendInGroup")
            }else{
                cell.haveImage.image = nil
            }
            return cell
        }
        cell.groupNameLable.text = friendGroup?[indexPath.row]?.fenzu_name
        if friendGroup?[indexPath.row]?.fenzu_id  == friendGroupID {
            cell.haveImage.image = UIImage(named: "friendInGroup")
        }else{
            cell.haveImage.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            let alert = NewFriendGroupAlert()
            alert.delegate = self
            alert.show()
        }
        if indexPath.section == 1 {
            if friendGroup?[indexPath.row]?.fenzu_id == friendGroupID {
                let alert = UIAlertController(title: "好友已经在该分组", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                moveFriendToGroup(groupId: friendGroup?[indexPath.row]?.fenzu_id ?? "", false)
            }
        }
    }
    
    func CreatedFriendGroup(_ info: FriendGroupInfoData?) {
        friendGroup?.append(info)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: (friendGroup?.count ?? 1)-1, section: 1)], with: .left)
        tableView.endUpdates()
        moveFriendToGroup(groupId: info?.fenzu_id ?? "", true)
    }
    
    func moveFriendToGroup(groupId:String,_ isRefresh:Bool) {
        if isloading {
            return
        }
        isloading = true
        SVProgressHUD.show()
        let model = MoveFriendToGroupSendModel()
        model.fenzu_id = groupId
        model.target_user_id = userId
        BoXinProvider.request(.MoveFriendToNewGroup(model: model)) { (result) in
            switch result {
            case .success(let res):
                if res.statusCode == 200 {
                    if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                        guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                            SVProgressHUD.dismiss()
                            return
                        }
                        if model.code == 200 {
                            
                            self.updateFriend(true)
                        }else{
                            SVProgressHUD.dismiss()
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
                                self.view.makeToast(model.message)
                            }
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        if isRefresh {
                            self.updateFriend(false)
                        }
                        DispatchQueue.main.async {
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }
                }else{
                    SVProgressHUD.dismiss()
                    if isRefresh {
                        self.updateFriend(false)
                    }
                    DispatchQueue.main.async {
                        self.view.makeToast("服务器连接失败")
                    }
                }
            case .failure(_):
                SVProgressHUD.dismiss()
                if isRefresh {
                    self.updateFriend(false)
                }
                DispatchQueue.main.async {
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                }
            }
        }
    }
    
    func updateFriend(_ isBack:Bool) {
         if friendGroup?.count ?? 0 < 1 {
                       return
                   }
                   var fgroup = Array<String>()
                   for i in 1 ..< (friendGroup?.count ?? 1) {
                       fgroup.append("\(friendGroup?[i]?.fenzu_id ?? ""):\(i)")
                   }
                   let model = ReSortSendModel()
                   model.param = fgroup.joined(separator: ",")
                   BoXinProvider.request(.ReSort(model: model)) { (result) in
                       switch result {
                       case .success(let res):
                           if res.statusCode == 200 {
                               if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                                   guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    SVProgressHUD.dismiss()
                                       return
                                   }
                                   if model.code == 200 {
                                    SVProgressHUD.dismiss()
                                       NotificationCenter.default.post(name: Notification.Name("UpdateFriend"), object: nil)
                                    if isBack {
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                   }else{
                                    SVProgressHUD.dismiss()
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
                                               UIViewController.currentViewController()?.present(nav, animated: false, completion: nil)
                                           }
                                       }
                                    DispatchQueue.main.async {
                                        self.view.makeToast(model.message)
                                    }
                                   }
                               }else{
                                   DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                       UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                   }
                               }
                           }else{
                               DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                   UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                               }
                           }
                       case .failure(_):
                           DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                               UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                           }
                       }
                   }
    }

}
