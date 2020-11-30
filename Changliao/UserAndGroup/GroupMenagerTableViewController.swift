//
//  GroupMenagerTableViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/18/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SVProgressHUD

class GroupMenagerTableViewController: UITableViewController {
    
    var isLoadding:Bool = false
    var allJinYan:Bool = false
    var model:GroupViewModel?
    var data:[GroupMemberData?]?
    let updateQueue = DispatchQueue(label: "group.menager.update")

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "GroupInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupInfo")
        tableView.register(UINib(nibName: "UserDetailSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailSetting")
        title = "群管理"
        tableView.rowHeight = 58
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdate), name: Notification.Name("UpdateGroup"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
    }
    
    @objc func onUpdate() {
        weak var weakSelf = self
        updateQueue.async {
            guard let gid = weakSelf?.model?.groupId else {
                return
            }
            weakSelf?.model = QueryFriend.shared.queryGroup(id: gid)
            weakSelf?.data = QueryFriend.shared.getGroupMembers(groupId: gid)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if model?.is_menager == 1 {
            return 2
        }
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        return v
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailSetting", for: indexPath) as! UserDetailSettingTableViewCell
            cell.tittleLable.textColor = UIColor.black
            cell.tittleLable.text = "全员禁言"
            cell.tittleLable.font = UIFont.systemFont(ofSize: 14)
            cell.settingSwitch.isHidden = false
            if model?.is_all_banned == 1 {
                cell.settingSwitch.isOn = true
            }else{
                cell.settingSwitch.isOn = false
            }
            cell.settingSwitch.addTarget(self, action: #selector(onjinyan), for: .touchUpInside)
            return cell
        }
        
        if indexPath.section == 1 {
            if model?.is_admin == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
                cell.tittleLabel.text = "群主权限转让"
                return cell
            }
            if model?.is_menager == 1 && model?.is_admin == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
                cell.tittleLabel.text = "踢出群成员"
                return cell
            }
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
            cell.tittleLabel.text = "踢出群成员"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfo", for: indexPath) as! GroupInfoTableViewCell
        cell.tittleLabel.text = "管理员设置"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if model?.is_menager == 1 && model?.is_admin == 2 {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let vc = TakeOutGroupMemberViewController()
                vc.model = model
                vc.data = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if model?.is_admin == 1 {
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
                let vc = ChangeGroupOwnerViewController()
                vc.model = model
                vc.data = data
                vc.typeID = 1
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        if indexPath.section == 2 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = TakeOutGroupMemberViewController()
            vc.model = model
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 3 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = OperationGroupMenagerViewController()
            vc.model = model
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @objc func onjinyan() {
        if isLoadding
        {
            return
        }
        self.isLoadding = true
        SVProgressHUD.show()
        if model?.is_all_banned == 1 {
            let model = DeleteGroupSendModel()
            model.group_id = self.model?.groupId
            BoXinProvider.request(.CancelGroupAllBanned(model: model)) { (result) in
                switch(result){
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.isLoadding = false
                                    self.model?.is_all_banned = 2
                                    QueryFriend.shared.addGroup(id: self.model!.groupId!, nickName: self.model!.groupName!, portrait1: self.model!.portrait!, admin_id: self.model!.administrator_id!, is_admin1: self.model!.is_admin, is_mg: self.model!.is_menager, notice1: self.model!.notice, type: self.model!.group_type, allMute: 2, pingbi: self.model!.is_pingbi, userSum: self.model?.groupUserSum ?? 0)
                                    let body = EMCmdMessageBody(action: "")
                                    var dic = ["type":"qun","id":self.model!.groupId!]
                                    dic.updateValue("1", forKey: "grouptype")
                                    let msg = EMMessage(conversationID: self.model!.groupId, from: EMClient.shared()?.currentUsername, to: self.model!.groupId, body: body, ext: dic as [AnyHashable : Any])
                                    msg?.chatType = EMChatTypeGroupChat
                                    EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                        
                                    }, completion: { (msg, err) in
                                        if err != nil {
                                            print(err?.errorDescription)
                                        }
                                        NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                        SVProgressHUD.dismiss()
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
                                    self.isLoadding = false
                                    self.view.makeToast(model.message)
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                self.isLoadding = false
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            self.isLoadding = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        self.isLoadding = false
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    self.isLoadding = false
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }else{
            let model = DeleteGroupSendModel()
            model.group_id = self.model?.groupId
            BoXinProvider.request(.SetGroupAllBanned(model: model)) { (result) in
                switch(result){
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    self.isLoadding = false
                                    self.model?.is_all_banned = 1
                                    QueryFriend.shared.addGroup(id: self.model!.groupId!, nickName: self.model!.groupName!, portrait1: self.model!.portrait!, admin_id: self.model!.administrator_id!, is_admin1: self.model!.is_admin, is_mg: self.model!.is_menager, notice1: self.model!.notice, type: self.model!.group_type, allMute: 1, pingbi: self.model!.is_pingbi, userSum: self.model?.groupUserSum ?? 0)
                                    let body = EMCmdMessageBody(action: "")
                                    var dic = ["type":"qun","id":self.model!.groupId]
                                    dic.updateValue("2", forKey: "grouptype")
                                    let msg = EMMessage(conversationID: self.model!.groupId, from: EMClient.shared()?.currentUsername, to: self.model!.groupId, body: body, ext: dic as [AnyHashable : Any])
                                    msg?.chatType = EMChatTypeGroupChat
                                    EMClient.shared()?.chatManager.send(msg, progress: { (a) in
                                        
                                    }, completion: { (msg, err) in
                                        if err != nil {
                                            print(err?.errorDescription)
                                        }
                                        NotificationCenter.default.post(Notification(name: Notification.Name("UpdateGroup")))
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                        SVProgressHUD.dismiss()
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
                                    self.isLoadding = false
                                    self.view.makeToast(model.message)
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                self.isLoadding = false
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }catch{
                            self.isLoadding = false
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        self.isLoadding = false
                        self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                        SVProgressHUD.dismiss()
                    }
                case .failure(let err):
                    self.isLoadding = false
                    self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                    print(err.errorDescription!)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
