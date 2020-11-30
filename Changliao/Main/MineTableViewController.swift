//
//  MineTableViewController.swift
//  Chaangliao
//
//  Created by guduzhonglao on 1/20/20.
//  Copyright © 2020 guduzhonglao. All rights reserved.
//

import UIKit

class MineTableViewController: UITableViewController {

    var Word = ["辅助功能","我的收藏","登录痕迹","关于我们"]
    var images = ["fuzu","编组 8","编组 9","编组 10"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(UINib(nibName: "UserInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "UserInfoTableViewCell")
        tableView.register(UINib(nibName: "MineTableViewCell", bundle: nil), forCellReuseIdentifier: "MineTableViewCell")
        tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        let scan = UIBarButtonItem(image: UIImage(named: "scan"), style: .plain, target: self, action: #selector(onscan))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem=scan
        let setting = UIBarButtonItem(image: UIImage(named: "setting"), style: .plain, target: self, action: #selector(onSetting))
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem=setting
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 130
        }
        return 50
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row  == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoTableViewCell") as! UserInfoTableViewCell
            if let model = UserInfoData.deserialize(from: UserDefaults.standard.string(forKey: "userInfo")){
                cell.avaterImageView.sd_setImage(with: URL(string: (model.db?.portrait)!)!, placeholderImage: UIImage(named: "moren"))
            
            //model?.db?.id_card
                cell.userNameLabel.text = model.db?.user_name
                cell.idCardLabel.text = NSLocalizedString("ChattingID", comment: "Chatting ID") + String(format: ":%@",model.db?.id_card ?? "")
                cell.selectionStyle = .none
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MineTableViewCell", for: indexPath) as! MineTableViewCell
        cell.iconImageView.image=UIImage(named: images[indexPath.row-1])
        cell.settingTitle.text=Word[indexPath.row-1]
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row==0 {
            ZZQAvatarPicker.startSelected { (image) in
                if image != nil {
                    BoXinUtil.uploadPortrait(image: image) { (b) in
                        if b {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }else{
                            SVProgressHUD.showError(withStatus: "更换头像失败")
                        }
                    }
                }
            }
        }
        if indexPath.row==1 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = SecondaryfunctionVc()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 2 {
            let vc = CollectionViewController(conversationChatter: "collection", conversationType: EMConversationTypeChat)!
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 3 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = LoginLogController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 4 {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
            let vc = AboutViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func onscan(){
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        let vc = NewSaoSaoViewController()
        vc.saoyisaoBlock={(Str)in
            BoXinUtil.onScaned(qrcode: Str)
        }
        UIViewController.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onSetting(){
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil)
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
