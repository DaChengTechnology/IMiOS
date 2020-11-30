//
//  SettingTableViewController.swift
//  boxin
//
//  Created by guduzhonglao on 6/10/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class SettingTableViewController: UIViewController,ScannerQRCodeDelegate,LogoutDelegate,UITableViewDataSource,UITableViewDelegate {
    var isLoading:Bool = false
    @IBOutlet weak var tableView: UITableView!
    
    func onLogin() {
        BoXinUtil.getUserInfo(Complite: nil)
        BoXinUtil.getMyGroup(nil)
        BoXinUtil.getFriends(nil)
    }
    
    func userLogout() {
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.view.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "User")
        tableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "Setting")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIViewController.currentViewController()?.navigationController?.setNavigationBarHidden(false, animated: false)
        UIViewController.currentViewController()?.navigationController?.navigationBar.tintColor = UIColor.hexadecimalColor(hexadecimal: "DB633D")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        DCUtill.setNavigationBarTittle(controller: self)
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItems(nil, animated: false)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.hexadecimalColor(hexadecimal: "FFFFFF")
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 17
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 157
        }
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "User") as! UserTableViewCell
            if let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo")){
                cell.headImageView.sd_setImage(with: URL(string: (model.db?.portrait)!)!, placeholderImage: UIImage(named: "moren"))
            
            //model?.db?.id_card
                cell.nickNameLabel.text = model.db?.user_name
                cell.idNumberLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@",model.db?.id_card ?? "")
            }
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Setting") as! SettingTableViewCell
            cell.settingImage.image = UIImage(named: "4a2d00d44b5543c57f72077065841c96")
            cell.settingLable.text = "扫一扫"
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Setting") as! SettingTableViewCell
            cell.settingImage.image = UIImage(named: "消息，通知")
            cell.settingLable.text = "消息设置"
            return cell
        }
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Setting") as! SettingTableViewCell
            cell.settingImage.image = UIImage(named: "功能-1")
            cell.settingLable.text = "辅助功能"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Setting") as! SettingTableViewCell
        cell.settingImage.image = UIImage(named: "关于我们")
        cell.settingLable.text = "关于我们"
        return cell        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = UserInfoViewController()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 1 {
            
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
//            let vc = ScannerViewController()
//            vc.delegate = self
            let vc = NewSaoSaoViewController()
            vc.saoyisaoBlock={(Str)in
                self.onScaned(qrcode: Str)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 2 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = NewMessageNoyifitySettingViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 3
        {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = SecondaryfunctionVc()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 4 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = AboutViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func onScaned(qrcode: String) {
        BoXinUtil.onScaned(qrcode: qrcode)
    }
    
    

}
