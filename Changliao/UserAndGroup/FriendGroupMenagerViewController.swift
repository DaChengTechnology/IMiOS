//
//  FriendGroupMenagerViewController.swift
//  boxin
//
//  Created by guduzhonglao on 11/14/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import Masonry

class FriendGroupMenagerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,NewFriendGroupDelefate {
    
    var tableView:UITableView = UITableView(frame: CGRect.zero)
    var groupInfo:[FriendGroupInfoData?]? = [FriendGroupInfoData].deserialize(from: UserDefaults.standard.string(forKey: "FriendGroup"))
    var isloading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        view.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "eeeeee")
        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "eeeeee")
        tableView.bounces = false
        self.view.addSubview(tableView)
        tableView.mas_makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)
                make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)
            } else {
                // Fallback on earlier versions
                make?.top.equalTo()(self.view)
                make?.bottom.equalTo()(self.view)
            }
            make?.left.equalTo()(self.view.mas_left)
            make?.right.equalTo()(self.view.mas_right)
        }
        tableView.setEditing(true, animated: false)
        self.navigationItem.title = "分组管理"
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
        guard let group = groupInfo else {
            return 0
        }
        return group.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return DCUtill.SCRATIO(x: 10)
            }
            if indexPath.row == 2 {
                return DCUtill.SCRATIO(x: 24)
            }
            return DCUtill.SCRATIO(x: 50)
        }
        return DCUtill.SCRATIO(x: 50)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section > 0 && indexPath.row > 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section > 0 && indexPath.row > 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section > 0 && indexPath.row > 0 {
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section > 0 && proposedDestinationIndexPath.row > 0 {
            return proposedDestinationIndexPath
        }
        return sourceIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let move = groupInfo?[sourceIndexPath.row]
        groupInfo?.remove(at: sourceIndexPath.row)
        groupInfo?.insert(move, at: destinationIndexPath.row)
        updateFriend()
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
                cell.textLabel?.text = "添加新的分组"
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
                let tap = UITapGestureRecognizer(target: self, action: #selector(onClick(g:)))
                cell.addGestureRecognizer(tap)
                return cell
            }
            cell.textLabel?.text = "添加新的分组"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            let tap = UITapGestureRecognizer(target: self, action: #selector(onClick(g:)))
            cell.addGestureRecognizer(tap)
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendGroup") else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "FriendGroup")
            guard let f = groupInfo?[indexPath.row] else {
                cell.textLabel?.text = ""
                cell.selectionStyle = .none
                return cell
            }
            cell.textLabel?.text = f.fenzu_name
            cell.selectionStyle = .none
            return cell
        }
        cell.selectionStyle = .none
        guard let f = groupInfo?[indexPath.row] else {
            cell.textLabel?.text = ""
            return cell
        }
        cell.textLabel?.text = f.fenzu_name
        return cell
    }
    
    @objc func onClick(g:UIGestureRecognizer) {
        if g.state == .ended {
            let alert = NewFriendGroupAlert()
            alert.delegate = self
            alert.show()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 && indexPath.row == 1 {
//            let alert = NewFriendGroupAlert()
//            alert.delegate = self
//            alert.show()
//            return
//        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "删除该分组后，好友自动并入默认分组", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (a) in
                let model = DeleteFenzuSendModel()
                model.fenzu_id = self.groupInfo?[indexPath.row]?.fenzu_id
                BoXinProvider.request(.DeleteFenzu(model: model)) { (result) in
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            if let model = BaseReciveModel.deserialize(from: try? res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.groupInfo?.remove(at: indexPath.row)
                                    DispatchQueue.main.async {
                                        tableView.beginUpdates()
                                        tableView.deleteRows(at: [indexPath], with: .left)
                                        tableView.endUpdates()
                                    }
                                    self.updateFriend()
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
                                }
                                self.isloading = false
                            }else{
                                DispatchQueue.main.async {
                                    self.isloading = false
                                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.isloading = false
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            self.isloading = false
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func CreatedFriendGroup(_ info: FriendGroupInfoData?) {
        guard info != nil else {
            return
        }
        groupInfo?.append(info)
        groupInfo = groupInfo?.sorted(by: { (a1, a2) -> Bool in
            return a1?.sort_num ?? 0 < a2?.sort_num ?? 1
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        updateFriend()
    }
    
    func updateFriend() {
         if groupInfo?.count ?? 0 < 1 {
                       return
                   }
                   var fgroup = Array<String>()
                   for i in 1 ..< (groupInfo?.count ?? 1) {
                       fgroup.append("\(groupInfo?[i]?.fenzu_id ?? ""):\(i)")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
