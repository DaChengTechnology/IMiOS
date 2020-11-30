//
//  InvitationFriendTableViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/17/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class InvitationFriendTableViewController: UITableViewController {
    
    var model:[GetUserData?]?
    var isLoading:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(UINib(nibName: "InvitationFriendTableViewCell", bundle: nil), forCellReuseIdentifier: "InvitationFriend")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        title = NSLocalizedString("NewFriend", comment: "New friend")
        NotificationCenter.default.addObserver(forName: NSNotification.Name("friendRequestDidReceive"), object: nil, queue: nil) { (no) in
            self.loadData()
        }
        tableView.rowHeight = 63
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DCUtill.setNavigationBarTittle(controller: self)
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let app = UIApplication.shared.delegate as! AppDelegate
        app.addFriendCount = 0
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if model == nil {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if model == nil {
            return 0
        }
        return model!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationFriend", for: indexPath) as! InvitationFriendTableViewCell

        cell.headImageView.sd_setImage(with: URL(string: model![indexPath.row]!.portrait!), placeholderImage: UIImage(named: "moren"))
        cell.nickNameLabel.text = model![indexPath.row]?.user_name
        cell.invitationInfoLabel.text = model![indexPath.row]?.remark
        cell.lookButton.tag = indexPath.row
        cell.lookButton.addTarget(self, action: #selector(onLook(button:)), for: .touchUpInside)
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "拒绝"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("QuestionRefuse", comment: "Are you sure you want to reject him/her?"), preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
                SVProgressHUD.show()
                let mo = ApplyForSendModel()
                if self.model == nil {
                    self.loadData()
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataErrorReloading", comment: "Data error,Reloadding"))
                    return
                }
                if self.model?.count ?? 0 <= indexPath.row {
                    self.loadData()
                    UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataErrorReloading", comment: "Data error,Reloadding"))
                    return
                }
                mo.target_user_id = self.model![indexPath.row]?.user_id
                BoXinProvider.request(.RefuseApplyForUser(model: mo)) { (result) in
                    switch(result){
                    case .success(let res):
                        if res.statusCode == 200 {
                            do{
                                if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                    guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                        return
                                    }
                                    if model.code == 200 {
                                        let err = EMClient.shared()?.contactManager.declineInvitation(forUsername: mo.target_user_id!)
                                        if err == nil {
                                            self.view.makeToast(NSLocalizedString("RejectSuccessed", comment: "Rejected successfully"))
                                            self.loadData()
                                        }else{
                                            self.view.makeToast(NSLocalizedString("RejectFailed", comment: "Rejected failed"))
                                            self.isLoading = false
                                        }
                                        let app = UIApplication.shared.delegate as! AppDelegate
                                        if app.addFriendCount > 0 {
                                            app.addFriendCount -= 1
                                        }
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
                                            let sb = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = sb.instantiateViewController(withIdentifier: "LoginNavigation")
                                            vc.modalPresentationStyle = .overFullScreen
                                            self.present(vc, animated: false, completion: nil)
                                        }
                                        self.view.makeToast(model.message)
                                        SVProgressHUD.dismiss()
                                    }
                                }else{
                                    self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                    SVProgressHUD.dismiss()
                                }
                            }catch{
                                self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                                SVProgressHUD.dismiss()
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                            SVProgressHUD.dismiss()
                        }
                    case .failure(let err):
                        self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                        print(err.errorDescription!)
                        SVProgressHUD.dismiss()
                    }
                }
            }
            alert.addAction(ok)
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
            alert.addAction(cancel)
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func onDisagree(sender:UIButton) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("QuestionRefuse", comment: "Are you sure you want to reject him/her?"), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (a) in
            if self.isLoading
            {
                
            }
            self.isLoading = true
            SVProgressHUD.show()
            let mo = ApplyForSendModel()
            if self.model == nil {
                self.loadData()
                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataErrorReloading", comment: "Data error,Reloadding"))
                return
            }
            if self.model?.count ?? 0 <= sender.tag - 10000 {
                self.loadData()
                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("DataErrorReloading", comment: "Data error,Reloadding"))
                return
            }
            mo.target_user_id = self.model![sender.tag - 10000]?.user_id
            BoXinProvider.request(.RefuseApplyForUser(model: mo)) { (result) in
                switch(result){
                case .success(let res):
                    if res.statusCode == 200 {
                        do{
                            if let model = SendSMSReciveModel.deserialize(from: try res.mapString()) {
                                guard BoXinUtil.isTokenExpired(model.code ?? 0) else {
                                    return
                                }
                                if model.code == 200 {
                                    let err = EMClient.shared()?.contactManager.declineInvitation(forUsername: mo.target_user_id!)
                                    if err == nil {
                                        self.view.makeToast(NSLocalizedString("RejectSuccessed", comment: "Rejected successfully"))
                                        self.loadData()
                                    }else{
                                        self.view.makeToast(NSLocalizedString("RejectFailed", comment: "Rejected failed"))
                                        DispatchQueue.main.async {
                                            self.isLoading = false
                                        }
                                    }
                                    let app = UIApplication.shared.delegate as! AppDelegate
                                    if app.addFriendCount > 0 {
                                        app.addFriendCount -= 1
                                    }
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
                                        let sb = UIStoryboard(name: "Main", bundle: nil)
                                        self.present(sb.instantiateViewController(withIdentifier: "LoginNavigation"), animated: false, completion: nil)
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
        alert.addAction(ok)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: "Cancel"), style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.modalPresentationStyle = .overFullScreen
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onLook(button:UIButton) {
        if button.tag < (model?.count ?? 0) {
            let vc = UserDetailViewController()
            vc.newFriendModel = self.model?[button.tag]
            vc.type=1
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < (model?.count ?? 0) {
            let vc = UserDetailViewController()
            vc.newFriendModel = self.model?[indexPath.row]
            vc.type=1
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
                                let app = UIApplication.shared.delegate as! AppDelegate
                                app.addFriendCount = model.data?.count ?? 0
                                self.model = model.data
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                DispatchQueue.main.async {
                                    self.isLoading = false
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
                                    self.present(vc, animated: false, completion: nil)
                                }
                                self.view.makeToast(model.message)
                            }
                        }else{
                            self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                        }
                    }catch{
                        self.view.makeToast(NSLocalizedString("DataInWrongFormat", comment: "Data in wrong format"))
                    }
                }else{
                    self.view.makeToast(NSLocalizedString("ServerConnectError", comment: "Server connect error"))
                }
            case .failure(let err):
                self.view.makeToast(NSLocalizedString("NetworkConnectFeild", comment: "Network connect feild"))
                print(err.errorDescription!)
            }
        }
    }

}
